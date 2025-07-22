import Foundation
import Combine

class NotificationService: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseManager = FirebaseManager.shared
    
    init() {
        loadDummyNotifications()
        updateUnreadCount()
    }
    
    // MARK: - Notification Management
    func fetchNotifications() {
        isLoading = true
        
        // For demo purposes, return dummy notifications
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadDummyNotifications()
            self?.updateUnreadCount()
            self?.isLoading = false
        }
    }
    
    func markAsRead(_ notification: Notification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            var updatedNotification = notifications[index]
            updatedNotification.isRead = true
            updatedNotification.updatedAt = Date()
            notifications[index] = updatedNotification
            
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        for (index, var notification) in notifications.enumerated() {
            if !notification.isRead {
                notification.isRead = true
                notification.updatedAt = Date()
                notifications[index] = notification
            }
        }
        
        updateUnreadCount()
    }
    
    func deleteNotification(_ notification: Notification) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
    }
    
    // MARK: - Notification Creation
    func createNotification(
        for userId: String,
        type: NotificationType,
        title: String,
        message: String,
        fromUserId: String? = nil,
        postId: String? = nil,
        connectionRequestId: String? = nil
    ) {
        let notification = Notification(
            userId: userId,
            type: type,
            title: title,
            message: message
        )
        
        var updatedNotification = notification
        updatedNotification.fromUserId = fromUserId
        updatedNotification.postId = postId
        updatedNotification.connectionRequestId = connectionRequestId
        
        if let fromUserId = fromUserId {
            // In a real app, fetch user details from Firebase
            updatedNotification.fromUserName = "Demo User"
            updatedNotification.fromUserProfileImageURL = "https://picsum.photos/40/40?random=999"
        }
        
        // For demo purposes, add to local array if it's for current user
        if userId == firebaseManager.currentUser?.id {
            notifications.insert(updatedNotification, at: 0)
            updateUnreadCount()
        }
    }
    
    // MARK: - Specific Notification Types
    func notifyLike(postId: String, postAuthorId: String, fromUserId: String, fromUserName: String) {
        guard postAuthorId != fromUserId else { return } // Don't notify if user likes their own post
        
        createNotification(
            for: postAuthorId,
            type: .like,
            title: "New Like",
            message: "\(fromUserName) liked your post",
            fromUserId: fromUserId,
            postId: postId
        )
    }
    
    func notifyComment(postId: String, postAuthorId: String, fromUserId: String, fromUserName: String) {
        guard postAuthorId != fromUserId else { return } // Don't notify if user comments on their own post
        
        createNotification(
            for: postAuthorId,
            type: .comment,
            title: "New Comment",
            message: "\(fromUserName) commented on your post",
            fromUserId: fromUserId,
            postId: postId
        )
    }
    
    func notifyConnectionRequest(toUserId: String, fromUserId: String, fromUserName: String, connectionId: String) {
        createNotification(
            for: toUserId,
            type: .connectionRequest,
            title: "Connection Request",
            message: "\(fromUserName) wants to connect with you",
            fromUserId: fromUserId,
            connectionRequestId: connectionId
        )
    }
    
    func notifyConnectionAccepted(toUserId: String, fromUserId: String, fromUserName: String) {
        createNotification(
            for: toUserId,
            type: .connectionAccepted,
            title: "Connection Accepted",
            message: "\(fromUserName) accepted your connection request",
            fromUserId: fromUserId
        )
    }
    
    func notifyMessage(toUserId: String, fromUserId: String, fromUserName: String) {
        guard toUserId != fromUserId else { return }
        
        createNotification(
            for: toUserId,
            type: .message,
            title: "New Message",
            message: "\(fromUserName) sent you a message",
            fromUserId: fromUserId
        )
    }
    
    func notifyMention(userId: String, postId: String, fromUserId: String, fromUserName: String) {
        guard userId != fromUserId else { return }
        
        createNotification(
            for: userId,
            type: .mention,
            title: "You were mentioned",
            message: "\(fromUserName) mentioned you in a post",
            fromUserId: fromUserId,
            postId: postId
        )
    }
    
    // MARK: - Helper Methods
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func loadDummyNotifications() {
        let currentUserId = firebaseManager.currentUser?.id ?? "current_user"
        
        let dummyNotifications = [
            Notification(
                userId: currentUserId,
                type: .like,
                title: "New Like",
                message: "Sarah Johnson liked your post"
            ),
            Notification(
                userId: currentUserId,
                type: .comment,
                title: "New Comment",
                message: "Michael Chen commented on your post"
            ),
            Notification(
                userId: currentUserId,
                type: .connectionRequest,
                title: "Connection Request",
                message: "Jennifer Lee wants to connect with you"
            ),
            Notification(
                userId: currentUserId,
                type: .connectionAccepted,
                title: "Connection Accepted",
                message: "Alex Thompson accepted your connection request"
            ),
            Notification(
                userId: currentUserId,
                type: .message,
                title: "New Message",
                message: "Jordan Kim sent you a message"
            ),
            Notification(
                userId: currentUserId,
                type: .mention,
                title: "You were mentioned",
                message: "Emily Rodriguez mentioned you in a post"
            ),
            Notification(
                userId: currentUserId,
                type: .profileView,
                title: "Profile View",
                message: "Someone viewed your profile"
            )
        ]
        
        // Add realistic data
        for (index, var notification) in dummyNotifications.enumerated() {
            notification.createdAt = Date().addingTimeInterval(-Double(index * 3600)) // Notifications from different hours
            notification.isRead = index > 2 // First 3 are unread
            notification.fromUserId = "user_\(index)"
            notification.fromUserName = ["Sarah Johnson", "Michael Chen", "Jennifer Lee", "Alex Thompson", "Jordan Kim", "Emily Rodriguez", "Anonymous"][index]
            notification.fromUserProfileImageURL = "https://picsum.photos/40/40?random=\(index + 600)"
        }
        
        self.notifications = dummyNotifications
    }
    
    func refreshNotifications() {
        fetchNotifications()
    }
    
    // MARK: - Real-time Updates
    func startListeningForNotifications() {
        // For demo purposes, simulate real-time notifications
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.simulateNewNotification()
        }
    }
    
    private func simulateNewNotification() {
        let randomTypes: [NotificationType] = [.like, .comment, .profileView, .message]
        let randomMessages = [
            "liked your post",
            "commented on your post", 
            "viewed your profile",
            "sent you a message"
        ]
        
        if Bool.random() {
            let type = randomTypes.randomElement() ?? .like
            let message = randomMessages.randomElement() ?? "interacted with you"
            
            let notification = Notification(
                userId: firebaseManager.currentUser?.id ?? "",
                type: type,
                title: type.rawValue.capitalized,
                message: "Demo User \(message)"
            )
            
            notifications.insert(notification, at: 0)
            updateUnreadCount()
        }
    }
} 