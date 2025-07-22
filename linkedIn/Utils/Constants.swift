import SwiftUI
import Foundation

struct Constants {
    
    // MARK: - Colors
    struct Colors {
        // Primary LinkedIn colors
        static let linkedInBlue = Color(red: 0.07, green: 0.4, blue: 0.75) // #0A66C2
        static let primaryBlue = Color(red: 0.07, green: 0.4, blue: 0.75)
        static let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
        static let deepBlue = Color(red: 0.05, green: 0.35, blue: 0.68)
        
        // Professional grays
        static let charcoal = Color(red: 0.15, green: 0.15, blue: 0.15)
        static let darkGray = Color(red: 0.2, green: 0.2, blue: 0.2)
        static let mediumGray = Color(red: 0.5, green: 0.5, blue: 0.5)
        static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
        static let professionalGray = Color(red: 0.98, green: 0.98, blue: 0.98)
        
        // Status colors
        static let success = Color(red: 0.2, green: 0.7, blue: 0.2)
        static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.0)
        static let accent = Color(red: 0.0, green: 0.6, blue: 0.87)
        
        // Premium colors
        static let premiumGold = Color(red: 1.0, green: 0.84, blue: 0.0)
        static let premiumGradientStart = Color(red: 1.0, green: 0.84, blue: 0.0)
        static let premiumGradientEnd = Color(red: 0.8, green: 0.6, blue: 0.0)
        
        // Semantic colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        static let label = Color(.label)
        static let secondaryLabel = Color(.secondaryLabel)
        static let tertiaryLabel = Color(.tertiaryLabel)
        static let border = Color(.separator)
        
        // Card colors
        static let cardBackground = Color(.systemBackground)
        static let cardShadow = Color.black.opacity(0.08)
        static let cardBorder = Color(.systemGray5)
        
        // Action colors
        static let likeRed = Color(red: 0.96, green: 0.26, blue: 0.31)
        static let commentBlue = Color(red: 0.07, green: 0.4, blue: 0.75)
        static let shareGreen = Color(red: 0.18, green: 0.65, blue: 0.28)
        static let sendPurple = Color(red: 0.35, green: 0.34, blue: 0.84)
        
