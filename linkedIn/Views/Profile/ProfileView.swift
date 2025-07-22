import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var postService = PostService()
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var selectedTab = 0
    @State private var showImagePicker = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: UIImage?
    
    private let tabs = ["Posts", "About", "Activity"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Profile Info Section
                    profileInfoSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Tabs Section
                    tabsSection
                    
                    // Content Section
                    contentSection
                }
            }
            .background(Constants.Colors.background)
            .navigationBarHidden(true)
            .refreshable {
                await refreshProfile()
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedImage, matching: .images)
        .onChange(of: selectedImage) { item in
            loadProfileImage(item)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            // Background Cover
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.Colors.primaryBlue,
                    Constants.Colors.accent
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            
            // Settings Button
            HStack {
                Spacer()
                
                VStack {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(Circle().fill(.black.opacity(0.3)).frame(width: 32, height: 32))
                    }
                    
                    Spacer()
                }
                .padding(.top, Constants.Spacing.md)
                .padding(.trailing, Constants.Spacing.md)
            }
            .frame(height: 120)
        }
    }
    
    // MARK: - Profile Info Section
    private var profileInfoSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Profile Image
            ZStack(alignment: .bottomTrailing) {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 4)
                        )
                } else {
                    AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(authService.currentUser?.fullName.initials ?? "")
                                    .font(Constants.Fonts.title1)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 4)
                    )
                }
                
                Button(action: { showImagePicker = true }) {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Constants.Colors.primaryBlue)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        )
                }
            }
            .offset(y: -60)
            
            VStack(spacing: Constants.Spacing.sm) {
                // Name and Headline
                VStack(spacing: Constants.Spacing.xs) {
                    Text(authService.currentUser?.fullName ?? "User Name")
                        .font(Constants.Fonts.title1)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let headline = authService.currentUser?.headline, !headline.isEmpty {
                        Text(headline)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .multilineTextAlignment(.center)
                    }
                    
                    if let location = authService.currentUser?.location, !location.isEmpty {
                        HStack {
                            Image(systemName: "location")
                                .font(.caption)
                            Text(location)
                                .font(Constants.Fonts.body)
                        }
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                // Connection Stats
                HStack(spacing: Constants.Spacing.lg) {
                    statView(number: "\(authService.currentUser?.connections.count ?? 0)", label: "Connections")
                    statView(number: "2.5K", label: "Followers")
                    statView(number: "15", label: "Posts")
                }
                .padding(.top, Constants.Spacing.sm)
            }
            .offset(y: -40)
        }
        .padding(.horizontal, Constants.Spacing.md)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: Constants.Spacing.md) {
            Button(action: { showEditProfile = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Constants.Colors.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(Constants.CornerRadius.large)
            }
            
            Button(action: { /* Share profile */ }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Constants.Colors.secondaryBackground)
                    .foregroundColor(Constants.Colors.label)
                    .cornerRadius(Constants.CornerRadius.large)
            }
            
            Button(action: { /* More options */ }) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(Constants.Colors.secondaryBackground)
                    .foregroundColor(Constants.Colors.label)
                    .cornerRadius(Constants.CornerRadius.large)
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .offset(y: -20)
    }
    
    // MARK: - Tabs Section
    private var tabsSection: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: { selectedTab = index }) {
                        VStack(spacing: Constants.Spacing.xs) {
                            Text(tabs[index])
                                .font(Constants.Fonts.body)
                                .fontWeight(selectedTab == index ? .semibold : .regular)
                                .foregroundColor(selectedTab == index ? Constants.Colors.primaryBlue : Constants.Colors.secondaryLabel)
                            
                            if selectedTab == index {
                                Rectangle()
                                    .fill(Constants.Colors.primaryBlue)
                                    .frame(height: 2)
                            } else {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            
            Divider()
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            switch selectedTab {
            case 0:
                postsView
            case 1:
                aboutView
            case 2:
                activityView
            default:
                EmptyView()
            }
        }
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Posts View
    private var postsView: some View {
        LazyVStack(spacing: Constants.Spacing.md) {
            if userPosts.isEmpty {
                emptyPostsView
            } else {
                ForEach(userPosts, id: \.id) { post in
                    PostCardView(post: post, postService: postService)
                        .padding(.horizontal, Constants.Spacing.md)
                }
            }
        }
    }
    
    // MARK: - About View
    private var aboutView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            // Bio Section
            if let bio = authService.currentUser?.bio, !bio.isEmpty {
                profileSection(title: "About", content: {
                    Text(bio)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                })
            }
            
            // Experience Section
            if !(authService.currentUser?.experience.isEmpty ?? true) {
                profileSection(title: "Experience", content: {
                    ForEach(authService.currentUser?.experience ?? [], id: \.id) { experience in
                        experienceRow(experience)
                    }
                })
            }
            
            // Education Section
            if !(authService.currentUser?.education.isEmpty ?? true) {
                profileSection(title: "Education", content: {
                    ForEach(authService.currentUser?.education ?? [], id: \.id) { education in
                        educationRow(education)
                    }
                })
            }
            
            // Skills Section
            if !(authService.currentUser?.skills.isEmpty ?? true) {
                profileSection(title: "Skills", content: {
                    skillsGrid
                })
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
    }
    
    // MARK: - Activity View
    private var activityView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            activitySection(title: "Recent Activity", items: [
                "Liked 3 posts",
                "Commented on 2 posts",
                "Connected with 1 new person",
                "Updated profile"
            ])
            
            activitySection(title: "Profile Views", items: [
                "25 profile views this week",
                "12 search appearances",
                "5 post views"
            ])
        }
        .padding(.horizontal, Constants.Spacing.md)
    }
    
    // MARK: - Helper Views
    private func statView(number: String, label: String) -> some View {
        VStack(spacing: Constants.Spacing.xs) {
            Text(number)
                .font(Constants.Fonts.headline)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.label)
            
            Text(label)
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.secondaryLabel)
        }
    }
    
    private func profileSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text(title)
                    .font(Constants.Fonts.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button("Edit") {
                    showEditProfile = true
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            content()
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func experienceRow(_ experience: Experience) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            Image(systemName: "building.2")
                .font(.title3)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(experience.title)
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(experience.company)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                Text(formatDateRange(start: experience.startDate, end: experience.endDate, isCurrent: experience.isCurrentRole))
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                if let description = experience.description, !description.isEmpty {
                    Text(description)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                        .padding(.top, Constants.Spacing.xs)
                }
            }
            
            Spacer()
        }
    }
    
    private func educationRow(_ education: Education) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            Image(systemName: "graduationcap")
                .font(.title3)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(education.institution)
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(education.degree)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                if let fieldOfStudy = education.fieldOfStudy {
                    Text(fieldOfStudy)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Text(formatDateRange(start: education.startDate, end: education.endDate))
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
        }
    }
    
    private var skillsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.sm) {
            ForEach(authService.currentUser?.skills ?? [], id: \.self) { skill in
                Text(skill)
                    .font(Constants.Fonts.body)
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.sm)
                    .background(Constants.Colors.lightBlue.opacity(0.3))
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.CornerRadius.large)
            }
        }
    }
    
    private func activitySection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text(title)
                .font(Constants.Fonts.title3)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack {
                        Circle()
                            .fill(Constants.Colors.primaryBlue)
                            .frame(width: 6, height: 6)
                        
                        Text(item)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var emptyPostsView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "doc.text")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text("No posts yet")
                    .font(Constants.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Share your thoughts and insights with your network.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create Your First Post") {
                // Navigate to post creation
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.vertical, Constants.Spacing.sm)
            .background(Constants.Colors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(Constants.CornerRadius.large)
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.top, Constants.Spacing.xl)
    }
    
    // MARK: - Computed Properties
    private var userPosts: [Post] {
        postService.posts.filter { $0.authorId == authService.currentUser?.id }
    }
    
    // MARK: - Helper Methods
    private func formatDateRange(start: Date, end: Date? = nil, isCurrent: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let startString = formatter.string(from: start)
        
        if isCurrent {
            return "\(startString) - Present"
        } else if let end = end {
            let endString = formatter.string(from: end)
            return "\(startString) - \(endString)"
        } else {
            return startString
        }
    }
    
    private func loadProfileImage(_ item: PhotosPickerItem?) {
        Task {
            if let item = item,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    profileImage = image
                }
            }
        }
    }
    
    @MainActor
    private func refreshProfile() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        // Refresh profile data
    }
}

