import SwiftUI
import PhotosUI

// MARK: - Supporting Models
struct HashtagSuggestion: Identifiable, Hashable {
    let id = UUID()
    let tag: String
    let count: Int
}

struct PostCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var postService = PostService()
    @StateObject private var authService = AuthService()
    
    @State private var postText = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var isLoading = false
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var showPollCreator = false
    @State private var showDocumentPicker = false
    @State private var postVisibility = PostVisibility.public
    @State private var addHashtags = true
    @State private var showEmojiPicker = false
    @State private var selectedTemplate: PostTemplate? = nil
    @State private var showTemplates = false
    @State private var pollOptions: [String] = ["", ""]
    @State private var pollDuration = 7 // days
    
    private let maxImages = 4
    private let maxCharacters = 3000
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Header
                headerSection
                
                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // User Profile Section with enhanced design
                        userProfileSection
                        
                        // Template Selection
                        if showTemplates {
                            templateSelectionSection
                        }
                        
                        // Text Input with rich formatting
                        textInputSection
                        
                        // Media Section
                        if !loadedImages.isEmpty {
                            mediaSection
                        }
                        
                        // Poll Section
                        if showPollCreator {
                            pollSection
                        }
                        
                        // Enhanced Hashtag Suggestions
                        if addHashtags && !extractedHashtags.isEmpty {
                            hashtagSuggestions
                        }
                        
                        // Professional Features
                        professionalFeaturesSection
                        
                        // Post Options with more controls
                        postOptionsSection
                        
                        Spacer(minLength: Constants.Spacing.xl)
                    }
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.top, Constants.Spacing.sm)
                }
            }
            .background(Constants.Colors.professionalGray)
            .navigationBarHidden(true)
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedImages, maxSelectionCount: maxImages, matching: .images)
        .onChange(of: selectedImages) { items in
            loadSelectedImages(items)
        }
    }
    
    // MARK: - Enhanced Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Constants.Colors.secondaryLabel)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text("Create Post")
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text("Share with your network")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Spacer()
                
                Button(action: createPost) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Post")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 70, height: 36)
                .background(canPost ? Constants.Colors.primaryBlue : Constants.Colors.border)
                .cornerRadius(Constants.CornerRadius.large)
                .disabled(!canPost || isLoading)
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.md)
            .background(Constants.Colors.background)
            
            Rectangle()
                .fill(Constants.Colors.border.opacity(0.3))
                .frame(height: 0.5)
        }
    }
    
    // MARK: - Enhanced User Profile Section
    private var userProfileSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack(spacing: Constants.Spacing.md) {
                // Profile Image with ring
                ZStack {
                    Circle()
                        .stroke(Constants.Colors.primaryGradient, lineWidth: 2)
                        .frame(width: 56, height: 56)
                    
                    AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? Constants.Images.defaultProfileMale)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(authService.currentUser?.fullName.initials ?? "")
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authService.currentUser?.fullName ?? "User")
                        .font(Constants.Fonts.professionalHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    // Enhanced Visibility Picker
                    Menu {
                        ForEach(PostVisibility.allCases, id: \.self) { visibility in
                            Button(action: { postVisibility = visibility }) {
                                HStack {
                                    Image(systemName: visibility.icon)
                                    Text(visibility.title)
                                    Text("• \(visibility.subtitle)")
                                        .foregroundColor(Constants.Colors.secondaryLabel)
                                    if postVisibility == visibility {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: Constants.Spacing.xs) {
                            Image(systemName: postVisibility.icon)
                                .font(.caption)
                            Text(postVisibility.title)
                                .font(Constants.Fonts.body)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundColor(Constants.Colors.primaryBlue)
                        .padding(.horizontal, Constants.Spacing.sm)
                        .padding(.vertical, Constants.Spacing.xs)
                        .background(Constants.Colors.lightBlue.opacity(0.2))
                        .cornerRadius(Constants.CornerRadius.pill)
                    }
                }
                
                Spacer()
                
                // Template button
                Button(action: { showTemplates.toggle() }) {
                    Image(systemName: showTemplates ? "text.badge.checkmark" : "text.badge.plus")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Template Selection Section
    private var templateSelectionSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Choose a Template")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button("Clear") {
                    selectedTemplate = nil
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.md) {
                    ForEach(PostTemplate.allTemplates, id: \.id) { template in
                        templateCard(template)
                    }
                }
                .padding(.horizontal, Constants.Spacing.sm)
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Enhanced Text Input Section
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            // Text editor with placeholder
            ZStack(alignment: .topLeading) {
                TextEditor(text: $postText)
                    .font(Constants.Fonts.professionalBody)
                    .foregroundColor(Constants.Colors.label)
                    .background(Constants.Colors.background)
                    .frame(minHeight: selectedTemplate != nil ? 180 : 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                            .stroke(Constants.Colors.border.opacity(0.5), lineWidth: 1)
                    )
                
                if postText.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                        Text(selectedTemplate?.placeholder ?? "What would you like to share?")
                            .font(Constants.Fonts.professionalBody)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        if selectedTemplate == nil {
                            Text("Share insights, ask questions, or celebrate achievements...")
                                .font(Constants.Fonts.body)
                                .foregroundColor(Constants.Colors.tertiaryLabel)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
                }
            }
            .cornerRadius(Constants.CornerRadius.medium)
            
            // Enhanced character count and stats
            HStack {
                if selectedTemplate != nil {
                    HStack(spacing: Constants.Spacing.xs) {
                        Image(systemName: selectedTemplate!.icon)
                            .font(.caption)
                        Text(selectedTemplate!.category)
                            .font(Constants.Fonts.caption1)
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .padding(.horizontal, Constants.Spacing.sm)
                    .padding(.vertical, Constants.Spacing.xs)
                    .background(Constants.Colors.lightBlue.opacity(0.2))
                    .cornerRadius(Constants.CornerRadius.small)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(postText.count)/\(maxCharacters)")
                        .font(Constants.Fonts.caption2)
                        .foregroundColor(postText.count > maxCharacters ? Constants.Colors.error : Constants.Colors.secondaryLabel)
                    
                    if !postText.isEmpty {
                        Text("~\(estimatedReadTime) min read")
                            .font(Constants.Fonts.caption2)
                            .foregroundColor(Constants.Colors.tertiaryLabel)
                    }
                }
            }
            
            // Enhanced Quick Actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Spacing.lg) {
                    quickActionButton(icon: "camera.fill", text: "Photo", color: Constants.Colors.commentBlue) {
                        showImagePicker = true
                    }
                    
                    quickActionButton(icon: "video.fill", text: "Video", color: Constants.Colors.shareGreen) {
                        showVideoPicker = true
                    }
                    
                    quickActionButton(icon: "chart.bar.fill", text: "Poll", color: Constants.Colors.warning) {
                        showPollCreator.toggle()
                    }
                    
                    quickActionButton(icon: "doc.fill", text: "Document", color: Constants.Colors.sendPurple) {
                        showDocumentPicker = true
                    }
                    
                    quickActionButton(icon: "calendar", text: "Event", color: Constants.Colors.likeRed) {
                        // Handle event creation
                    }
                    
                    quickActionButton(icon: "face.smiling", text: "Emoji", color: Constants.Colors.premiumGold) {
                        showEmojiPicker.toggle()
                    }
                }
                .padding(.horizontal, Constants.Spacing.sm)
            }
            
            if showEmojiPicker {
                emojiPickerSection
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Enhanced Media Section
    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Media (\(loadedImages.count)/\(maxImages))")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                if loadedImages.count < maxImages {
                    Button("Add More") {
                        showImagePicker = true
                    }
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Constants.Spacing.sm), count: loadedImages.count == 1 ? 1 : 2), spacing: Constants.Spacing.sm) {
                ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: loadedImages.count == 1 ? 250 : 150)
                            .cornerRadius(Constants.CornerRadius.medium)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                    .stroke(.white, lineWidth: 2)
                            )
                        
                        Button(action: { removeImage(at: index) }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .background(Circle().fill(.black.opacity(0.6)))
                        }
                        .padding(Constants.Spacing.sm)
                    }
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Poll Section
    private var pollSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Create Poll")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button("Remove") {
                    showPollCreator = false
                    pollOptions = ["", ""]
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.error)
            }
            
            VStack(spacing: Constants.Spacing.sm) {
                ForEach(Array(pollOptions.enumerated()), id: \.offset) { index, option in
                    HStack {
                        TextField("Option \(index + 1)", text: $pollOptions[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if pollOptions.count > 2 {
                            Button(action: { pollOptions.remove(at: index) }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(Constants.Colors.error)
                            }
                        }
                    }
                }
                
                if pollOptions.count < 4 {
                    Button("Add Option") {
                        pollOptions.append("")
                    }
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            
            HStack {
                Text("Poll Duration:")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                
                Picker("Duration", selection: $pollDuration) {
                    Text("1 day").tag(1)
                    Text("3 days").tag(3)
                    Text("1 week").tag(7)
                    Text("2 weeks").tag(14)
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(Constants.Colors.primaryBlue)
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Professional Features Section
    private var professionalFeaturesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Professional Features")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.sm) {
                professionalFeatureRow(
                    icon: "briefcase.fill",
                    title: "Mark as Professional Milestone",
                    subtitle: "Highlight career achievements",
                    isOn: .constant(false)
                )
                
                professionalFeatureRow(
                    icon: "eye.fill",
                    title: "Request Recommendations",
                    subtitle: "Ask connections for endorsements",
                    isOn: .constant(false)
                )
                
                professionalFeatureRow(
                    icon: "person.2.fill",
                    title: "Looking for Opportunities",
                    subtitle: "Signal you're open to offers",
                    isOn: .constant(false)
                )
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Enhanced Hashtag Suggestions
    private var hashtagSuggestions: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Trending Hashtags")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.sm) {
                ForEach(extractedHashtags, id: \.self) { hashtag in
                    Button(action: { addHashtagToText(hashtag.tag) }) {
                        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                            HStack {
                                Text(hashtag.tag)
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                                
                                Spacer()
                                
                                Text("\(hashtag.count)K")
                                    .font(Constants.Fonts.caption2)
                                    .foregroundColor(Constants.Colors.secondaryLabel)
                            }
                            
                            Text("posts this week")
                                .font(Constants.Fonts.caption1)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.primaryBlue.opacity(0.05))
                        .cornerRadius(Constants.CornerRadius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                                .stroke(Constants.Colors.primaryBlue.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Enhanced Post Options Section
    private var postOptionsSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            VStack(spacing: Constants.Spacing.sm) {
                optionRow(
                    icon: "number",
                    title: "Add hashtags automatically",
                    subtitle: "AI will suggest relevant hashtags",
                    isOn: $addHashtags
                )
                
                optionRow(
                    icon: "bell.badge",
                    title: "Notify followers",
                    subtitle: "Send push notifications to followers",
                    isOn: .constant(true)
                )
                
                optionRow(
                    icon: "link",
                    title: "Allow sharing",
                    subtitle: "Others can repost your content",
                    isOn: .constant(true)
                )
                
                optionRow(
                    icon: "message.badge",
                    title: "Allow comments",
                    subtitle: "People can comment on your post",
                    isOn: .constant(true)
                )
            }
        }
        .padding(Constants.Spacing.cardPadding)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
    }
    
    // MARK: - Helper Views
    private func templateCard(_ template: PostTemplate) -> some View {
        Button(action: { 
            selectedTemplate = template
            postText = template.defaultContent
        }) {
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                HStack {
                    Image(systemName: template.icon)
                        .font(.title3)
                        .foregroundColor(template.color)
                    
                    Spacer()
                    
                    if selectedTemplate?.id == template.id {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundColor(Constants.Colors.success)
                    }
                }
                
                Text(template.title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                    .multilineTextAlignment(.leading)
                
                Text(template.description)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(width: 160, height: 120)
            .padding(Constants.Spacing.md)
            .background(selectedTemplate?.id == template.id ? Constants.Colors.lightBlue.opacity(0.1) : Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                    .stroke(selectedTemplate?.id == template.id ? Constants.Colors.primaryBlue : Constants.Colors.border.opacity(0.3), lineWidth: selectedTemplate?.id == template.id ? 2 : 1)
            )
        }
    }
    
    private func professionalFeatureRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Constants.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                
                Text(subtitle)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
    
    private func quickActionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(text)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.label)
            }
            .frame(width: 80, height: 60)
            .background(color.opacity(0.1))
            .cornerRadius(Constants.CornerRadius.medium)
        }
    }
    
    private func optionRow(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: Constants.Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                
                Text(subtitle)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, Constants.Spacing.xs)
    }
    
    // MARK: - Enhanced Emoji Picker Section
    private var emojiPickerSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Frequently Used")
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: Constants.Spacing.sm) {
                ForEach(frequentlyUsedEmojis, id: \.self) { emoji in
                    Button(action: { addEmojiToText(emoji) }) {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Constants.Colors.secondaryBackground)
                            .cornerRadius(Constants.CornerRadius.medium)
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.lightBlue.opacity(0.05))
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    // MARK: - Computed Properties
    private var canPost: Bool {
        !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
        postText.count <= maxCharacters && 
        !isLoading
    }
    
    private var extractedHashtags: [HashtagSuggestion] {
        let suggested = [
            HashtagSuggestion(tag: "#ProNet", count: 45),
            HashtagSuggestion(tag: "#Professional", count: 125),
            HashtagSuggestion(tag: "#Networking", count: 87),
            HashtagSuggestion(tag: "#Career", count: 203),
            HashtagSuggestion(tag: "#Technology", count: 156),
            HashtagSuggestion(tag: "#Innovation", count: 98),
            HashtagSuggestion(tag: "#Leadership", count: 67),
            HashtagSuggestion(tag: "#Growth", count: 134),
            HashtagSuggestion(tag: "#Success", count: 89)
        ]
        return suggested.filter { hashtag in
            !postText.contains(hashtag.tag)
        }
    }
    
    private var estimatedReadTime: Int {
        max(1, postText.components(separatedBy: .whitespacesAndNewlines).count / 200)
    }
    
    private var frequentlyUsedEmojis: [String] {
        ["🚀", "💡", "🎉", "👏", "💪", "🌟", "🔥", "✨", "📈", "🎯", "💯", "🙌", "👍", "❤️", "😊", "🤝"]
    }
    
    // MARK: - Actions
    private func createPost() {
        guard canPost else { return }
        
        isLoading = true
        
        // Enhanced post creation with more features
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let imageURLs = loadedImages.map { _ in 
                // Use professional images from Constants
                [Constants.Images.businessMeeting, Constants.Images.teamWork, 
                 Constants.Images.conference, Constants.Images.startup,
                 Constants.Images.technology, Constants.Images.office].randomElement() ?? Constants.Images.businessMeeting
            }
            
            postService.createPost(content: postText, imageURLs: imageURLs)
            isLoading = false
            dismiss()
        }
    }
    
    private func loadSelectedImages(_ items: [PhotosPickerItem]) {
        Task {
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if loadedImages.count < maxImages {
                            loadedImages.append(image)
                        }
                    }
                }
            }
        }
    }
    
    private func removeImage(at index: Int) {
        withAnimation(Constants.Animation.professional) {
            loadedImages.remove(at: index)
        }
    }
    
    private func addHashtagToText(_ hashtag: String) {
        if !postText.contains(hashtag) {
            if !postText.isEmpty && !postText.hasSuffix(" ") {
                postText += " "
            }
            postText += hashtag + " "
        }
    }
    
    private func addEmojiToText(_ emoji: String) {
        postText += emoji
    }
}

