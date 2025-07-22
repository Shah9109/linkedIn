import Foundation
import Combine

class PostService: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseManager = FirebaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var postCache: [String: Post] = [:]
    private var currentPage = 0
    private let pageSize = 20
    private var hasMorePosts = true
    
    // Analytics tracking
    @Published var analytics: PostAnalytics = PostAnalytics()
    
    init() {
        setupDummyData()
    }
    
    // MARK: - Post Management
    func fetchPosts() {
        guard !isLoading && hasMorePosts else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call with enhanced data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            let newPosts = self.generateProfessionalPosts()
            
            if self.currentPage == 0 {
                self.posts = newPosts
            } else {
                self.posts.append(contentsOf: newPosts)
            }
            
            self.currentPage += 1
            self.hasMorePosts = newPosts.count == self.pageSize
            self.cacheNewPosts(newPosts)
            self.updateAnalytics()
            
            self.isLoading = false
        }
    }
    
    func refreshPosts() {
        currentPage = 0
        hasMorePosts = true
        postCache.removeAll()
        fetchPosts()
    }
    
    func createPost(content: String, imageURLs: [String] = [], videoURL: String? = nil) {
        guard let currentUser = firebaseManager.currentUser else { return }
        
        let newPost = Post(
            authorId: currentUser.id,
            authorName: currentUser.fullName,
            content: content
        )
        
        // Enhanced post creation with professional features
        var enhancedPost = newPost
        enhancedPost.authorProfileImageURL = currentUser.profileImageURL ?? Constants.Images.defaultProfileMale
        enhancedPost.authorHeadline = currentUser.headline
        enhancedPost.imageURLs = imageURLs
        enhancedPost.videoURL = videoURL
        enhancedPost.hashtags = content.extractHashtags()
        enhancedPost.mentions = content.extractMentions()
        
        // Add to beginning of posts list
        DispatchQueue.main.async { [weak self] in
            self?.posts.insert(enhancedPost, at: 0)
            self?.cachePost(enhancedPost)
            self?.trackPostCreation(enhancedPost)
        }
    }
    
    func updatePost(_ post: Post, newContent: String) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        var updatedPost = post
        updatedPost.content = newContent
        updatedPost.updatedAt = Date()
        updatedPost.isEdited = true
        updatedPost.hashtags = newContent.extractHashtags()
        updatedPost.mentions = newContent.extractMentions()
        
        posts[index] = updatedPost
        cachePost(updatedPost)
    }
    
    func deletePost(_ post: Post) {
        posts.removeAll { $0.id == post.id }
        postCache.removeValue(forKey: post.id)
        trackPostDeletion(post)
    }
    
    // MARK: - Engagement Actions
    func likePost(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }),
              let userId = firebaseManager.currentUser?.id else { return }
        
        var updatedPost = posts[index]
        
        if updatedPost.isLikedBy(userId: userId) {
            updatedPost.likes.removeAll { $0 == userId }
        } else {
            updatedPost.likes.append(userId)
            trackEngagement(.like, postId: post.id)
        }
        
        posts[index] = updatedPost
        cachePost(updatedPost)
        
        // Simulate haptic feedback
        simulateHapticFeedback(.light)
    }
    
    func sharePost(_ post: Post) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        var updatedPost = posts[index]
        updatedPost.shares += 1
        
        posts[index] = updatedPost
        cachePost(updatedPost)
        trackEngagement(.share, postId: post.id)
        
        // Simulate sharing success
        simulateHapticFeedback(.success)
    }
    
    func addComment(to post: Post, content: String) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }),
              let currentUser = firebaseManager.currentUser else { return }
        
        let comment = Comment(
            authorId: currentUser.id,
            authorName: currentUser.fullName,
            content: content
        )
        
        var updatedComment = comment
        updatedComment.authorProfileImageURL = currentUser.profileImageURL
        
        var updatedPost = posts[index]
        updatedPost.comments.append(updatedComment)
        
        posts[index] = updatedPost
        cachePost(updatedPost)
        trackEngagement(.comment, postId: post.id)
    }
    
    func likeComment(_ comment: Comment, in post: Post) {
        guard let postIndex = posts.firstIndex(where: { $0.id == post.id }),
              let commentIndex = posts[postIndex].comments.firstIndex(where: { $0.id == comment.id }),
              let userId = firebaseManager.currentUser?.id else { return }
        
        var updatedComment = posts[postIndex].comments[commentIndex]
        
        if updatedComment.likes.contains(userId) {
            updatedComment.likes.removeAll { $0 == userId }
        } else {
            updatedComment.likes.append(userId)
        }
        
        posts[postIndex].comments[commentIndex] = updatedComment
        cachePost(posts[postIndex])
    }
    
    // MARK: - Advanced Features
    func searchPosts(query: String) -> [Post] {
        return posts.filter { post in
            post.content.localizedCaseInsensitiveContains(query) ||
            post.authorName.localizedCaseInsensitiveContains(query) ||
            post.hashtags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func getPostsByHashtag(_ hashtag: String) -> [Post] {
        return posts.filter { post in
            post.hashtags.contains { $0.lowercased() == hashtag.lowercased() }
        }
    }
    
    func getTrendingHashtags() -> [(hashtag: String, count: Int)] {
        var hashtagCounts: [String: Int] = [:]
        
        posts.forEach { post in
            post.hashtags.forEach { hashtag in
                hashtagCounts[hashtag, default: 0] += 1
            }
        }
        
        return hashtagCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (hashtag: $0.key, count: $0.value) }
    }
    
    func getRecommendedPosts(for userId: String) -> [Post] {
        // Simple recommendation based on user's interactions
        let userInteractedHashtags = getUserInteractionHashtags(userId: userId)
        
        return posts.filter { post in
            !post.hashtags.isEmpty &&
            post.hashtags.contains { userInteractedHashtags.contains($0) }
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    // MARK: - Analytics and Reporting
    func getPostAnalytics(for postId: String) -> PostDetailAnalytics? {
        guard let post = getPost(by: postId) else { return nil }
        
        let impressions = Int.random(in: (post.likeCount * 10)...(post.likeCount * 50))
        let engagementRate = Double(post.likeCount + post.commentCount + post.shares) / Double(impressions) * 100
        
        return PostDetailAnalytics(
            postId: postId,
            impressions: impressions,
            likes: post.likeCount,
            comments: post.commentCount,
            shares: post.shares,
            engagementRate: engagementRate,
            demographics: generateDemographics(),
            viewsByHour: generateHourlyViews()
        )
    }
    
    func reportPost(_ post: Post, reason: ReportReason) {
        // Simulate reporting functionality
        print("Post \(post.id) reported for: \(reason.rawValue)")
        trackUserAction(.report, postId: post.id)
    }
    
    func savePost(_ post: Post) {
        // Simulate saving post for later
        print("Post \(post.id) saved")
        trackUserAction(.save, postId: post.id)
    }
    
    // MARK: - Content Moderation
    func moderateContent(_ content: String) -> ContentModerationResult {
        // Simple content moderation
        let inappropriateWords = ["spam", "fake", "scam", "inappropriate"]
        let containsInappropriate = inappropriateWords.contains { word in
            content.lowercased().contains(word)
        }
        
        let profanityScore = containsInappropriate ? 0.8 : 0.1
        let spamScore = content.count < 10 ? 0.7 : 0.1
        
        return ContentModerationResult(
            isApproved: profanityScore < 0.5 && spamScore < 0.5,
            profanityScore: profanityScore,
            spamScore: spamScore,
            suggestedActions: profanityScore > 0.5 ? ["review_content"] : []
        )
    }
    
    // MARK: - Private Helper Methods
    private func setupDummyData() {
        // Initialize with some professional demo posts
        generateInitialPosts()
    }
    
    private func generateInitialPosts() {
        let professionalPosts = [
            createDemoPost(
                author: "Sarah Johnson",
                headline: "Senior Product Manager at Microsoft",
                content: "Excited to share that our team just launched a groundbreaking AI feature that will transform how professionals collaborate! The journey from concept to reality has been incredible. 🚀\n\n#Innovation #AI #ProductManagement #Microsoft #TeamWork",
                imageURL: Constants.Images.businessMeeting,
                likes: 234,
                comments: 45,
                shares: 12
            ),
            createDemoPost(
                author: "David Chen",
                headline: "Tech Lead at Google",
                content: "Just finished an amazing 3-day hackathon where we built solutions for sustainable technology. The creativity and passion of developers worldwide continues to inspire me! 🌱💡\n\n#Hackathon #Sustainability #Technology #Innovation #Google",
                imageURL: Constants.Images.technology,
                likes: 189,
                comments: 32,
                shares: 8
            ),
            createDemoPost(
                author: "Emily Rodriguez",
                headline: "Marketing Director at Startup Inc.",
                content: "Reflecting on Q4 results: 300% growth in user acquisition and 95% customer satisfaction rate! This wouldn't be possible without our incredible team and the trust our customers place in us. 📈✨\n\n#Growth #Marketing #Startup #CustomerSuccess #TeamWin",
                imageURL: Constants.Images.conference,
                likes: 156,
                comments: 28,
                shares: 15
            )
        ]
        
        self.posts = professionalPosts
    }
    
    private func generateProfessionalPosts() -> [Post] {
        let authors = [
            ("Michael Smith", "Software Engineer at Apple", Constants.Images.businessProfile1),
            ("Lisa Wang", "Data Scientist at Netflix", Constants.Images.businessProfile2),
            ("James Wilson", "UX Designer at Adobe", Constants.Images.businessProfile3),
            ("Rachel Kim", "Sales Director at Salesforce", Constants.Images.defaultProfileFemale),
            ("Tom Anderson", "Operations Manager at Tesla", Constants.Images.defaultProfileMale)
        ]
        
        let professionalContent = [
            "Just completed a major project milestone! The collaboration between cross-functional teams has been outstanding. #TeamWork #ProjectManagement #Success",
            "Attended an incredible industry conference today. The insights on AI and machine learning were game-changing! 🧠💡 #AI #MachineLearning #Conference",
            "Proud to announce that our team achieved 99.9% uptime this quarter! Reliability and performance are at the heart of everything we do. #Performance #Engineering #Quality",
            "Launching our new mentorship program next month. Excited to help the next generation of professionals grow! 🌱 #Mentorship #Leadership #Growth",
            "The future of work is remote-first, and we're leading the charge. Our productivity has increased 40% since going fully distributed! #RemoteWork #Productivity #Future"
        ]
        
        return (0..<pageSize).map { index in
            let author = authors[index % authors.count]
            let content = professionalContent[index % professionalContent.count]
            let imageURLs = [Constants.Images.businessMeeting, Constants.Images.teamWork, Constants.Images.office, Constants.Images.startup]
            
            return createDemoPost(
                author: author.0,
                headline: author.1,
                content: content,
                imageURL: index % 3 == 0 ? imageURLs.randomElement()! : nil,
                likes: Int.random(in: 15...250),
                comments: Int.random(in: 2...45),
                shares: Int.random(in: 0...25),
                profileImageURL: author.2
            )
        }
    }
    
    private func createDemoPost(
        author: String,
        headline: String,
        content: String,
        imageURL: String? = nil,
        likes: Int = 0,
        comments: Int = 0,
        shares: Int = 0,
        profileImageURL: String = Constants.Images.defaultProfileMale
    ) -> Post {
        var post = Post(
            authorId: UUID().uuidString,
            authorName: author,
            content: content
        )
        
        post.authorHeadline = headline
        post.authorProfileImageURL = profileImageURL
        post.createdAt = Date().addingTimeInterval(-TimeInterval.random(in: 0...(7*24*3600))) // Random date within last week
        
        if let imageURL = imageURL {
            post.imageURLs = [imageURL]
        }
        
        // Add realistic likes
        post.likes = (0..<likes).map { _ in UUID().uuidString }
        post.shares = shares
        
        // Add realistic comments
        let commentAuthors = ["Alex Thompson", "Maria Garcia", "John Doe", "Jane Smith", "Robert Johnson"]
        let commentContents = [
            "Great insights! Thanks for sharing this.",
            "Congratulations on this achievement! 🎉",
            "This is exactly what I needed to read today.",
            "Love the perspective you've shared here.",
            "Keep up the excellent work! 👏"
        ]
        
        post.comments = (0..<comments).map { index in
            Comment(
                authorId: UUID().uuidString,
                authorName: commentAuthors[index % commentAuthors.count],
                content: commentContents[index % commentContents.count]
            )
        }
        
        post.hashtags = content.extractHashtags()
        
        return post
    }
    
    private func cachePost(_ post: Post) {
        postCache[post.id] = post
    }
    
    private func cacheNewPosts(_ posts: [Post]) {
        posts.forEach { cachePost($0) }
    }
    
    private func getPost(by id: String) -> Post? {
        return postCache[id] ?? posts.first { $0.id == id }
    }
    
    private func getUserInteractionHashtags(userId: String) -> [String] {
        // Simulate user interaction history
        return ["#Technology", "#Innovation", "#Leadership", "#Growth"]
    }
    
    private func simulateHapticFeedback(_ type: HapticFeedbackType) {
        // In a real app, this would trigger haptic feedback
        print("Haptic feedback: \(type)")
    }
    
    // MARK: - Analytics Tracking
    private func updateAnalytics() {
        let totalPosts = posts.count
        let totalLikes = posts.reduce(0) { $0 + $1.likeCount }
        let totalComments = posts.reduce(0) { $0 + $1.commentCount }
        let totalShares = posts.reduce(0) { $0 + $1.shares }
        
        analytics = PostAnalytics(
            totalPosts: totalPosts,
            totalLikes: totalLikes,
            totalComments: totalComments,
            totalShares: totalShares,
            averageEngagement: totalPosts > 0 ? Double(totalLikes + totalComments + totalShares) / Double(totalPosts) : 0,
            topHashtags: getTrendingHashtags().prefix(5).map { $0.hashtag }
        )
    }
    
    private func trackPostCreation(_ post: Post) {
        print("📊 Analytics: Post created - \(post.id)")
    }
    
    private func trackPostDeletion(_ post: Post) {
        print("📊 Analytics: Post deleted - \(post.id)")
    }
    
    private func trackEngagement(_ type: EngagementType, postId: String) {
        print("📊 Analytics: \(type.rawValue) on post \(postId)")
    }
    
    private func trackUserAction(_ action: UserAction, postId: String) {
        print("📊 Analytics: User \(action.rawValue) on post \(postId)")
    }
    
    private func generateDemographics() -> PostDemographics {
        PostDemographics(
            ageGroups: [
                "18-24": Int.random(in: 10...25),
                "25-34": Int.random(in: 30...45),
                "35-44": Int.random(in: 20...35),
                "45+": Int.random(in: 5...20)
            ],
            locations: [
                "United States": Int.random(in: 40...60),
                "Europe": Int.random(in: 20...35),
                "Asia": Int.random(in: 15...30),
                "Other": Int.random(in: 5...15)
            ],
            industries: [
                "Technology": Int.random(in: 30...50),
                "Finance": Int.random(in: 15...25),
                "Healthcare": Int.random(in: 10...20),
                "Other": Int.random(in: 15...25)
            ]
        )
    }
    
    private func generateHourlyViews() -> [Int] {
        return (0..<24).map { _ in Int.random(in: 5...50) }
    }
}

// MARK: - Supporting Models
struct PostAnalytics {
    let totalPosts: Int
    let totalLikes: Int
    let totalComments: Int
    let totalShares: Int
    let averageEngagement: Double
    let topHashtags: [String]
    
    init() {
        self.totalPosts = 0
        self.totalLikes = 0
        self.totalComments = 0
        self.totalShares = 0
        self.averageEngagement = 0
        self.topHashtags = []
    }
    
    init(totalPosts: Int, totalLikes: Int, totalComments: Int, totalShares: Int, averageEngagement: Double, topHashtags: [String]) {
        self.totalPosts = totalPosts
        self.totalLikes = totalLikes
        self.totalComments = totalComments
        self.totalShares = totalShares
        self.averageEngagement = averageEngagement
        self.topHashtags = topHashtags
    }
}

struct PostDetailAnalytics {
    let postId: String
    let impressions: Int
    let likes: Int
    let comments: Int
    let shares: Int
    let engagementRate: Double
    let demographics: PostDemographics
    let viewsByHour: [Int]
}

struct PostDemographics {
    let ageGroups: [String: Int]
    let locations: [String: Int]
    let industries: [String: Int]
}

struct ContentModerationResult {
    let isApproved: Bool
    let profanityScore: Double
    let spamScore: Double
    let suggestedActions: [String]
}

enum EngagementType: String {
    case like = "like"
    case comment = "comment"
    case share = "share"
}

enum UserAction: String {
    case report = "report"
    case save = "save"
    case follow = "follow"
    case unfollow = "unfollow"
}

enum ReportReason: String, CaseIterable {
    case spam = "spam"
    case harassment = "harassment"
    case inappropriate = "inappropriate"
    case misinformation = "misinformation"
    case copyright = "copyright"
    case other = "other"
    
    var title: String {
        switch self {
        case .spam:
            return "Spam"
        case .harassment:
            return "Harassment or bullying"
        case .inappropriate:
            return "Inappropriate content"
        case .misinformation:
            return "False information"
        case .copyright:
            return "Intellectual property violation"
        case .other:
            return "Other"
        }
    }
}

enum HapticFeedbackType {
    case light, medium, heavy, success, warning, error
} 