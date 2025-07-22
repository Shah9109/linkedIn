import SwiftUI

struct HomeView: View {
    @StateObject private var postService = PostService()
    @StateObject private var authService = AuthService()
    @State private var showCreatePost = false
    @State private var searchText = ""
    @State private var selectedTab = 0
    
    private let feedTabs = ["Home", "Recent", "Following", "Popular"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Stories Section
                        storiesSection
                        
                        // Feed Tabs
                        feedTabsSection
                        
                        // Quick Actions Card
                        quickActionsCard
                        
                        // Trending Topics
                        trendingTopicsSection
                        
                        // Posts Feed
                        postsSection
                    }
                }
                .refreshable {
                    await refreshPosts()
                }
            }
            .background(Constants.Colors.professionalGray)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCreatePost) {
            PostCreationView()
        }
        .onAppear {
            if postService.posts.isEmpty {
                postService.fetchPosts()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                // Logo and Search
                HStack(spacing: Constants.Spacing.md) {
                    // LinkedIn-style logo
                    ZStack {
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.small)
                            .fill(Constants.Colors.primaryBlue)
                            .frame(width: 32, height: 32)
                        
                        Text("in")
                            .font(Constants.Fonts.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .font(.callout)
                    
                        TextField("Search", text: $searchText)
                            .font(Constants.Fonts.body)
                    }
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.sm)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.pill)
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: Constants.Spacing.lg) {
                    notificationButton
                    chatButton
                    profileButton
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.md)
            .background(Constants.Colors.background)
            
            Rectangle()
                .fill(Constants.Colors.border.opacity(0.3))
                .frame(height: 0.5)
        }
    }
    
    // MARK: - Stories Section
    private var storiesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.md) {
                // Your Story
                yourStoryView
                
                // Other Stories
                ForEach(0..<8, id: \.self) { index in
                    storyView(
                        profileImage: Constants.Images.businessProfile1,
                        name: "Story \(index + 1)",
                        isViewed: index < 3
                    )
        }
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.md)
        .background(Constants.Colors.background)
    }
    
    // MARK: - Feed Tabs Section
    private var feedTabsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(feedTabs.enumerated()), id: \.offset) { index, tab in
                    Button(action: { selectedTab = index }) {
                        VStack(spacing: Constants.Spacing.xs) {
                            Text(tab)
                                .font(selectedTab == index ? Constants.Fonts.bodyMedium : Constants.Fonts.body)
                                .foregroundColor(selectedTab == index ? Constants.Colors.primaryBlue : Constants.Colors.secondaryLabel)
                            
                            Rectangle()
                                .fill(selectedTab == index ? Constants.Colors.primaryBlue : .clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(minWidth: 80)
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.sm)
                }
            }
        }
        .background(Constants.Colors.background)
        .overlay(
            Rectangle()
                .fill(Constants.Colors.border.opacity(0.3))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    // MARK: - Quick Actions Card
    private var quickActionsCard: some View {
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
                            Text(authService.currentUser?.fullName.initials ?? "YN")
                                .font(Constants.Fonts.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                
                // Quick Post Button
                Button(action: { showCreatePost = true }) {
                    HStack {
                        Text("Start a post, try writing with AI")
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                        Spacer()
                    }
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.vertical, Constants.Spacing.md)
                    .background(Constants.Colors.secondaryBackground)
                    .cornerRadius(Constants.CornerRadius.pill)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.CornerRadius.pill)
                            .stroke(Constants.Colors.border.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            
            // Action Buttons
            HStack {
                quickActionButton(
                    icon: "camera.fill", 
                    text: "Media",
                    color: Constants.Colors.commentBlue
                ) {
                    showCreatePost = true
                }
                
                Spacer()
                
                quickActionButton(
                    icon: "calendar",
                    text: "Event", 
                    color: Constants.Colors.warning
                ) {
                    // Handle event creation
                }
                
                Spacer()
                
                quickActionButton(
                    icon: "doc.text.fill",
                    text: "Write article",
                    color: Constants.Colors.shareGreen
                ) {
                    showCreatePost = true
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
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Trending Topics Section
    private var trendingTopicsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Trending in your industry")
                    .font(Constants.Fonts.professionalHeadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button("See all") {
                    // Show all trending topics
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.primaryBlue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Constants.Spacing.sm), count: 2), spacing: Constants.Spacing.sm) {
                ForEach(trendingTopics, id: \.self) { topic in
                    trendingTopicCard(topic)
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
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Posts Section
    private var postsSection: some View {
        LazyVStack(spacing: Constants.Spacing.md) {
            ForEach(postService.posts, id: \.id) { post in
                PostCardView(post: post, postService: postService)
                    .padding(.horizontal, Constants.Spacing.md)
            }
            
            // Loading indicator
            if postService.isLoading {
                loadingSection
            }
        }
        .padding(.top, Constants.Spacing.md)
    }
    
    // MARK: - Helper Views
    private var notificationButton: some View {
        Button(action: { /* Handle notifications */ }) {
            ZStack {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                // Unread badge
                Circle()
                    .fill(Constants.Colors.likeRed)
                    .frame(width: 8, height: 8)
                    .offset(x: 8, y: -8)
            }
        }
    }
    
    private var chatButton: some View {
        Button(action: { /* Handle chat */ }) {
            Image(systemName: "message")
                .font(.title3)
                .foregroundColor(Constants.Colors.secondaryLabel)
        }
    }
    
    private var profileButton: some View {
        Button(action: { /* Handle profile */ }) {
            AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? Constants.Images.defaultProfileMale)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .overlay(
                        Text("YN")
                            .font(Constants.Fonts.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    )
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
        }
    }
    
    private var yourStoryView: some View {
        VStack(spacing: Constants.Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(Constants.Colors.primaryBlue, lineWidth: 2)
                    .frame(width: 68, height: 68)
                
                AsyncImage(url: URL(string: authService.currentUser?.profileImageURL ?? Constants.Images.defaultProfileMale)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Constants.Colors.lightGray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                
                // Plus button
                Circle()
                    .fill(Constants.Colors.primaryBlue)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .offset(x: 20, y: 20)
            }
            
            Text("Your story")
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.label)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
    
    private func storyView(profileImage: String, name: String, isViewed: Bool) -> some View {
        VStack(spacing: Constants.Spacing.xs) {
            Circle()
                .stroke(isViewed ? Constants.Colors.lightGray : Constants.Colors.primaryBlue, lineWidth: 2)
                .frame(width: 68, height: 68)
                .overlay(
                    AsyncImage(url: URL(string: profileImage)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                )
            
            Text(name)
                .font(Constants.Fonts.caption1)
                .foregroundColor(Constants.Colors.label)
                .lineLimit(1)
        }
        .frame(width: 80)
    }
    
    private func quickActionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Constants.Spacing.xs) {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundColor(color)
                
                Text(text)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
            }
            .padding(.vertical, Constants.Spacing.xs)
        }
    }
    
    private func trendingTopicCard(_ topic: String) -> some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.shareGreen)
                
                Spacer()
                
                Text("12.5k")
                    .font(Constants.Fonts.caption2)
                    .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            Text(topic)
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.label)
                .lineLimit(2)
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.secondaryBackground)
        .cornerRadius(Constants.CornerRadius.medium)
    }
    
    // MARK: - Loading Section
    private var loadingSection: some View {
        VStack(spacing: Constants.Spacing.md) {
            ForEach(0..<2, id: \.self) { _ in
                PostSkeletonView()
                    .padding(.horizontal, Constants.Spacing.md)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var trendingTopics: [String] {
        [
            "Artificial Intelligence",
            "Remote Work",
            "Digital Transformation", 
            "Sustainability"
        ]
    }
    
    // MARK: - Actions
    @MainActor
    private func refreshPosts() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        postService.refreshPosts()
    }
}

// MARK: - Enhanced Post Card View
struct PostCardView: View {
    let post: Post
    let postService: PostService
    @State private var showComments = false
    @State private var commentText = ""
    @State private var isLiked = false
    @State private var likeCount = 0
    @State private var showMoreContent = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            postHeader
            
            // Content
            postContent
            
            // Media
            if !post.imageURLs.isEmpty {
                postMedia
            }
            
            // Engagement Stats
            if likeCount > 0 || post.commentCount > 0 || post.shares > 0 {
                engagementStats
            }
            
            Divider()
                .padding(.horizontal, Constants.Spacing.cardPadding)
            
            // Action Buttons
            actionButtons
            
            // Comments Section
            if showComments {
                commentsSection
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
        .onAppear {
            likeCount = post.likeCount
            isLiked = post.isLikedBy(userId: FirebaseManager.shared.currentUser?.id ?? "")
        }
    }
    
    // MARK: - Post Components
    private var postHeader: some View {
        HStack(alignment: .top) {
                // Profile Image
            AsyncImage(url: URL(string: post.authorProfileImageURL ?? Constants.Images.businessProfile1)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Constants.Colors.lightGray)
                        .overlay(
                            Text(post.authorName.initials)
                                .font(Constants.Fonts.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
            .frame(width: 52, height: 52)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(post.authorName)
                        .font(Constants.Fonts.professionalHeadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    // Verified badge
                    if Bool.random() { // Random verification for demo
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                    
                    // Following button
                    if Bool.random() {
                        Button("• Follow") {
                            // Handle follow
                        }
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                
                if let headline = post.authorHeadline {
                    Text(headline)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(post.createdAt.formatForPost())
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Text("•")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    
                    Image(systemName: "globe.americas")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
            
            Spacer()
            
            Menu {
                Button("Save post") { /* Handle save */ }
                Button("Copy link") { /* Handle copy */ }
                Button("Report post") { /* Handle report */ }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .padding(Constants.Spacing.sm)
            }
        }
        .padding(.horizontal, Constants.Spacing.cardPadding)
        .padding(.top, Constants.Spacing.cardPadding)
        .padding(.bottom, Constants.Spacing.md)
    }
    
    private var postContent: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            let contentText = post.content
            let shouldTruncate = contentText.count > 200
            
            Text(shouldTruncate && !showMoreContent ? String(contentText.prefix(200)) + "..." : contentText)
                .font(Constants.Fonts.professionalBody)
                .foregroundColor(Constants.Colors.label)
                .fixedSize(horizontal: false, vertical: true)
            
            if shouldTruncate {
                Button(showMoreContent ? "Show less" : "...see more") {
                    showMoreContent.toggle()
                }
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.secondaryLabel)
            }
            
            // Hashtags
            if !post.hashtags.isEmpty {
                HStack {
                    ForEach(post.hashtags.prefix(3), id: \.self) { hashtag in
                        Button(hashtag) {
                            // Handle hashtag tap
                        }
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.cardPadding)
    }
    
    private var postMedia: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.Spacing.sm) {
                ForEach(Array(post.imageURLs.enumerated()), id: \.offset) { index, imageURL in
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Constants.Colors.lightGray)
                                    .shimmer(isLoading: true)
                            }
                    .frame(width: post.imageURLs.count == 1 ? UIScreen.main.bounds.width - 32 : 280, height: 200)
                            .cornerRadius(Constants.CornerRadius.medium)
                            .clipped()
                        }
                    }
            .padding(.horizontal, Constants.Spacing.cardPadding)
                }
        .padding(.top, Constants.Spacing.md)
            }
            
    private var engagementStats: some View {
                HStack {
                    if likeCount > 0 {
                        HStack(spacing: Constants.Spacing.xs) {
                    HStack(spacing: -4) {
                        Circle()
                            .fill(Constants.Colors.likeRed)
                            .frame(width: 16, height: 16)
                            .overlay(
                            Image(systemName: "heart.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                            )
                        
                        Circle()
                            .fill(Constants.Colors.primaryBlue)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "hand.thumbsup.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    Button("\(likeCount)") {
                        // Show who liked
                    }
                                .font(Constants.Fonts.caption1)
                                .foregroundColor(Constants.Colors.secondaryLabel)
                        }
                    }
                    
            Spacer()
            
            HStack(spacing: Constants.Spacing.md) {
                    if post.commentCount > 0 {
                    Button("\(post.commentCount) comments") {
                        showComments.toggle()
                    }
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    if post.shares > 0 {
                    Text("\(post.shares) reposts")
                            .font(Constants.Fonts.caption1)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
        }
        .padding(.horizontal, Constants.Spacing.cardPadding)
        .padding(.top, Constants.Spacing.md)
        .padding(.bottom, Constants.Spacing.sm)
            }
            
    private var actionButtons: some View {
            HStack {
                actionButton(
                    icon: isLiked ? "heart.fill" : "heart",
                    text: "Like",
                color: isLiked ? Constants.Colors.likeRed : Constants.Colors.secondaryLabel
                ) {
                    handleLike()
                }
                
                Spacer()
                
            actionButton(
                icon: "bubble.left", 
                text: "Comment", 
                color: Constants.Colors.commentBlue
            ) {
                    showComments.toggle()
                }
                
                Spacer()
                
            actionButton(
                icon: "arrow.2.squarepath", 
                text: "Repost", 
                color: Constants.Colors.shareGreen
            ) {
                    handleShare()
                }
                
                Spacer()
                
            actionButton(
                icon: "paperplane", 
                text: "Send", 
                color: Constants.Colors.sendPurple
            ) {
                    // Handle send
                }
        }
        .padding(.horizontal, Constants.Spacing.cardPadding)
        .padding(.vertical, Constants.Spacing.md)
            }
            
    private var commentsSection: some View {
                VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
                    Divider()
                .padding(.horizontal, Constants.Spacing.cardPadding)
                    
                    // Add Comment
            HStack(spacing: Constants.Spacing.sm) {
                AsyncImage(url: URL(string: Constants.Images.defaultProfileMale)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Constants.Colors.lightGray)
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                
                    HStack {
                        TextField("Add a comment...", text: $commentText)
                            .font(Constants.Fonts.body)
                        
                    if !commentText.isEmpty {
                        Button("Post") {
                            handleComment()
                        }
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.secondaryBackground)
                .cornerRadius(Constants.CornerRadius.pill)
            }
            .padding(.horizontal, Constants.Spacing.cardPadding)
                    
                    // Comments List
                    ForEach(post.comments.prefix(3), id: \.id) { comment in
                        CommentRowView(comment: comment)
                    .padding(.horizontal, Constants.Spacing.cardPadding)
                    }
                    
                    if post.comments.count > 3 {
                        Button("View all \(post.comments.count) comments") {
                            // Handle view all comments
                        }
                .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.primaryBlue)
                .padding(.horizontal, Constants.Spacing.cardPadding)
                .padding(.bottom, Constants.Spacing.md)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func actionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: Constants.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                Text(text)
                    .font(Constants.Fonts.caption1)
            }
            .foregroundColor(color)
        }
    }
    
    private func handleLike() {
        withAnimation(Constants.Animation.professional) {
            isLiked.toggle()
            likeCount += isLiked ? 1 : -1
        }
        postService.likePost(post)
    }
    
    private func handleShare() {
        postService.sharePost(post)
    }
    
    private func handleComment() {
        guard !commentText.isEmpty else { return }
        postService.addComment(to: post, content: commentText)
        commentText = ""
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: Constants.Spacing.sm) {
            AsyncImage(url: URL(string: comment.authorProfileImageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .overlay(
                        Text(comment.authorName.initials)
                            .font(Constants.Fonts.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    )
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                HStack {
                    Text(comment.authorName)
                        .font(Constants.Fonts.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    Text(comment.createdAt.formatForPost())
                        .font(Constants.Fonts.caption2)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Text(comment.content)
                    .font(Constants.Fonts.caption1)
                    .foregroundColor(Constants.Colors.label)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Post Skeleton View
struct PostSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 48, height: 48)
                    .shimmer(isLoading: true)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 120, height: 16)
                        .shimmer(isLoading: true)
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 80, height: 12)
                        .shimmer(isLoading: true)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(height: 16)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(height: 16)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 200, height: 16)
                    .shimmer(isLoading: true)
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
} 