        // Gradients
        static let primaryGradient = LinearGradient(
            colors: [primaryBlue, deepBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let premiumGradient = LinearGradient(
            colors: [premiumGradientStart, premiumGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let backgroundGradient = LinearGradient(
            colors: [professionalGray, background],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 22, weight: .bold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
        
        // Professional fonts
        static let professionalTitle = Font.system(size: 24, weight: .bold, design: .rounded)
        static let professionalHeadline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let professionalBody = Font.system(size: 16, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // Professional spacing
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 28
        static let itemSpacing: CGFloat = 12
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let round: CGFloat = 50
        
        // Professional radius
        static let card: CGFloat = 14
        static let button: CGFloat = 8
        static let pill: CGFloat = 25
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let light = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.15), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        static let card = (color: Color.black.opacity(0.08), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(2))
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
        static let bouncy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)
        static let professional = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
    
    // MARK: - Professional Images (Google Drive URLs)
    struct Images {
        // Profile images
        static let defaultProfileMale = "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face"
        static let defaultProfileFemale = "https://images.unsplash.com/photo-1494790108755-2616c16413f4?w=400&h=400&fit=crop&crop=face"
        static let businessProfile1 = "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&h=400&fit=crop&crop=face"
        static let businessProfile2 = "https://images.unsplash.com/photo-1519244703995-f4e0f30006d5?w=400&h=400&fit=crop&crop=face"
        static let businessProfile3 = "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&h=400&fit=crop&crop=face"
        
        // Company logos
        static let companyLogo1 = "https://images.unsplash.com/photo-1549921296-3b0c1cd7878a?w=200&h=200&fit=crop"
        static let companyLogo2 = "https://images.unsplash.com/photo-1572021335469-31706a17aaef?w=200&h=200&fit=crop"
        static let techCompanyLogo = "https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=200&h=200&fit=crop"
        
        // Post images
        static let businessMeeting = "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=600&h=400&fit=crop"
        static let teamWork = "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=600&h=400&fit=crop"
        static let conference = "https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=600&h=400&fit=crop"
        static let startup = "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop"
        static let technology = "https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&h=400&fit=crop"
        static let office = "https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&h=400&fit=crop"
        
        // Cover photos
        static let professionalCover1 = "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&h=300&fit=crop"
        static let professionalCover2 = "https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&h=300&fit=crop"
        static let networkingCover = "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&h=300&fit=crop"
        
        // Industry images
        static let financeIndustry = "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=250&fit=crop"
        static let healthcareIndustry = "https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400&h=250&fit=crop"
        static let educationIndustry = "https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=400&h=250&fit=crop"
        static let technologyIndustry = "https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&h=250&fit=crop"
    }
    
    // MARK: - Sample Data for Jobs and Content
    struct SampleData {
        static let companies = [
            "Apple", "Google", "Microsoft", "Meta", "Amazon", "Netflix", "Tesla",
            "Spotify", "Uber", "Airbnb", "Stripe", "Figma", "Notion", "Slack",
            "Zoom", "Dropbox", "Adobe", "Salesforce", "Oracle", "IBM", "Intel",
            "NVIDIA", "PayPal", "Square", "Twitter", "Pinterest", "Snapchat",
            "TikTok", "LinkedIn", "GitHub", "Atlassian", "ServiceNow", "Shopify",
            "Coinbase", "Robinhood", "DoorDash", "Instacart", "Lyft", "Palantir",
            "Snowflake", "Databricks", "MongoDB", "Redis", "Elastic", "Docker",
            "Kubernetes", "Jenkins", "GitLab", "CircleCI", "Splunk", "New Relic"
        ]
        
        static let industries = [
            "Technology", "Software Development", "E-commerce", "Financial Services",
            "Healthcare", "Education", "Media & Entertainment", "Automotive",
            "Aerospace", "Biotechnology", "Telecommunications", "Gaming",
            "Artificial Intelligence", "Cybersecurity", "Cloud Computing",
            "Data Analytics", "DevOps", "Mobile Development", "Web Development",
            "Blockchain", "Internet of Things", "Machine Learning", "Robotics",
            "Virtual Reality", "Augmented Reality", "Social Media", "Streaming",
            "Food Delivery", "Transportation", "Real Estate", "Insurance",
            "Consulting", "Marketing", "Sales", "Human Resources", "Legal"
        ]
        
        static let skills = [
            // Programming Languages
            "Swift", "Kotlin", "Java", "JavaScript", "TypeScript", "Python",
            "Go", "Rust", "C++", "C#", "PHP", "Ruby", "Scala", "Dart",
            
            // Mobile Development
            "iOS Development", "Android Development", "React Native", "Flutter",
            "UIKit", "SwiftUI", "Jetpack Compose", "Xamarin", "Ionic",
            
            // Web Development
            "React", "Vue.js", "Angular", "Node.js", "Express.js", "Next.js",
            "HTML", "CSS", "SASS", "Webpack", "Vite", "GraphQL", "REST APIs",
            
            // Cloud & Infrastructure
            "AWS", "Google Cloud", "Azure", "Docker", "Kubernetes", "Terraform",
            "Jenkins", "GitLab CI/CD", "Ansible", "Prometheus", "Grafana",
            
            // Databases
            "MySQL", "PostgreSQL", "MongoDB", "Redis", "Elasticsearch",
            "DynamoDB", "Cassandra", "Neo4j", "SQLite", "Oracle",
            
            // Data Science & ML
            "Machine Learning", "Deep Learning", "TensorFlow", "PyTorch",
            "Scikit-learn", "Pandas", "NumPy", "R", "Tableau", "Power BI",
            
            // Design & UX
            "UI/UX Design", "Figma", "Sketch", "Adobe Creative Suite",
            "Prototyping", "User Research", "Wireframing", "Design Systems",
            
            // Project Management
            "Agile", "Scrum", "Kanban", "Jira", "Confluence", "Notion",
            "Project Management", "Product Management", "Roadmap Planning",
            
            // Business & Marketing
            "Digital Marketing", "SEO", "SEM", "Social Media Marketing",
            "Content Marketing", "Email Marketing", "Analytics", "A/B Testing",
            
            // Soft Skills
            "Leadership", "Communication", "Problem Solving", "Team Collaboration",
            "Critical Thinking", "Time Management", "Adaptability", "Creativity"
        ]
        
        static let jobCategories = [
            "Software Engineering", "Product Management", "Data Science",
            "Design", "Marketing", "Sales", "Operations", "Finance",
            "Human Resources", "Legal", "Customer Success", "DevOps",
            "Security", "Research", "Consulting", "Business Development"
        ]
        
        static let workLocations = [
            "San Francisco, CA", "New York, NY", "Seattle, WA", "Austin, TX",
            "Boston, MA", "Los Angeles, CA", "Chicago, IL", "Denver, CO",
            "Atlanta, GA", "Miami, FL", "Dallas, TX", "Phoenix, AZ",
            "San Diego, CA", "Portland, OR", "Nashville, TN", "Raleigh, NC",
            "Remote", "Hybrid", "London, UK", "Toronto, ON", "Vancouver, BC",
            "Berlin, Germany", "Amsterdam, Netherlands", "Singapore",
            "Tokyo, Japan", "Sydney, Australia", "Tel Aviv, Israel"
        ]
        
        static func randomCompany() -> String {
            return companies.randomElement() ?? "TechCorp"
        }
        
        static func randomIndustry() -> String {
            return industries.randomElement() ?? "Technology"
        }
        
        static func randomSkills(count: Int = 5) -> [String] {
            return Array(skills.shuffled().prefix(count))
        }
        
        static func randomLocation() -> String {
            return workLocations.randomElement() ?? "Remote"
        }
    }
    
    // MARK: - Firebase Collections
    struct FirebaseCollections {
        static let users = "users"
        static let posts = "posts"
        static let connections = "connections"
        static let chatRooms = "chatRooms"
        static let messages = "messages"
        static let notifications = "notifications"
        static let comments = "comments"
    }
    
    // MARK: - Storage Paths
    struct StoragePaths {
        static let userProfiles = "user_profiles"
        static let postImages = "post_images"
        static let postVideos = "post_videos"
        static let chatImages = "chat_images"
        static let chatVideos = "chat_videos"
        static let documents = "documents"
        static let resumes = "resumes"
    }
    
    // MARK: - App Settings
    struct AppSettings {
        static let maxImageUploadSize: Int64 = 10 * 1024 * 1024 // 10MB
        static let maxVideoUploadSize: Int64 = 100 * 1024 * 1024 // 100MB
        static let maxDocumentUploadSize: Int64 = 50 * 1024 * 1024 // 50MB
        static let postsPerPage = 20
        static let connectionsPerPage = 50
        static let messagesPerPage = 50
        static let notificationsPerPage = 30
    }
    
    // MARK: - Dummy Data
    struct DummyCredentials {
        static let demoEmail = "demo@pronet.com"
        static let demoPassword = "demo123"
        static let testUsers = [
            ("john.doe@pronet.com", "password123"),
            ("jane.smith@pronet.com", "password123"),
            ("alex.johnson@pronet.com", "password123"),
            ("sarah.wilson@pronet.com", "password123"),
            ("mike.brown@pronet.com", "password123")
        ]
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let genericError = "Something went wrong. Please try again."
        static let networkError = "Network connection error. Please check your internet connection."
        static let authenticationError = "Authentication failed. Please check your credentials."
        static let invalidEmail = "Please enter a valid email address."
        static let weakPassword = "Password must be at least 6 characters long."
        static let passwordMismatch = "Passwords do not match."
        static let requiredFields = "Please fill in all required fields."
        static let uploadError = "Failed to upload file. Please try again."
        static let permissionError = "Permission denied. Please grant necessary permissions."
    }
    
    // MARK: - Success Messages
    struct SuccessMessages {
        static let profileUpdated = "Profile updated successfully!"
        static let postCreated = "Post created successfully!"
        static let connectionSent = "Connection request sent!"
        static let connectionAccepted = "Connection accepted!"
        static let messageLoaded = "Messages loaded successfully!"
        static let signupSuccess = "Account created successfully!"
        static let loginSuccess = "Welcome back!"
    }
} 