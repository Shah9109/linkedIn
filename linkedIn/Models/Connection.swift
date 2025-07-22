import Foundation

struct Connection: Identifiable, Codable {
    var id: String = UUID().uuidString
    var fromUserId: String
    var toUserId: String
    var status: ConnectionStatus
    var requestMessage: String?
    var createdAt: Date
    var updatedAt: Date
    var acceptedAt: Date?
    
    init(fromUserId: String, toUserId: String, requestMessage: String? = nil) {
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.requestMessage = requestMessage
        self.status = .pending
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

enum ConnectionStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case blocked = "blocked"
    case withdrawn = "withdrawn"
    
    var displayText: String {
        switch self {
        case .pending:
            return "Pending"
        case .accepted:
            return "Connected"
        case .declined:
            return "Declined"
        case .blocked:
            return "Blocked"
        case .withdrawn:
            return "Withdrawn"
        }
    }
}

struct ConnectionRequest: Identifiable {
    let id: String
    let connection: Connection
    let fromUser: User
    let toUser: User
} 