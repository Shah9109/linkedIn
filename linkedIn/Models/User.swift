import Foundation

struct User: Identifiable, Codable {
    var id: String = UUID().uuidString
    var email: String
    var fullName: String
    var profileImageURL: String?
    var bio: String?
    var headline: String?
    var location: String?
    var experience: [Experience]
    var education: [Education]
    var skills: [String]
    var connections: [String] // User IDs of connections
    var pendingConnections: [String] // User IDs of pending connection requests
    var isOnline: Bool
    var lastSeen: Date
    var resumeURL: String?
    var phoneNumber: String?
    var website: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(email: String, fullName: String, profileImageURL: String? = nil) {
        self.email = email
        self.fullName = fullName
        self.profileImageURL = profileImageURL
        self.bio = ""
        self.headline = ""
        self.location = ""
        self.experience = []
        self.education = []
        self.skills = []
        self.connections = []
        self.pendingConnections = []
        self.isOnline = false
        self.lastSeen = Date()
        self.phoneNumber = ""
        self.website = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
}

struct Experience: Identifiable, Codable {
    var id = UUID()
    var title: String
    var company: String
    var location: String?
    var startDate: Date
    var endDate: Date?
    var description: String?
    var isCurrentRole: Bool
    
    init(title: String, company: String, startDate: Date, isCurrentRole: Bool = false) {
        self.title = title
        self.company = company
        self.startDate = startDate
        self.isCurrentRole = isCurrentRole
    }
}

struct Education: Identifiable, Codable {
    var id = UUID()
    var institution: String
    var degree: String
    var fieldOfStudy: String?
    var startDate: Date
    var endDate: Date?
    var description: String?
    
    init(institution: String, degree: String, startDate: Date) {
        self.institution = institution
        self.degree = degree
        self.startDate = startDate
    }
} 