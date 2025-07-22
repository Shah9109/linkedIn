import Foundation
import Combine

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let firebaseManager = FirebaseManager.shared
    
    init() {
        // Subscribe to Firebase auth state changes
        firebaseManager.$isUserLoggedIn
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
        
        firebaseManager.$currentUser
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    func signUp(email: String, password: String, fullName: String) {
        isLoading = true
        errorMessage = ""
        
        // For demo purposes, use dummy authentication
        if firebaseManager.authenticateWithDummyCredentials(email: email, password: password) ||
           email.contains("@pronet.com") || email.contains("@demo.com") {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.firebaseManager.createDummyUser(email: email, fullName: fullName)
                self?.isLoading = false
            }
            return
        }
        
        // Real Firebase authentication (commented out for demo)
        /*
        firebaseManager.signUp(email: email, password: password, fullName: fullName) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let user):
                    self?.currentUser = user
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        */
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        // For demo purposes, use dummy authentication
        if firebaseManager.authenticateWithDummyCredentials(email: email, password: password) ||
           email.contains("@pronet.com") || email.contains("@demo.com") {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                let userName = email.components(separatedBy: "@").first?.replacingOccurrences(of: ".", with: " ").capitalizingFirstLetter() ?? "Demo User"
                self?.firebaseManager.createDummyUser(email: email, fullName: userName)
                self?.isLoading = false
            }
            return
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.isLoading = false
                self?.errorMessage = Constants.ErrorMessages.authenticationError
            }
            return
        }
        
        // Real Firebase authentication (commented out for demo)
        /*
        firebaseManager.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        */
    }
    
    func signOut() {
        isLoading = true
        
        // For demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAuthenticated = false
            self?.currentUser = nil
            self?.isLoading = false
            self?.firebaseManager.isUserLoggedIn = false
            self?.firebaseManager.currentUser = nil
        }
        
        // Real Firebase sign out (commented out for demo)
        /*
        do {
            try firebaseManager.signOut()
            isAuthenticated = false
            currentUser = nil
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
        */
    }
    
    func resetPassword(email: String) {
        isLoading = true
        errorMessage = ""
        
        // For demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoading = false
            // Simulate success
        }
        
        // Real Firebase password reset (commented out for demo)
        /*
        firebaseManager.resetPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    // Show success message
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        */
    }
    
    // MARK: - Validation Methods
    func validateEmail(_ email: String) -> String? {
        if email.isEmpty {
            return "Email is required"
        }
        if !email.isValidEmail {
            return "Please enter a valid email address"
        }
        return nil
    }
    
    func validatePassword(_ password: String) -> String? {
        if password.isEmpty {
            return "Password is required"
        }
        if !password.isValidPassword {
            return "Password must be at least 6 characters"
        }
        return nil
    }
    
    func validateFullName(_ fullName: String) -> String? {
        if fullName.isEmpty {
            return "Full name is required"
        }
        if fullName.count < 2 {
            return "Full name must be at least 2 characters"
        }
        return nil
    }
    
    func validateConfirmPassword(_ password: String, _ confirmPassword: String) -> String? {
        if confirmPassword.isEmpty {
            return "Please confirm your password"
        }
        if password != confirmPassword {
            return "Passwords do not match"
        }
        return nil
    }
    
    // MARK: - Helper Methods
    func clearError() {
        errorMessage = ""
    }
} 