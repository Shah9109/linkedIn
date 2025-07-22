import SwiftUI

struct ConnectionRequestView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User
    let connectionService: ConnectionService
    
    @State private var message = ""
    @State private var selectedTemplate = 0
    @State private var isLoading = false
    
    private let messageTemplates = [
        "Hi [Name], I'd like to connect with you on ProNet.",
        "Hi [Name], I came across your profile and would love to connect. We seem to have similar professional interests.",
        "Hi [Name], I noticed we work in similar fields. I'd love to connect and potentially collaborate.",
        "Hi [Name], I'd like to add you to my professional network on ProNet."
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    // User Profile Section
                    userProfileSection
                    
                    // Message Templates
                    messageTemplatesSection
                    
                    // Custom Message
                    customMessageSection
                    
                    // Character Count
                    characterCountSection
                    
                    Spacer(minLength: Constants.Spacing.xl)
                }
                .padding(.horizontal, Constants.Spacing.lg)
                .padding(.top, Constants.Spacing.lg)
            }
            .background(Constants.Colors.background)
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: sendConnectionRequest) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primaryBlue))
                                .scaleEffect(0.8)
                        } else {
                            Text("Send")
                                .fontWeight(.semibold)
                                .foregroundColor(message.isEmpty ? Constants.Colors.border : Constants.Colors.primaryBlue)
                        }
                    }
                    .disabled(message.isEmpty || isLoading)
                }
            }
        }
    }
    
    // MARK: - User Profile Section
    private var userProfileSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Profile Image
            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .overlay(
                        Text(user.fullName.initials)
                            .font(Constants.Fonts.title1)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(spacing: Constants.Spacing.xs) {
                Text(user.fullName)
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                if let headline = user.headline {
                    Text(headline)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .multilineTextAlignment(.center)
                }
                
                if let location = user.location {
                    HStack {
                        Image(systemName: "location")
                            .font(.caption)
                        Text(location)
                            .font(Constants.Fonts.body)
                    }
                    .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
            
            // Connection Info
            VStack(spacing: Constants.Spacing.xs) {
                Text("Connect with \(user.fullName.components(separatedBy: " ").first ?? user.fullName)")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Add a personal note to your invitation")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Constants.Spacing.lg)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Message Templates Section
    private var messageTemplatesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Quick Templates")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(0..<messageTemplates.count, id: \.self) { index in
                    templateRow(index: index)
                }
            }
        }
    }
    
    private func templateRow(index: Int) -> some View {
        Button(action: {
            selectedTemplate = index
            message = messageTemplates[index].replacingOccurrences(of: "[Name]", with: user.fullName.components(separatedBy: " ").first ?? user.fullName)
        }) {
            HStack {
                VStack {
                    Circle()
                        .fill(selectedTemplate == index ? Constants.Colors.primaryBlue : Constants.Colors.border)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                                .opacity(selectedTemplate == index ? 1 : 0)
                        )
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(messageTemplates[index].replacingOccurrences(of: "[Name]", with: user.fullName.components(separatedBy: " ").first ?? user.fullName))
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(messageTemplates[index].replacingOccurrences(of: "[Name]", with: user.fullName.components(separatedBy: " ").first ?? user.fullName).count) characters")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Constants.Spacing.md)
            .background(selectedTemplate == index ? Constants.Colors.lightBlue.opacity(0.3) : Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(selectedTemplate == index ? Constants.Colors.primaryBlue : Constants.Colors.border, lineWidth: selectedTemplate == index ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Custom Message Section
    private var customMessageSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Personal Message")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            TextEditor(text: $message)
                .font(Constants.Fonts.body)
                .padding(Constants.Spacing.sm)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                        .stroke(Constants.Colors.border, lineWidth: 1)
                )
                .frame(minHeight: 100)
                .onChange(of: message) { _ in
                    // Reset template selection if message is manually edited
                    if !messageTemplates.contains(where: { template in
                        template.replacingOccurrences(of: "[Name]", with: user.fullName.components(separatedBy: " ").first ?? user.fullName) == message
                    }) {
                        selectedTemplate = -1
                    }
                }
            
            // Tips
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text("Tips for a great connection request:")
                    .font(Constants.Fonts.caption1)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                tipRow(text: "Mention how you found their profile")
                tipRow(text: "Explain why you'd like to connect")
                tipRow(text: "Keep it professional and friendly")
                tipRow(text: "Personalize the message when possible")
            }
            .padding(Constants.Spacing.md)
            .background(Constants.Colors.lightBlue.opacity(0.2))
            .cornerRadius(Constants.CornerRadius.medium)
        }
    }
    
    private func tipRow(text: String) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.xs) {
            Text("•")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.primaryBlue)
            Text(text)
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.secondaryLabel)
            Spacer()
        }
    }
    
    // MARK: - Character Count Section
    private var characterCountSection: some View {
        HStack {
            Spacer()
            Text("\(message.count)/300")
                .font(Constants.Fonts.caption1)
                .foregroundColor(message.count > 300 ? Constants.Colors.error : Constants.Colors.secondaryLabel)
        }
    }
    
    // MARK: - Actions
    private func sendConnectionRequest() {
        guard !message.isEmpty && message.count <= 300 else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            connectionService.sendConnectionRequest(to: user, message: message)
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    ConnectionRequestView(
        user: User(email: "test@example.com", fullName: "John Doe"),
        connectionService: ConnectionService()
    )
} 