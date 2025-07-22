import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService()
    
    @State private var email = ""
    @State private var emailError: String?
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: Constants.Spacing.xl) {
                // Header
                VStack(spacing: Constants.Spacing.lg) {
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .scaleEffect(showSuccessMessage ? 1.2 : 1.0)
                        .animation(Constants.Animation.spring, value: showSuccessMessage)
                    
                    VStack(spacing: Constants.Spacing.sm) {
                        Text("Forgot Password?")
                            .font(Constants.Fonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.label)
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.Spacing.md)
                    }
                }
                .padding(.top, Constants.Spacing.xxl)
                
                if showSuccessMessage {
                    // Success Message
                    successSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                } else {
                    // Email Form
                    emailFormSection
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .background(Constants.Colors.background)
            .navigationTitle("Reset Password")
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
    
    // MARK: - Email Form Section
    private var emailFormSection: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Email Field
            CustomTextField(
                text: $email,
                placeholder: "Enter your email address",
                keyboardType: .emailAddress,
                icon: "envelope.fill",
                errorMessage: emailError
            )
            .onChange(of: email) { _ in
                emailError = nil
                authService.clearError()
            }
            
            // Error Message
            if !authService.errorMessage.isEmpty {
                Text(authService.errorMessage)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.error)
                    .padding(.horizontal, Constants.Spacing.md)
                    .multilineTextAlignment(.center)
            }
            
            // Send Reset Email Button
            Button(action: handlePasswordReset) {
                HStack {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(email.isEmpty ? Constants.Colors.border : Constants.Colors.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(Constants.CornerRadius.large)
                .scaleEffect(authService.isLoading ? 0.95 : 1.0)
                .animation(Constants.Animation.quick, value: authService.isLoading)
            }
            .disabled(email.isEmpty || authService.isLoading)
            
            // Help Text
            VStack(spacing: Constants.Spacing.sm) {
                Text("Didn't receive the email?")
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                Button("Check your spam folder or try again") {
                    // Could add resend functionality here
                }
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            .padding(.top, Constants.Spacing.md)
        }
    }
    
    // MARK: - Success Section
    private var successSection: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.success)
                .scaleEffect(1.0)
                .animation(Constants.Animation.bouncy.delay(0.2), value: showSuccessMessage)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text("Email Sent!")
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("We've sent a password reset link to:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                Text(email)
                    .font(Constants.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.sm)
                    .background(Constants.Colors.lightBlue.opacity(0.3))
                    .cornerRadius(Constants.CornerRadius.medium)
            }
            .multilineTextAlignment(.center)
            
            // Instructions
            VStack(spacing: Constants.Spacing.sm) {
                Text("What's next?")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    instructionRow(number: "1", text: "Check your email inbox")
                    instructionRow(number: "2", text: "Click the reset link in the email")
                    instructionRow(number: "3", text: "Create a new password")
                    instructionRow(number: "4", text: "Sign in with your new password")
                }
            }
            .padding(.top, Constants.Spacing.md)
            
            // Done Button
            Button("Done") {
                dismiss()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Constants.Colors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(Constants.CornerRadius.large)
            .padding(.top, Constants.Spacing.lg)
        }
    }
    
    // MARK: - Helper Views
    private func instructionRow(number: String, text: String) -> some View {
        HStack(spacing: Constants.Spacing.sm) {
            Text(number)
                .font(Constants.Fonts.caption1)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Constants.Colors.primaryBlue)
                .cornerRadius(10)
            
            Text(text)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.label)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    private func handlePasswordReset() {
        // Validate email
        if let emailValidation = authService.validateEmail(email) {
            emailError = emailValidation
            return
        }
        
        // Clear error
        emailError = nil
        
        // Hide keyboard
        hideKeyboard()
        
        // Send reset email
        authService.resetPassword(email: email)
        
        // Simulate success for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(Constants.Animation.medium) {
                showSuccessMessage = true
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ForgotPasswordView()
} 