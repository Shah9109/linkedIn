import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var agreedToTerms = false
    
    @State private var fullNameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?
    @State private var termsError: String?
    
    @State private var currentStep = 0
    private let totalSteps = 2
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Progress Bar
                    progressBar
                    
                    // Content
                    ScrollView {
                        VStack(spacing: Constants.Spacing.lg) {
                            // Header
                            headerSection
                            
                            // Form Steps
                            if currentStep == 0 {
                                basicInfoStep
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            } else {
                                passwordStep
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))
                            }
                            
                            // Action Buttons
                            actionButtons
                            
                            Spacer(minLength: Constants.Spacing.xl)
                        }
                        .padding(.horizontal, Constants.Spacing.lg)
                        .padding(.top, Constants.Spacing.lg)
                    }
                }
            }
            .background(Constants.Colors.background)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: Constants.Spacing.sm) {
            HStack {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .frame(height: 4)
                        .foregroundColor(step <= currentStep ? Constants.Colors.primaryBlue : Constants.Colors.border)
                        .animation(Constants.Animation.medium, value: currentStep)
                    
                    if step < totalSteps - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.lg)
            
            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.secondaryLabel)
        }
        .padding(.top, Constants.Spacing.sm)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            Image(systemName: currentStep == 0 ? "person.circle.fill" : "lock.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.primaryBlue)
                .scaleEffect(currentStep == 0 ? 1.0 : 0.9)
                .animation(Constants.Animation.spring, value: currentStep)
            
            VStack(spacing: Constants.Spacing.xs) {
                Text(currentStep == 0 ? "Tell us about yourself" : "Secure your account")
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(currentStep == 0 ? "Enter your basic information to get started" : "Create a strong password to protect your account")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, Constants.Spacing.lg)
    }
    
    // MARK: - Basic Info Step
    private var basicInfoStep: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Full Name Field
            CustomTextField(
                text: $fullName,
                placeholder: "Full Name",
                keyboardType: .default,
                icon: "person.fill",
                errorMessage: fullNameError
            )
            .onChange(of: fullName) { _ in
                fullNameError = nil
                authService.clearError()
            }
            
            // Email Field
            CustomTextField(
                text: $email,
                placeholder: "Email Address",
                keyboardType: .emailAddress,
                icon: "envelope.fill",
                errorMessage: emailError
            )
            .onChange(of: email) { _ in
                emailError = nil
                authService.clearError()
            }
            
            // Professional Tips
            professionalTipsSection
        }
    }
    
    // MARK: - Password Step
    private var passwordStep: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Password Field
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
            
            // Confirm Password Field
            CustomTextField(
                text: $confirmPassword,
                placeholder: "Confirm Password",
                keyboardType: .default,
                isSecure: !showConfirmPassword,
                icon: "lock.fill",
                errorMessage: confirmPasswordError,
                trailingIcon: showConfirmPassword ? "eye.slash.fill" : "eye.fill",
                trailingAction: { showConfirmPassword.toggle() }
            )
            .onChange(of: confirmPassword) { _ in
                confirmPasswordError = nil
                authService.clearError()
            }
            
            // Password Requirements
            passwordRequirementsSection
            
            // Terms and Conditions
            termsSection
        }
    }
    
    // MARK: - Professional Tips Section
    private var professionalTipsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Constants.Colors.warning)
                Text("Professional Tips")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                tipRow(icon: "checkmark.circle.fill", text: "Use your real name for better networking")
                tipRow(icon: "checkmark.circle.fill", text: "Professional email addresses work best")
                tipRow(icon: "checkmark.circle.fill", text: "Complete profile increases connections by 40%")
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.lightBlue.opacity(0.3))
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    // MARK: - Password Requirements Section
    private var passwordRequirementsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                Image(systemName: "shield.fill")
                    .foregroundColor(Constants.Colors.success)
                Text("Password Requirements")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                requirementRow(text: "At least 6 characters", isMet: password.count >= 6)
                requirementRow(text: "Contains uppercase letter", isMet: password.range(of: "[A-Z]", options: .regularExpression) != nil)
                requirementRow(text: "Contains lowercase letter", isMet: password.range(of: "[a-z]", options: .regularExpression) != nil)
                requirementRow(text: "Passwords match", isMet: !password.isEmpty && password == confirmPassword)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.lightGray.opacity(0.3))
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    // MARK: - Terms Section
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack(alignment: .top, spacing: Constants.Spacing.sm) {
                Button(action: { agreedToTerms.toggle() }) {
                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                        .foregroundColor(agreedToTerms ? Constants.Colors.primaryBlue : Constants.Colors.border)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text("I agree to the Terms of Service and Privacy Policy")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                    
                    HStack {
                        Button("Terms of Service") {
                            // Handle terms tap
                        }
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.primaryBlue)
                        
                        Text("•")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        Button("Privacy Policy") {
                            // Handle privacy policy tap
                        }
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
            }
            
            if let termsError = termsError {
                Text(termsError)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.error)
                    .padding(.leading, Constants.Spacing.xl)
            }
        }
        .onChange(of: agreedToTerms) { _ in
            termsError = nil
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Error Message
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.error)
                    .padding(.horizontal, Constants.Spacing.md)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: Constants.Spacing.md) {
                // Back Button
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(Constants.Animation.medium) {
                            currentStep -= 1
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Constants.Colors.secondaryBackground)
                    .foregroundColor(Constants.Colors.label)
                    .cornerRadius(Constants.CornerRadius.large)
                }
                
                // Next/Create Button
                Button(action: handleNextAction) {
                    HStack {
                        if authService.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(currentStep == totalSteps - 1 ? "Create Account" : "Next")
                                .font(Constants.Fonts.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(canProceed ? Constants.Colors.primaryBlue : Constants.Colors.border)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.CornerRadius.large)
                }
                .disabled(!canProceed || authService.isLoading)
                .scaleEffect(authService.isLoading ? 0.95 : 1.0)
                .animation(Constants.Animation.quick, value: authService.isLoading)
            }
        }
        .padding(.top, Constants.Spacing.lg)
    }
    
    // MARK: - Helper Views
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: icon)
                .foregroundColor(Constants.Colors.success)
                .font(.caption)
            Text(text)
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.label)
            Spacer()
        }
    }
    
    private func requirementRow(text: String, isMet: Bool) -> some View {
        HStack(spacing: Constants.Spacing.sm) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? Constants.Colors.success : Constants.Colors.border)
                .font(.caption)
            Text(text)
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.label)
                .strikethrough(isMet)
            Spacer()
        }
        .animation(Constants.Animation.quick, value: isMet)
    }
    
    // MARK: - Computed Properties
    private var canProceed: Bool {
        if currentStep == 0 {
            return !fullName.isEmpty && !email.isEmpty
        } else {
            return !password.isEmpty && !confirmPassword.isEmpty && agreedToTerms && password == confirmPassword && password.count >= 6
        }
    }
    
    // MARK: - Actions
    private func handleNextAction() {
        if currentStep == 0 {
            // Validate first step
            if let nameError = authService.validateFullName(fullName) {
                fullNameError = nameError
                return
            }
            
            if let emailValidation = authService.validateEmail(email) {
                emailError = emailValidation
                return
            }
            
            // Clear errors and move to next step
            fullNameError = nil
            emailError = nil
            
            withAnimation(Constants.Animation.medium) {
                currentStep += 1
            }
        } else {
            // Validate final step and create account
            handleSignup()
        }
    }
    
    private func handleSignup() {
        // Validate password
        if let passwordValidation = authService.validatePassword(password) {
            passwordError = passwordValidation
            return
        }
        
        // Validate confirm password
        if let confirmValidation = authService.validateConfirmPassword(password, confirmPassword) {
            confirmPasswordError = confirmValidation
            return
        }
        
        // Validate terms agreement
        if !agreedToTerms {
            termsError = "Please agree to the Terms of Service and Privacy Policy"
            return
        }
        
        // Clear errors
        passwordError = nil
        confirmPasswordError = nil
        termsError = nil
        
        // Hide keyboard
        hideKeyboard()
        
        // Create account
        authService.signUp(email: email, password: password, fullName: fullName)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupView()
} 