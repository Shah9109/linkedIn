import Foundation

struct Post: Identifiable, Codable {
    var id: String = UUID().uuidString
    var authorId: String
    var authorName: String
    var authorProfileImageURL: String?
    var authorHeadline: String?
    var content: String
    var imageURLs: [String]
    var videoURL: String?
    var likes: [String] // User IDs who liked
    var comments: [Comment]
    var shares: Int
    var hashtags: [String]
    var mentions: [String] // User IDs mentioned
    var createdAt: Date
    var updatedAt: Date
    var isEdited: Bool
    
    init(authorId: String, authorName: String, content: String) {
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.imageURLs = []
        self.likes = []
        self.comments = []
        self.shares = 0
        self.hashtags = []
        self.mentions = []
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isEdited = false
    }
    
    var likeCount: Int {
        likes.count
    }
    
    var commentCount: Int {
        comments.count
    }
    
    func isLikedBy(userId: String) -> Bool {
        likes.contains(userId)
    }
}

struct Comment: Identifiable, Codable {
    var id = UUID()
    var authorId: String
    var authorName: String
    var authorProfileImageURL: String?
    var content: String
    var likes: [String] // User IDs who liked the comment
    var replies: [Reply]
    var createdAt: Date
    var updatedAt: Date
    
    init(authorId: String, authorName: String, content: String) {
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.likes = []
        self.replies = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var likeCount: Int {
        likes.count
    }
}

struct Reply: Identifiable, Codable {
    var id = UUID()
    var authorId: String
    var authorName: String
    var authorProfileImageURL: String?
    var content: String
    var likes: [String]
    var createdAt: Date
    
    init(authorId: String, authorName: String, content: String) {
        self.authorId = authorId
        self.authorName = authorName
        self.content = content
        self.likes = []
        self.createdAt = Date()
    }
} 