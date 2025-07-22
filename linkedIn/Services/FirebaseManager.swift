import Foundation

class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    @Published var isUserLoggedIn = false
    @Published var currentUser: User?
    
    private init() {
        // Initialize with dummy state
    }
    
    // MARK: - User Management
    func fetchCurrentUser() {
        // In a real app, this would fetch from Firebase
        // For demo, we'll keep the current user
    }
    
    // MARK: - Authentication (Demo Mode)
    func signUp(email: String, password: String, fullName: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(email: email, fullName: fullName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(newUser))
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(()))
        }
    }
    
    func signOut() throws {
        currentUser = nil
        isUserLoggedIn = false
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(.success(()))
        }
    }
    
    // MARK: - File Upload (Demo Mode)
    func uploadImage(imageData: Data, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Simulate upload delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let dummyURL = "https://picsum.photos/400/300?random=\(Int.random(in: 1...1000))"
            completion(.success(dummyURL))
        }
    }
    
    func uploadVideo(videoURL: URL, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            let dummyURL = "https://www.example.com/video/\(UUID().uuidString).mp4"
            completion(.success(dummyURL))
        }
    }
    
    func uploadDocument(documentURL: URL, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let dummyURL = "https://www.example.com/document/\(UUID().uuidString).pdf"
            completion(.success(dummyURL))
        }
    }
    
    // MARK: - Dummy Authentication (for demo purposes)
    func authenticateWithDummyCredentials(email: String, password: String) -> Bool {
        // Check against dummy credentials
        if email == Constants.DummyCredentials.demoEmail && password == Constants.DummyCredentials.demoPassword {
            return true
        }
        
        for (testEmail, testPassword) in Constants.DummyCredentials.testUsers {
            if email == testEmail && password == testPassword {
                return true
            }
        }
        
        return false
    }
    
    func createDummyUser(email: String, fullName: String) {
        let dummyUser = User(email: email, fullName: fullName)
        currentUser = dummyUser
        isUserLoggedIn = true
    }
} 