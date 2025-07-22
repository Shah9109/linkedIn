import Foundation
import Combine

class ChatService: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseManager = FirebaseManager.shared
    private var currentChatRoomId: String?
    
    init() {
        loadDummyConversations()
    }
    
    // MARK: - Conversation Management
    func fetchConversations() {
        isLoading = true
        
        // For demo purposes, return dummy conversations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadDummyConversations()
            self?.isLoading = false
        }
    }
    
    func createOrGetChatRoom(with user: User, completion: @escaping (String?) -> Void) {
        guard let currentUserId = firebaseManager.currentUser?.id else {
            completion(nil)
            return
        }
        
        // For demo purposes, create a dummy chat room ID
        let chatRoomId = "chat_\(currentUserId)_\(user.id)"
        currentChatRoomId = chatRoomId
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(chatRoomId)
        }
    }
    
    // MARK: - Message Management
    func fetchMessages(for chatRoomId: String) {
        currentChatRoomId = chatRoomId
        isLoading = true
        
        // For demo purposes, return dummy messages
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadDummyMessages(for: chatRoomId)
            self?.isLoading = false
        }
    }
    
    func sendMessage(content: String, type: MessageType = .text, imageURL: String? = nil, videoURL: String? = nil) {
        guard let currentUser = firebaseManager.currentUser,
              let chatRoomId = currentChatRoomId else { return }
        
        let message = Message(
            chatRoomId: chatRoomId,
            senderId: currentUser.id,
            senderName: currentUser.fullName,
            content: content,
            messageType: type
        )
        
        var updatedMessage = message
        updatedMessage.senderProfileImageURL = currentUser.profileImageURL
        updatedMessage.imageURL = imageURL
        updatedMessage.videoURL = videoURL
        
        // For demo purposes, add to local array
        messages.append(updatedMessage)
    }
    
    func markMessageAsRead(_ message: Message) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        // Update local message
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            var updatedMessage = messages[index]
            updatedMessage.isRead = true
            updatedMessage.readBy[currentUserId] = Date()
            messages[index] = updatedMessage
        }
    }
    
    // MARK: - Real-time Updates
    func startListeningForMessages(in chatRoomId: String) {
        currentChatRoomId = chatRoomId
        
        // For demo purposes, simulate real-time updates
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.simulateIncomingMessage()
        }
    }
    
    func stopListeningForMessages() {
        // Implementation for stopping real-time listeners
    }
    
    // MARK: - Helper Methods
    private func loadDummyConversations() {
        let dummyUsers = [
            User(email: "sarah.martinez@example.com", fullName: "Sarah Martinez"),
            User(email: "michael.chen@example.com", fullName: "Michael Chen"),
            User(email: "jennifer.lee@example.com", fullName: "Jennifer Lee"),
            User(email: "alex.thompson@example.com", fullName: "Alex Thompson"),
            User(email: "jordan.kim@example.com", fullName: "Jordan Kim")
        ]
        
        let lastMessages = [
            "Hey! How's the new project coming along?",
            "Great meeting today! Let's catch up soon.",
            "Thanks for sharing those resources 📚",
            "Are you free for coffee this week?",
            "Looking forward to collaborating!"
        ]
        
        var conversations: [Conversation] = []
        
        for (index, var user) in dummyUsers.enumerated() {
            user.profileImageURL = "https://picsum.photos/60/60?random=\(index + 400)"
            user.headline = ["iOS Developer", "Backend Engineer", "Product Designer", "Marketing Manager", "Data Analyst"][index]
            
            var lastMessage = Message(
                chatRoomId: "chat_\(index)",
                senderId: user.id,
                senderName: user.fullName,
                content: lastMessages[index]
            )
            lastMessage.createdAt = Date().addingTimeInterval(-Double(index * 1800)) // Messages from different times
            
            let conversation = Conversation(
                id: "chat_\(index)",
                otherUser: user,
                lastMessage: lastMessage,
                unreadCount: index == 0 ? 2 : 0
            )
            
            conversations.append(conversation)
        }
        
        self.conversations = conversations
    }
    
    private func loadDummyMessages(for chatRoomId: String) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        let dummyMessages = [
            Message(chatRoomId: chatRoomId, senderId: "other_user", senderName: "Sarah Martinez", content: "Hey! How's everything going?"),
            Message(chatRoomId: chatRoomId, senderId: currentUserId, senderName: firebaseManager.currentUser?.fullName ?? "You", content: "Hey Sarah! Things are great, just working on some exciting projects."),
            Message(chatRoomId: chatRoomId, senderId: "other_user", senderName: "Sarah Martinez", content: "That sounds awesome! What kind of projects?"),
            Message(chatRoomId: chatRoomId, senderId: currentUserId, senderName: firebaseManager.currentUser?.fullName ?? "You", content: "I'm building a new social networking app with SwiftUI. It's been really fun!"),
            Message(chatRoomId: chatRoomId, senderId: "other_user", senderName: "Sarah Martinez", content: "SwiftUI is amazing! I'd love to hear more about it sometime."),
            Message(chatRoomId: chatRoomId, senderId: currentUserId, senderName: firebaseManager.currentUser?.fullName ?? "You", content: "Definitely! Let's grab coffee next week and I can show you some demos.")
        ]
        
        // Add timestamps
        for (index, var message) in dummyMessages.enumerated() {
            message.createdAt = Date().addingTimeInterval(-Double((dummyMessages.count - index) * 300))
            message.senderProfileImageURL = "https://picsum.photos/40/40?random=\(index + 500)"
        }
        
        self.messages = dummyMessages
    }
    
    private func simulateIncomingMessage() {
        guard currentChatRoomId != nil else { return }
        
        let randomMessages = [
            "How's your day going?",
            "Just saw your latest post!",
            "Are you attending the conference next week?",
            "Great idea in the meeting today!",
            "Let me know if you need any help."
        ]
        
        if Bool.random() && !messages.isEmpty {
            let message = Message(
                chatRoomId: currentChatRoomId!,
                senderId: "simulated_user",
                senderName: "Demo User",
                content: randomMessages.randomElement() ?? "Hello!"
            )
            
            messages.append(message)
        }
    }
    
    private func updateChatRoomLastMessage(chatRoomId: String, message: Message) {
        // Update chat room with last message info
        // Real Firebase implementation would update the chat room document
    }
    
    func refreshConversations() {
        fetchConversations()
    }
} 