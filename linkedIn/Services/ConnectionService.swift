import Foundation
import Combine

class ConnectionService: ObservableObject {
    @Published var users: [User] = []
    @Published var connections: [User] = []
    @Published var pendingRequests: [ConnectionRequest] = []
    @Published var sentRequests: [Connection] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseManager = FirebaseManager.shared
    
    init() {
        loadDummyUsers()
        loadDummyConnections()
    }
    
    // MARK: - User Discovery
    func fetchUsers() {
        isLoading = true
        
        // For demo purposes, return dummy users
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadDummyUsers()
            self?.isLoading = false
        }
    }
    
    // MARK: - Connection Management
    func sendConnectionRequest(to user: User, message: String? = nil) {
        guard let currentUserId = firebaseManager.currentUser?.id else { return }
        
        let connection = Connection(
            fromUserId: currentUserId,
            toUserId: user.id,
            requestMessage: message
        )
        
        // For demo purposes, add to sent requests
        sentRequests.append(connection)
        
        // Remove from users list
        users.removeAll { $0.id == user.id }
    }
    
    func acceptConnectionRequest(_ request: ConnectionRequest) {
        // Add to connections
        connections.append(request.fromUser)
        
        // Remove from pending requests
        pendingRequests.removeAll { $0.id == request.id }
    }
    
    func declineConnectionRequest(_ request: ConnectionRequest) {
        // Remove from pending requests
        pendingRequests.removeAll { $0.id == request.id }
    }
    
    func removeConnection(_ user: User) {
        connections.removeAll { $0.id == user.id }
    }
    
    func withdrawConnectionRequest(_ connection: Connection) {
        sentRequests.removeAll { $0.id == connection.id }
    }
    
    // MARK: - Connection Status
    func getConnectionStatus(with user: User) -> ConnectionStatus? {
        guard firebaseManager.currentUser?.id != nil else { return nil }
        
        // Check if already connected
        if connections.contains(where: { $0.id == user.id }) {
            return .accepted
        }
        
        // Check if request was sent
        if sentRequests.contains(where: { $0.toUserId == user.id }) {
            return .pending
        }
        
        // Check if there's a pending request from this user
        if pendingRequests.contains(where: { $0.fromUser.id == user.id }) {
            return .pending
        }
        
        return nil
    }
    
    // MARK: - Search
    func searchUsers(query: String) {
        if query.isEmpty {
            fetchUsers()
            return
        }
        
        // Simple local search for demo
        let filteredUsers = users.filter { user in
            user.fullName.localizedCaseInsensitiveContains(query) ||
            user.headline?.localizedCaseInsensitiveContains(query) == true ||
            user.bio?.localizedCaseInsensitiveContains(query) == true
        }
        
        self.users = filteredUsers
    }
    
    // MARK: - Helper Methods
    private func loadDummyUsers() {
        let dummyUsers = [
            User(email: "alice.cooper@example.com", fullName: "Alice Cooper"),
            User(email: "bob.johnson@example.com", fullName: "Bob Johnson"),
            User(email: "carol.williams@example.com", fullName: "Carol Williams"),
            User(email: "daniel.brown@example.com", fullName: "Daniel Brown"),
            User(email: "emma.davis@example.com", fullName: "Emma Davis"),
            User(email: "frank.miller@example.com", fullName: "Frank Miller"),
            User(email: "grace.wilson@example.com", fullName: "Grace Wilson"),
            User(email: "henry.moore@example.com", fullName: "Henry Moore"),
            User(email: "iris.taylor@example.com", fullName: "Iris Taylor"),
            User(email: "jack.anderson@example.com", fullName: "Jack Anderson")
        ]
        
        // Add realistic data
        for (index, var user) in dummyUsers.enumerated() {
            user.profileImageURL = "https://picsum.photos/150/150?random=\(index + 100)"
            user.headline = [
                "Senior Software Engineer at TechCorp",
                "Product Manager at InnovateCo",
                "UX Designer at DesignStudio",
                "Data Scientist at Analytics Inc",
                "Marketing Director at BrandCorp",
                "Full Stack Developer at StartupXYZ",
                "DevOps Engineer at CloudTech",
                "Business Analyst at ConsultingGroup",
                "Mobile Developer at AppFactory",
                "AI Research Scientist at FutureLab"
            ][index]
            
            user.bio = [
                "Passionate about creating innovative software solutions that make a difference.",
                "Building products that users love with a focus on customer experience.",
                "Designing intuitive interfaces that solve real-world problems.",
                "Turning data into actionable insights for business growth.",
                "Helping brands tell their story in the digital age.",
                "Full stack developer with expertise in modern web technologies.",
                "Automating infrastructure to enable seamless deployments.",
                "Bridging the gap between business and technology.",
                "Creating mobile experiences that delight users.",
                "Exploring the frontiers of artificial intelligence."
            ][index]
            
            user.location = [
                "San Francisco, CA", "New York, NY", "Seattle, WA", "Austin, TX", "Boston, MA",
                "Los Angeles, CA", "Chicago, IL", "Denver, CO", "Miami, FL", "Portland, OR"
            ][index]
            
            user.skills = [
                ["Swift", "iOS", "SwiftUI", "UIKit"],
                ["Product Management", "Strategy", "Analytics"],
                ["UI/UX", "Figma", "Sketch", "Design Systems"],
                ["Python", "Machine Learning", "Data Analysis"],
                ["Marketing", "Brand Strategy", "Digital Marketing"],
                ["JavaScript", "React", "Node.js", "TypeScript"],
                ["Docker", "Kubernetes", "AWS", "CI/CD"],
                ["Business Analysis", "Requirements", "Process Improvement"],
                ["React Native", "Flutter", "Mobile Development"],
                ["AI", "Deep Learning", "Research", "Python"]
            ][index]
        }
        
        self.users = dummyUsers
    }
    
    private func loadDummyConnections() {
        let connectionUsers = [
            User(email: "connected1@example.com", fullName: "Sarah Martinez"),
            User(email: "connected2@example.com", fullName: "Michael Chen"),
            User(email: "connected3@example.com", fullName: "Jennifer Lee")
        ]
        
        for (index, var user) in connectionUsers.enumerated() {
            user.profileImageURL = "https://picsum.photos/150/150?random=\(index + 200)"
            user.headline = ["iOS Developer", "Backend Engineer", "Product Designer"][index]
        }
        
        self.connections = connectionUsers
        
        // Create some dummy pending requests
        let pendingUsers = [
            User(email: "pending1@example.com", fullName: "Alex Thompson"),
            User(email: "pending2@example.com", fullName: "Jordan Kim")
        ]
        
        for (index, var user) in pendingUsers.enumerated() {
            user.profileImageURL = "https://picsum.photos/150/150?random=\(index + 300)"
            user.headline = ["Marketing Manager", "Data Analyst"][index]
            
            let connection = Connection(
                fromUserId: user.id,
                toUserId: firebaseManager.currentUser?.id ?? ""
            )
            
            let request = ConnectionRequest(
                id: UUID().uuidString,
                connection: connection,
                fromUser: user,
                toUser: firebaseManager.currentUser ?? User(email: "", fullName: "")
            )
            
            pendingRequests.append(request)
        }
    }
    
    func refreshConnections() {
        fetchUsers()
    }
} 