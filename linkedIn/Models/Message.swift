import Foundation

struct ChatRoom: Identifiable, Codable {
    var id: String = UUID().uuidString
    var participants: [String] // User IDs
    var lastMessage: String?
    var lastMessageTime: Date?
    var lastMessageSenderId: String?
    var unreadCount: [String: Int] // User ID -> unread count
    var createdAt: Date
    var updatedAt: Date
    
    init(participants: [String]) {
        self.participants = participants
        self.unreadCount = [:]
        self.createdAt = Date()
        self.updatedAt = Date()
        
        // Initialize unread count for all participants
        for participant in participants {
            self.unreadCount[participant] = 0
        }
    }
}

struct Message: Identifiable, Codable {
    var id: String = UUID().uuidString
    var chatRoomId: String
    var senderId: String
    var senderName: String
    var senderProfileImageURL: String?
    var content: String
    var messageType: MessageType
    var imageURL: String?
    var videoURL: String?
    var documentURL: String?
    var isRead: Bool
    var readBy: [String: Date] // User ID -> read timestamp
    var createdAt: Date
    var updatedAt: Date
    
    init(chatRoomId: String, senderId: String, senderName: String, content: String, messageType: MessageType = .text) {
        self.chatRoomId = chatRoomId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.messageType = messageType
        self.isRead = false
        self.readBy = [:]
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case video = "video"
    case document = "document"
    case voice = "voice"
}

struct Conversation: Identifiable {
    let id: String
    let otherUser: User
    let lastMessage: Message?
    let unreadCount: Int
} 