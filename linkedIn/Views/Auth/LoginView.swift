import SwiftUI

struct LoginView: View {
    @StateObject private var authService = AuthService()
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showSignup = false
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var showForgotPassword = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .frame(height: geometry.size.height * 0.35)
                    
                    // Login Form Section
                    loginFormSection
                        .padding(.horizontal, Constants.Spacing.lg)
                        .padding(.top, Constants.Spacing.xl)
                    
                    Spacer(minLength: Constants.Spacing.lg)
                }
            }
        }
        .background(Constants.Colors.background)
        .fullScreenCover(isPresented: $showSignup) {
            SignupView()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.Colors.primaryBlue,
                    Constants.Colors.accent
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: Constants.Spacing.lg) {
                // Logo
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                        .scaleEffect(showSignup ? 0.8 : 1.0)
                        .animation(Constants.Animation.spring, value: showSignup)
                    
                    Text("ProNet")
                        .font(Constants.Fonts.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .opacity(showSignup ? 0.8 : 1.0)
                        .animation(Constants.Animation.medium, value: showSignup)
                }
                
                Text("Connect with professionals worldwide")
                    .font(Constants.Fonts.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.lg)
            }
            .padding(.top, Constants.Spacing.xxl)
        }
    }
    
    // MARK: - Login Form Section
    private var loginFormSection: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Welcome Text
            VStack(spacing: Constants.Spacing.sm) {
                Text("Welcome Back")
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Sign in to continue your professional journey")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, Constants.Spacing.md)
            
            // Email Field
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                CustomTextField(
                    text: $email,
                    placeholder: "Email address",
                    keyboardType: .emailAddress,
                    isSecure: false,
                    icon: "envelope.fill",
                    errorMessage: emailError
                )
                .onChange(of: email) { _ in
                    emailError = nil
                    authService.clearError()
                }
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                CustomTextField(
                    text: $password,
                    placeholder: "Password",
                    keyboardType: .default,
                    isSecure: !showPassword,
                    icon: "lock.fill",
                    errorMessage: passwordError,
                    trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                    trailingAction: { showPassword.toggle() }
                )
                .onChange(of: password) { _ in
                    passwordError = nil
                    authService.clearError()
                }
            }
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .font(Constants.Fonts.callout)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.top, Constants.Spacing.xs)
            
            // Error Message
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.error)
                    .padding(.horizontal, Constants.Spacing.md)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .scale))
            }
            
            // Login Button
            Button(action: handleLogin) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .font(Constants.Fonts.headline)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Constants.Colors.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(Constants.CornerRadius.large)
                .scaleEffect(authService.isLoading ? 0.95 : 1.0)
                .animation(Constants.Animation.quick, value: authService.isLoading)
            }
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            .opacity(authService.isLoading || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
            .padding(.top, Constants.Spacing.md)
            
            // Demo Credentials
            demoCredentialsSection
            
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Constants.Colors.border)
                Text("or")
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Constants.Colors.border)
            }
            .padding(.vertical, Constants.Spacing.lg)
            
            // Sign Up Button
            Button(action: { showSignup = true }) {
                HStack {
                    Text("Don't have an account?")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    Text("Sign Up")
                        .font(Constants.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
    
    // MARK: - Demo Credentials Section
    private var demoCredentialsSection: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Text("Demo Credentials")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.secondaryLabel)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.Spacing.sm) {
                ForEach(getDemoCredentials(), id: \.email) { credential in
                    Button(action: {
                        email = credential.email
                        password = credential.password
                    }) {
                        VStack(spacing: 2) {
                            Text(credential.name)
                                .font(Constants.Fonts.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.primaryBlue)
                            Text(credential.email)
                                .font(Constants.Fonts.caption2)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                        .padding(.vertical, Constants.Spacing.xs)
                        .padding(.horizontal, Constants.Spacing.sm)
                        .background(Constants.Colors.lightBlue)
                        .cornerRadius(Constants.CornerRadius.small)
                    }
                }
            }
        }
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Actions
    private func handleLogin() {
        // Validate inputs
        if let emailValidation = authService.validateEmail(email) {
            emailError = emailValidation
            return
        }
        
        if let passwordValidation = authService.validatePassword(password) {
            passwordError = passwordValidation
            return
        }
        
        // Clear errors
        emailError = nil
        passwordError = nil
        
        // Hide keyboard
        hideKeyboard()
        
        // Perform login
        authService.signIn(email: email, password: password)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func getDemoCredentials() -> [(name: String, email: String, password: String)] {
        return [
            (name: "Demo User", email: Constants.DummyCredentials.demoEmail, password: Constants.DummyCredentials.demoPassword),
            (name: "John Doe", email: "john.doe@pronet.com", password: "password123"),
            (name: "Jane Smith", email: "jane.smith@pronet.com", password: "password123"),
            (name: "Alex Johnson", email: "alex.johnson@pronet.com", password: "password123")
        ]
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let icon: String
    let errorMessage: String?
    let trailingIcon: String?
    let trailingAction: (() -> Void)?
    
    init(
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        icon: String,
        errorMessage: String? = nil,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.icon = icon
        self.errorMessage = errorMessage
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack(spacing: Constants.Spacing.md) {
                Image(systemName: icon)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                        .textContentType(keyboardType == .emailAddress ? .emailAddress : .none)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if let trailingIcon = trailingIcon {
                    Button(action: trailingAction ?? {}) {
                        Image(systemName: trailingIcon)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.md)
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(errorMessage != nil ? Constants.Colors.error : Constants.Colors.border, lineWidth: errorMessage != nil ? 2 : 1)
            )
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.error)
                    .padding(.horizontal, Constants.Spacing.sm)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(Constants.Animation.quick, value: errorMessage)
    }
}

#Preview {
    LoginView()
} 