// MARK: - Comprehensive Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var showAccountSettings = false
    @State private var showPrivacySettings = false
    @State private var showNotificationSettings = false
    @State private var showSecuritySettings = false
    @State private var showDataSettings = false
    @State private var showHelpCenter = false
    @State private var showAbout = false
    @State private var showSignOutConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Profile Header
                    profileHeaderSection
                    
                    // Main Settings Sections
                    settingsSection(title: "Account", items: accountSettings)
                    settingsSection(title: "Privacy", items: privacySettings)
                    settingsSection(title: "Notifications", items: notificationSettings)
                    settingsSection(title: "Security", items: securitySettings)
                    settingsSection(title: "Data & Storage", items: dataSettings)
                    settingsSection(title: "Support", items: supportSettings)
                    settingsSection(title: "About", items: aboutSettings)
                    
                    // Sign Out Section
                    signOutSection
                    
                    // App Version
                    versionSection
                }
            }
            .background(Constants.Colors.professionalGray)
            .navigationTitle("Settings & Privacy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
        .sheet(isPresented: $showAccountSettings) {
            AccountSettingsView()
        }
        .sheet(isPresented: $showPrivacySettings) {
            PrivacySettingsView()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showSecuritySettings) {
            SecuritySettingsView()
        }
        .sheet(isPresented: $showDataSettings) {
            DataSettingsView()
        }
        .sheet(isPresented: $showHelpCenter) {
            HelpCenterView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .confirmationDialog("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authService.signOut()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    // MARK: - Profile Header Section
    private var profileHeaderSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack {
                // Profile Image
                AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? Constants.Images.defaultProfileMale)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Constants.Colors.lightGray)
                        .overlay(
                            Text(authService.currentUser?.fullName.initials ?? "")
                                .font(Constants.Fonts.title3)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(authService.currentUser?.fullName ?? "User Name")
                        .font(Constants.Fonts.professionalHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text(authService.currentUser?.email ?? "")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    if let headline = authService.currentUser?.headline {
                        Text(headline)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Premium Badge (if applicable)
                premiumBadge
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
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Settings Section
    private func settingsSection(title: String, items: [SettingsItem]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            Text(title)
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
                .padding(.horizontal, Constants.Spacing.cardPadding)
                .padding(.top, Constants.Spacing.lg)
                .padding(.bottom, Constants.Spacing.sm)
            
            // Section Items
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    settingsRow(item: item, isLast: index == items.count - 1)
                }
            }
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.CornerRadius.card)
            .shadow(
                color: Constants.Shadow.card.color,
                radius: Constants.Shadow.card.radius,
                x: Constants.Shadow.card.x,
                y: Constants.Shadow.card.y
            )
        }
        .padding(.horizontal, Constants.Spacing.md)
    }
    
    // MARK: - Settings Row
    private func settingsRow(item: SettingsItem, isLast: Bool) -> some View {
        Button(action: item.action) {
            HStack(spacing: Constants.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                        .fill(item.iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: item.icon)
                        .font(.callout)
                        .foregroundColor(item.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                
                Spacer()
                
                // Right accessory
                if let value = item.value {
                    Text(value)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                if item.hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                if item.hasToggle {
                    Toggle("", isOn: .constant(item.toggleValue ?? false))
                        .labelsHidden()
                }
            }
            .padding(.horizontal, Constants.Spacing.cardPadding)
            .padding(.vertical, Constants.Spacing.md)
            .background(Constants.Colors.cardBackground)
            
            if !isLast {
                Divider()
                    .padding(.leading, 64)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Sign Out Section
    private var signOutSection: some View {
        VStack(spacing: 0) {
            Button(action: { showSignOutConfirmation = true }) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                            .fill(Constants.Colors.error.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.callout)
                            .foregroundColor(Constants.Colors.error)
                    }
                    
                    Text("Sign Out")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.error)
                    
                    Spacer()
                }
                .padding(.horizontal, Constants.Spacing.cardPadding)
                .padding(.vertical, Constants.Spacing.md)
            }
        }
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.card)
        .shadow(
            color: Constants.Shadow.card.color,
            radius: Constants.Shadow.card.radius,
            x: Constants.Shadow.card.x,
            y: Constants.Shadow.card.y
        )
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.lg)
    }
    
    // MARK: - Version Section
    private var versionSection: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Text("ProNet Professional")
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            Text("Version 1.0.0 (Build 1)")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.tertiaryLabel)
            
            Text("© 2025 ProNet. All rights reserved.")
                .font(Constants.Fonts.caption2)
                .foregroundColor(Constants.Colors.tertiaryLabel)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, Constants.Spacing.xl)
    }
    
    // MARK: - Premium Badge
    private var premiumBadge: some View {
        HStack(spacing: Constants.Spacing.xs) {
            Image(systemName: "crown.fill")
                .font(.caption)
                .foregroundColor(Constants.Colors.premiumGold)
            
            Text("Premium")
                .font(Constants.Fonts.caption1)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.premiumGold)
        }
        .padding(.horizontal, Constants.Spacing.sm)
        .padding(.vertical, Constants.Spacing.xs)
        .background(Constants.Colors.premiumGold.opacity(0.1))
        .cornerRadius(Constants.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                .stroke(Constants.Colors.premiumGold.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Settings Data
    private var accountSettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Profile Information",
                subtitle: "Edit your profile details",
                icon: "person.circle",
                iconColor: Constants.Colors.primaryBlue,
                hasChevron: true,
                action: { showAccountSettings = true }
            ),
            SettingsItem(
                title: "Premium Features",
                subtitle: "Upgrade your experience",
                icon: "crown",
                iconColor: Constants.Colors.premiumGold,
                hasChevron: true,
                action: { /* Handle premium */ }
            ),
            SettingsItem(
                title: "Account Preferences",
                subtitle: "Language, region, and more",
                icon: "gearshape",
                iconColor: Constants.Colors.mediumGray,
                hasChevron: true,
                action: { /* Handle preferences */ }
            )
        ]
    }
    
    private var privacySettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Profile Visibility",
                subtitle: "Control who can see your profile",
                icon: "eye",
                iconColor: Constants.Colors.shareGreen,
                hasChevron: true,
                action: { showPrivacySettings = true }
            ),
            SettingsItem(
                title: "Activity Status",
                subtitle: "Show when you're active",
                icon: "circle.fill",
                iconColor: Constants.Colors.success,
                hasToggle: true,
                toggleValue: true,
                action: { /* Handle activity status */ }
            ),
            SettingsItem(
                title: "Data Privacy",
                subtitle: "Manage your data and downloads",
                icon: "lock.shield",
                iconColor: Constants.Colors.commentBlue,
                hasChevron: true,
                action: { /* Handle data privacy */ }
            )
        ]
    }
    
    private var notificationSettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Push Notifications",
                subtitle: "Get notified about activity",
                icon: "bell",
                iconColor: Constants.Colors.warning,
                hasChevron: true,
                action: { showNotificationSettings = true }
            ),
            SettingsItem(
                title: "Email Notifications",
                subtitle: "Weekly digest and updates",
                icon: "envelope",
                iconColor: Constants.Colors.commentBlue,
                hasChevron: true,
                action: { /* Handle email notifications */ }
            ),
            SettingsItem(
                title: "SMS Notifications",
                subtitle: "Security alerts via SMS",
                icon: "message",
                iconColor: Constants.Colors.shareGreen,
                hasToggle: true,
                toggleValue: false,
                action: { /* Handle SMS notifications */ }
            )
        ]
    }
    
    private var securitySettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Change Password",
                subtitle: "Update your password",
                icon: "key",
                iconColor: Constants.Colors.primaryBlue,
                hasChevron: true,
                action: { showSecuritySettings = true }
            ),
            SettingsItem(
                title: "Two-Factor Authentication",
                subtitle: "Add extra security to your account",
                icon: "shield.checkered",
                iconColor: Constants.Colors.success,
                hasChevron: true,
                action: { /* Handle 2FA */ }
            ),
            SettingsItem(
                title: "Login Activity",
                subtitle: "See where you're logged in",
                icon: "list.bullet.rectangle",
                iconColor: Constants.Colors.mediumGray,
                hasChevron: true,
                action: { /* Handle login activity */ }
            )
        ]
    }
    
    private var dataSettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Download Your Data",
                subtitle: "Get a copy of your information",
                icon: "arrow.down.circle",
                iconColor: Constants.Colors.commentBlue,
                hasChevron: true,
                action: { showDataSettings = true }
            ),
            SettingsItem(
                title: "Storage & Data",
                subtitle: "Manage app storage usage",
                icon: "internaldrive",
                iconColor: Constants.Colors.mediumGray,
                hasChevron: true,
                action: { /* Handle storage */ }
            ),
            SettingsItem(
                title: "Clear Cache",
                subtitle: "Free up storage space",
                icon: "trash.circle",
                iconColor: Constants.Colors.warning,
                hasChevron: true,
                action: { /* Handle clear cache */ }
            )
        ]
    }
    
    private var supportSettings: [SettingsItem] {
        [
            SettingsItem(
                title: "Help Center",
                subtitle: "Get help and support",
                icon: "questionmark.circle",
                iconColor: Constants.Colors.primaryBlue,
                hasChevron: true,
                action: { showHelpCenter = true }
            ),
            SettingsItem(
                title: "Contact Support",
                subtitle: "Get in touch with our team",
                icon: "phone.circle",
                iconColor: Constants.Colors.shareGreen,
                hasChevron: true,
                action: { /* Handle contact support */ }
            ),
            SettingsItem(
                title: "Send Feedback",
                subtitle: "Help us improve the app",
                icon: "heart.circle",
                iconColor: Constants.Colors.likeRed,
                hasChevron: true,
                action: { /* Handle feedback */ }
            )
        ]
    }
    
    private var aboutSettings: [SettingsItem] {
        [
            SettingsItem(
                title: "About ProNet",
                subtitle: "Learn more about our mission",
                icon: "info.circle",
                iconColor: Constants.Colors.primaryBlue,
                hasChevron: true,
                action: { showAbout = true }
            ),
            SettingsItem(
                title: "Privacy Policy",
                subtitle: "How we protect your privacy",
                icon: "doc.text",
                iconColor: Constants.Colors.mediumGray,
                hasChevron: true,
                action: { /* Handle privacy policy */ }
            ),
            SettingsItem(
                title: "Terms of Service",
                subtitle: "Terms and conditions",
                icon: "doc.plaintext",
                iconColor: Constants.Colors.mediumGray,
                hasChevron: true,
                action: { /* Handle terms */ }
            )
        ]
    }
}

