import Foundation

struct Notification: Identifiable, Codable {
    var id: String = UUID().uuidString
    var userId: String // Recipient user ID
    var fromUserId: String? // User who triggered the notification
    var fromUserName: String?
    var fromUserProfileImageURL: String?
    var type: NotificationType
    var title: String
    var message: String
    var postId: String? // For post-related notifications
    var connectionRequestId: String? // For connection requests
    var isRead: Bool
    var actionTaken: Bool // For connection requests - true if accepted/declined
    var createdAt: Date
    var updatedAt: Date
    
    init(userId: String, type: NotificationType, title: String, message: String) {
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.isRead = false
        self.actionTaken = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum NotificationType: String, Codable, CaseIterable {
    case like = "like"
    case comment = "comment"
    case share = "share"
    case connectionRequest = "connection_request"
    case connectionAccepted = "connection_accepted"
    case mention = "mention"
    case message = "message"
    case jobAlert = "job_alert"
    case postUpdate = "post_update"
    case profileView = "profile_view"
    
    var icon: String {
        switch self {
        case .like:
            return "heart.fill"
        case .comment:
            return "bubble.left.fill"
        case .share:
            return "arrowshape.turn.up.right.fill"
        case .connectionRequest, .connectionAccepted:
            return "person.2.fill"
        case .mention:
            return "at"
        case .message:
            return "message.fill"
        case .jobAlert:
            return "briefcase.fill"
        case .postUpdate:
            return "doc.text.fill"
        case .profileView:
            return "eye.fill"
        }
    }
    
    var color: String {
        switch self {
        case .like:
            return "red"
        case .comment:
            return "blue"
        case .share:
            return "green"
        case .connectionRequest, .connectionAccepted:
            return "purple"
        case .mention:
            return "orange"
        case .message:
            return "blue"
        case .jobAlert:
            return "brown"
        case .postUpdate:
            return "gray"
        case .profileView:
            return "teal"
        }
    }
} 