// MARK: - Enhanced Post Visibility Enum
enum PostVisibility: String, CaseIterable {
    case `public` = "public"
    case connections = "connections"
    case connectionsOnly = "connections_only"
    
    var title: String {
        switch self {
        case .public:
            return "Anyone"
        case .connections:
            return "Connections"
        case .connectionsOnly:
            return "Connections only"
        }
    }
    
    var subtitle: String {
        switch self {
        case .public:
            return "Visible to everyone on and off ProNet"
        case .connections:
            return "Visible to your connections"
        case .connectionsOnly:
            return "Only connections can see and share"
        }
    }
    
    var icon: String {
        switch self {
        case .public:
            return "globe"
        case .connections:
            return "person.2"
        case .connectionsOnly:
            return "lock"
        }
    }
}

// MARK: - Post Template Model
struct PostTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let category: String
    let placeholder: String
    let defaultContent: String
    
    static let allTemplates: [PostTemplate] = [
        PostTemplate(
            title: "Achievement",
            description: "Share your latest accomplishment",
            icon: "trophy.fill",
            color: Constants.Colors.premiumGold,
            category: "Milestone",
            placeholder: "I'm excited to share that...",
            defaultContent: "I'm excited to share that I've reached a significant milestone! "
        ),
        PostTemplate(
            title: "Insight",
            description: "Share professional wisdom",
            icon: "lightbulb.fill",
            color: Constants.Colors.shareGreen,
            category: "Knowledge",
            placeholder: "Here's what I've learned...",
            defaultContent: "Here's an insight from my professional journey: "
        ),
        PostTemplate(
            title: "Question",
            description: "Ask your network for advice",
            icon: "questionmark.circle.fill",
            color: Constants.Colors.commentBlue,
            category: "Discussion",
            placeholder: "I'd love to hear your thoughts on...",
            defaultContent: "I'd love to hear your thoughts on "
        ),
        PostTemplate(
            title: "Team Update",
            description: "Celebrate your team's success",
            icon: "person.3.fill",
            color: Constants.Colors.sendPurple,
            category: "Team",
            placeholder: "Proud to share that our team...",
            defaultContent: "Proud to share that our team has "
        ),
        PostTemplate(
            title: "Industry News",
            description: "Comment on industry trends",
            icon: "newspaper.fill",
            color: Constants.Colors.likeRed,
            category: "News",
            placeholder: "Thoughts on the latest industry development...",
            defaultContent: "Thoughts on the latest industry development: "
        ),
        PostTemplate(
            title: "Gratitude",
            description: "Thank someone or celebrate",
            icon: "heart.fill",
            color: Constants.Colors.warning,
            category: "Personal",
            placeholder: "I want to thank...",
            defaultContent: "I want to take a moment to thank "
        )
    ]
}

#Preview {
    PostCreationView()
        .environmentObject(AuthService())
} 