// MARK: - Settings Item Model
struct SettingsItem {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let hasChevron: Bool
    let hasToggle: Bool
    let toggleValue: Bool?
    let value: String?
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color,
        hasChevron: Bool = false,
        hasToggle: Bool = false,
        toggleValue: Bool? = nil,
        value: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.hasChevron = hasChevron
        self.hasToggle = hasToggle
        self.toggleValue = toggleValue
        self.value = value
        self.action = action
    }
}

// MARK: - Individual Settings Views
struct AccountSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Account Settings")
                    .font(Constants.Fonts.title2)
                    .padding()
                
                Spacer()
                
                Text("Detailed account settings would be implemented here.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct PrivacySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileVisibility = "Everyone"
    @State private var showActivity = true
    @State private var showConnections = true
    @State private var allowMessages = true
    
    private let visibilityOptions = ["Everyone", "Connections only", "No one"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Visibility") {
                    Picker("Who can see your profile", selection: $profileVisibility) {
                        ForEach(visibilityOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Activity") {
                    Toggle("Show activity status", isOn: $showActivity)
                    Toggle("Show connections", isOn: $showConnections)
                    Toggle("Allow messages from anyone", isOn: $allowMessages)
                }
                
                Section("Data & Privacy") {
                    NavigationLink("Data Privacy Settings") {
                        DataPrivacyView()
                    }
                }
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotifications = true
    @State private var emailNotifications = true
    @State private var connectionRequests = true
    @State private var likes = true
    @State private var comments = true
    @State private var mentions = true
    @State private var messages = true
    @State private var weeklyDigest = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Push Notifications") {
                    Toggle("Enable push notifications", isOn: $pushNotifications)
                    
                    if pushNotifications {
                        Toggle("Connection requests", isOn: $connectionRequests)
                        Toggle("Likes on your posts", isOn: $likes)
                        Toggle("Comments on your posts", isOn: $comments)
                        Toggle("Mentions", isOn: $mentions)
                        Toggle("Messages", isOn: $messages)
                    }
                }
                
                Section("Email Notifications") {
                    Toggle("Weekly digest", isOn: $weeklyDigest)
                    Toggle("Email updates", isOn: $emailNotifications)
                }
                
                Section("Quiet Hours") {
                    NavigationLink("Set quiet hours") {
                        QuietHoursView()
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SecuritySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Password & Security") {
                    NavigationLink("Change Password") {
                        ChangePasswordView()
                    }
                    NavigationLink("Two-Factor Authentication") {
                        TwoFactorAuthView()
                    }
                }
                
                Section("Login Activity") {
                    NavigationLink("Where you're logged in") {
                        LoginActivityView()
                    }
                    NavigationLink("Login alerts") {
                        LoginAlertsView()
                    }
                }
            }
            .navigationTitle("Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct DataSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Your Data") {
                    NavigationLink("Download your data") {
                        DataDownloadView()
                    }
                    NavigationLink("Data usage") {
                        DataUsageView()
                    }
                }
                
                Section("Storage") {
                    HStack {
                        Text("App storage")
                        Spacer()
                        Text("245 MB")
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Button("Clear cache") {
                        // Handle clear cache
                    }
                    .foregroundColor(Constants.Colors.warning)
                }
            }
            .navigationTitle("Data & Storage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HelpCenterView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Constants.Spacing.md) {
                    helpSection(title: "Getting Started", items: [
                        "How to create your profile",
                        "Building your network",
                        "Making your first post",
                        "Finding the right connections"
                    ])
                    
                    helpSection(title: "Privacy & Security", items: [
                        "Managing your privacy settings",
                        "Blocking and reporting",
                        "Two-factor authentication",
                        "Account security tips"
                    ])
                    
                    helpSection(title: "Features", items: [
                        "Using advanced search",
                        "Creating engaging content",
                        "Professional messaging",
                        "Premium features"
                    ])
                    
                    helpSection(title: "Troubleshooting", items: [
                        "App not loading",
                        "Notification issues",
                        "Connection problems",
                        "Account recovery"
                    ])
                }
                .padding(Constants.Spacing.md)
            }
            .navigationTitle("Help Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func helpSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text(title)
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    Button(action: { /* Handle help item */ }) {
                        HStack {
                            Text(item)
                                .font(Constants.Fonts.body)
                                .foregroundColor(Constants.Colors.label)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                        .padding(Constants.Spacing.md)
                        .background(Constants.Colors.cardBackground)
                        
                        if index < items.count - 1 {
                            Divider()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .cornerRadius(Constants.CornerRadius.card)
            .shadow(
                color: Constants.Shadow.card.color,
                radius: Constants.Shadow.card.radius,
                x: Constants.Shadow.card.x,
                y: Constants.Shadow.card.y
            )
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.xl) {
                    // App Logo
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                            .fill(Constants.Colors.primaryGradient)
                            .frame(width: 100, height: 100)
                        
                        Text("in")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: Constants.Spacing.md) {
                        Text("ProNet Professional")
                            .font(Constants.Fonts.title1)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.label)
                        
                        Text("Version 1.0.0")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        Text("Connect with professionals, share insights, and grow your career with ProNet - the professional networking platform designed for the modern workforce.")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.label)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Constants.Spacing.lg)
                    }
                    
                    VStack(spacing: Constants.Spacing.sm) {
                        Text("© 2025 ProNet Inc.")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        
                        Text("All rights reserved.")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
                .padding(Constants.Spacing.xl)
            }
            .navigationTitle("About ProNet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Additional Setting Views (Placeholders)
struct DataPrivacyView: View {
    var body: some View {
        Text("Data Privacy Settings")
    }
}

struct QuietHoursView: View {
    var body: some View {
        Text("Quiet Hours Settings")
    }
}

struct ChangePasswordView: View {
    var body: some View {
        Text("Change Password")
    }
}

struct TwoFactorAuthView: View {
    var body: some View {
        Text("Two-Factor Authentication")
    }
}

struct LoginActivityView: View {
    var body: some View {
        Text("Login Activity")
    }
}

struct LoginAlertsView: View {
    var body: some View {
        Text("Login Alerts")
    }
}

struct DataDownloadView: View {
    var body: some View {
        Text("Download Your Data")
    }
}

struct DataUsageView: View {
    var body: some View {
        Text("Data Usage")
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    @State private var fullName = ""
    @State private var headline = ""
    @State private var location = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var phoneNumber = ""
    @State private var selectedProfileImage: UIImage?
    @State private var showImagePicker = false
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var experience: [Experience] = []
    @State private var education: [Education] = []
    @State private var skills: [String] = []
    @State private var newSkill = ""
    @State private var showAddExperience = false
    @State private var showAddEducation = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Constants.Spacing.lg) {
                    // Profile Photo Section
                    profilePhotoSection
                    
                    // Basic Information
                    basicInfoSection
                    
                    // Professional Summary
                    professionalSummarySection
                    
                    // Contact Information
                    contactInfoSection
                    
                    // Experience Section
                    experienceSection
                    
                    // Education Section
                    educationSection
                    
                    // Skills Section
                    skillsSection
                }
                .padding(Constants.Spacing.md)
            }
            .background(Constants.Colors.professionalGray)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfile) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primaryBlue))
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .disabled(isLoading)
                }
            }
        }
        .photosPicker(isPresented: $showImagePicker, selection: $selectedImageItem, matching: .images)
        .onChange(of: selectedImageItem) { item in
            loadSelectedImage(item)
        }
        .sheet(isPresented: $showAddExperience) {
            AddExperienceView { newExperience in
                experience.append(newExperience)
            }
        }
        .sheet(isPresented: $showAddEducation) {
            AddEducationView { newEducation in
                education.append(newEducation)
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            Text("Profile Photo")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: Constants.Spacing.md) {
                // Profile Image
                if let selectedProfileImage = selectedProfileImage {
                    Image(uiImage: selectedProfileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Constants.Colors.primaryBlue, lineWidth: 3)
                        )
                } else {
                    AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? Constants.Images.defaultProfileMale)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(authService.currentUser?.fullName.initials ?? "")
                                    .font(Constants.Fonts.title1)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Constants.Colors.primaryBlue, lineWidth: 3)
                    )
                }
                
                Button("Change Photo") {
                    showImagePicker = true
                }
                .font(Constants.Fonts.body)
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
    
    // MARK: - Basic Information Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Basic Information")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.md) {
                customTextField("Full Name", text: $fullName, placeholder: "Enter your full name")
                customTextField("Professional Headline", text: $headline, placeholder: "e.g., Senior Software Engineer at Apple")
                customTextField("Location", text: $location, placeholder: "e.g., San Francisco, CA")
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
    
    // MARK: - Professional Summary Section
    private var professionalSummarySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("About")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text("Summary")
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.label)
                
                TextEditor(text: $bio)
                    .font(Constants.Fonts.body)
                    .frame(minHeight: 100)
                    .padding(Constants.Spacing.sm)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.medium)
                            .stroke(Constants.Colors.border, lineWidth: 1)
                    )
                    .overlay(
                        Group {
                            if bio.isEmpty {
                                VStack {
                                    HStack {
                                        Text("Write a brief summary about your professional background...")
                                            .font(Constants.Fonts.body)
                                            .foregroundColor(Constants.Colors.tertiaryLabel)
                                            .allowsHitTesting(false)
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding(Constants.Spacing.md)
                            }
                        }
                    )
                
                Text("\(bio.count)/2000 characters")
                    .font(Constants.Fonts.caption2)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
    
    // MARK: - Contact Information Section
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Contact Information")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            VStack(spacing: Constants.Spacing.md) {
                customTextField("Website", text: $website, placeholder: "https://yourwebsite.com")
                customTextField("Phone Number", text: $phoneNumber, placeholder: "+1 (555) 123-4567")
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
    
    // MARK: - Experience Section
    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Experience")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button(action: { showAddExperience = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            
            if experience.isEmpty {
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "briefcase")
                        .font(.title)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Text("No experience added yet")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Button("Add Experience") {
                        showAddExperience = true
                    }
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.Spacing.xl)
            } else {
                VStack(spacing: Constants.Spacing.sm) {
                    ForEach(Array(experience.enumerated()), id: \.offset) { index, exp in
                        experienceRow(exp) {
                            experience.remove(at: index)
                        }
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
    
    // MARK: - Education Section
    private var educationSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Education")
                    .font(Constants.Fonts.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button(action: { showAddEducation = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            
            if education.isEmpty {
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "graduationcap")
                        .font(.title)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Text("No education added yet")
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Button("Add Education") {
                        showAddEducation = true
                    }
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.Spacing.xl)
            } else {
                VStack(spacing: Constants.Spacing.sm) {
                    ForEach(Array(education.enumerated()), id: \.offset) { index, edu in
                        educationRow(edu) {
                            education.remove(at: index)
                        }
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
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Skills")
                .font(Constants.Fonts.headline)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.label)
            
            // Add Skill Input
            HStack {
                TextField("Add a skill", text: $newSkill)
                    .font(Constants.Fonts.body)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    addSkill()
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
                .disabled(newSkill.isEmpty)
            }
            
            // Skills Grid
            if !skills.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: Constants.Spacing.sm) {
                    ForEach(Array(skills.enumerated()), id: \.offset) { index, skill in
                        skillTag(skill) {
                            skills.remove(at: index)
                        }
                    }
                }
            }
            
            // Suggested Skills
            if !suggestedSkills.isEmpty {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Text("Suggested Skills")
                        .font(Constants.Fonts.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Constants.Spacing.xs) {
                        ForEach(suggestedSkills, id: \.self) { skill in
                            Button(action: { addSuggestedSkill(skill) }) {
                                Text(skill)
                                    .font(Constants.Fonts.caption1)
                                    .padding(.horizontal, Constants.Spacing.sm)
                                    .padding(.vertical, Constants.Spacing.xs)
                                    .background(Constants.Colors.primaryBlue.opacity(0.1))
                                    .foregroundColor(Constants.Colors.primaryBlue)
                                    .cornerRadius(Constants.CornerRadius.small)
                            }
                        }
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
    
    // MARK: - Helper Views
    private func customTextField(_ title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            Text(title)
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
            
            TextField(placeholder, text: text)
                .font(Constants.Fonts.body)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private func experienceRow(_ exp: Experience, onDelete: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            Image(systemName: "briefcase.fill")
                .font(.callout)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(exp.title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(exp.company)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                Text(formatDateRange(start: exp.startDate, end: exp.endDate, isCurrent: exp.isCurrentRole))
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.callout)
                    .foregroundColor(Constants.Colors.error)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    private func educationRow(_ edu: Education, onDelete: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: Constants.Spacing.md) {
            Image(systemName: "graduationcap.fill")
                .font(.callout)
                .foregroundColor(Constants.Colors.primaryBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Text(edu.degree)
                    .font(Constants.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(edu.institution)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                if let field = edu.fieldOfStudy {
                    Text(field)
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Text(formatDateRange(start: edu.startDate, end: edu.endDate))
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.callout)
                    .foregroundColor(Constants.Colors.error)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    private func skillTag(_ skill: String, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: Constants.Spacing.xs) {
            Text(skill)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.label)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
        .background(Constants.Colors.lightBlue.opacity(0.3))
        .cornerRadius(Constants.CornerRadius.pill)
    }
    
    // MARK: - Computed Properties
    private var suggestedSkills: [String] {
        let allSkills = Constants.SampleData.skills
        return allSkills.filter { skill in
            !skills.contains(skill) && skill.localizedCaseInsensitiveContains(newSkill.isEmpty ? "" : newSkill)
        }.prefix(6).map { $0 }
    }
    
    // MARK: - Actions
    private func loadUserData() {
        guard let user = authService.currentUser else { return }
        
        fullName = user.fullName
        headline = user.headline ?? ""
        location = user.location ?? ""
        bio = user.bio ?? ""
        website = user.website ?? ""
        phoneNumber = user.phoneNumber ?? ""
        experience = user.experience
        education = user.education
        skills = user.skills
    }
    
    private func loadSelectedImage(_ item: PhotosPickerItem?) {
        Task {
            if let item = item,
               let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedProfileImage = image
                }
            }
        }
    }
    
    private func addSkill() {
        let trimmedSkill = newSkill.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSkill.isEmpty && !skills.contains(trimmedSkill) else { return }
        
        skills.append(trimmedSkill)
        newSkill = ""
    }
    
    private func addSuggestedSkill(_ skill: String) {
        guard !skills.contains(skill) else { return }
        skills.append(skill)
    }
    
    private func saveProfile() {
        isLoading = true
        
        // Simulate saving profile
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            dismiss()
        }
    }
    
    private func formatDateRange(start: Date, end: Date? = nil, isCurrent: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let startString = formatter.string(from: start)
        
        if isCurrent {
            return "\(startString) - Present"
        } else if let end = end {
            let endString = formatter.string(from: end)
            return "\(startString) - \(endString)"
        } else {
            return startString
        }
    }
}

// MARK: - Add Experience View
struct AddExperienceView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Experience) -> Void
    
    @State private var title = ""
    @State private var company = ""
    @State private var location = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isCurrentRole = false
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Role Details") {
                    TextField("Job Title", text: $title)
                    TextField("Company", text: $company)
                    TextField("Location", text: $location)
                }
                
                Section("Duration") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    
                    Toggle("I currently work here", isOn: $isCurrentRole)
                    
                    if !isCurrentRole {
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                    }
                }
                
                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Experience")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let experience = Experience(
                            title: title,
                            company: company,
                            startDate: startDate,
                            isCurrentRole: isCurrentRole
                        )
                        onAdd(experience)
                        dismiss()
                    }
                    .disabled(title.isEmpty || company.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Education View
struct AddEducationView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (Education) -> Void
    
    @State private var institution = ""
    @State private var degree = ""
    @State private var fieldOfStudy = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Education Details") {
                    TextField("School", text: $institution)
                    TextField("Degree", text: $degree)
                    TextField("Field of Study", text: $fieldOfStudy)
                }
                
                Section("Duration") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, displayedComponents: [.date])
                }
                
                Section("Description") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Education")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let education = Education(
                            institution: institution,
                            degree: degree,
                            startDate: startDate
                        )
                        onAdd(education)
                        dismiss()
                    }
                    .disabled(institution.isEmpty || degree.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
} 