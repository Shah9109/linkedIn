# LinkedIn-Inspired iOS App

A professional networking iOS application built with SwiftUI that replicates core LinkedIn functionality with a modern, native iOS experience.

## 📱 Features

### Authentication & Profile
- 🔐 Secure signup/login system
- 🔄 Password reset functionality
- 👤 Professional profile management
  - Profile photo upload
  - Bio and headline
  - Experience and education
  - Skills and endorsements
  - Location and contact info

### Home Feed & Content
- 📱 Professional post creation
  - Rich text support
  - Multi-image upload
  - Hashtag suggestions
  - @mentions
  - Professional templates
  - Polls and surveys
- 👍 Post engagement
  - Likes and reactions
  - Comments and replies
  - Share functionality
  - Analytics tracking
- 🎯 Smart feed algorithm
  - Personalized content
  - Trending topics
  - Professional recommendations

### Networking
- 🤝 Connection management
  - Send/receive requests
  - Network suggestions
  - Connection status tracking
- 🔍 Advanced user search
  - Filter by industry, location
  - Professional recommendations
  - "People you may know"
- 📊 Network analytics
  - Growth tracking
  - Connection insights
  - Industry statistics

### Messaging
- 💬 Real-time chat
  - Direct messaging
  - Group conversations
  - Media sharing
  - Read receipts
- 🔔 Push notifications
  - Message alerts
  - Custom notification settings
  - Mute/unmute conversations

### Jobs Portal
- 💼 Job search & discovery
  - Advanced filters
    - Location
    - Experience level
    - Salary range
    - Company size
    - Industry
  - Easy apply
  - Save jobs
  - Job alerts
- 📝 Application management
  - Track applications
  - Quick apply with profile
  - Custom cover letters
  - Resume upload
- 💰 Salary insights
  - Industry benchmarks
  - Location-based data
  - Experience-based ranges

### Settings & Privacy
- ⚙️ Account settings
  - Profile visibility
  - Network preferences
  - Communication settings
- 🔒 Privacy controls
  - Data management
  - Blocked connections
  - Activity broadcast
- 🔔 Notification preferences
  - Custom alerts
  - Email preferences
  - Push notifications

## 🛠 Technical Details

### Architecture
- **Design Pattern**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.6
- **Swift Version**: 5.0

### Key Components
- `Models/`: Data models and business logic
- `Views/`: SwiftUI views and UI components
- `ViewModels/`: View state and business logic
- `Services/`: Network and data services
- `Utils/`: Helper functions and extensions

### Dependencies
- SwiftUI for UI
- Combine for reactive programming
- PhotosUI for image handling
- Firebase (simulated) for backend

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/linkedin-ios.git
```

2. Open the project in Xcode:
```bash
cd linkedin-ios
open linkedIn.xcodeproj
```

3. Build and run the project:
- Select your target device/simulator
- Press ⌘R or click the Play button

## 🎨 Design System

The app follows a professional design system with:
- Consistent typography and spacing
- LinkedIn-inspired color palette
- Modern iOS UI patterns
- Responsive layouts
- Accessibility support

### Colors
- Primary Blue: `#0A66C2`
- Deep Blue: `#004182`
- Light Blue: `#E7F3FF`
- Professional Gray: `#F3F2F0`
- Text Colors:
  - Primary: `#191919`
  - Secondary: `#666666`
  - Tertiary: `#86888A`

### Typography
- Headlines: SF Pro Display
- Body Text: SF Pro Text
- Monospace: SF Mono (for code)

## 🔧 Development

### Code Structure
```
linkedIn/
├── Models/
│   ├── User.swift
│   ├── Post.swift
│   ├── Job.swift
│   └── ...
├── Views/
│   ├── Auth/
│   ├── Home/
│   ├── Network/
│   ├── Jobs/
│   └── ...
├── Services/
│   ├── AuthService.swift
│   ├── PostService.swift
│   └── ...
└── Utils/
    ├── Constants.swift
    └── Extensions.swift
```

### Key Files
- `ContentView.swift`: Main app entry point
- `MainTabView.swift`: Tab-based navigation
- `Constants.swift`: App-wide configuration
- `FirebaseManager.swift`: Backend simulation

## 🚀 Getting Started

1. **Authentication**
   - Sign up with email or demo account
   - Complete profile setup

2. **Profile Setup**
   - Add profile photo
   - Fill professional details
   - Add experience & education

3. **Networking**
   - Find connections
   - Join professional groups
   - Follow industry leaders

4. **Content Creation**
   - Create professional posts
   - Share updates
   - Engage with network

5. **Job Search**
   - Set job preferences
   - Save interesting positions
   - Apply to opportunities

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- SwiftUI and iOS development community
- LinkedIn for inspiration
- Contributors and testers

## 📱 Screenshots

[Add screenshots of key app features here]

## 📞 Contact

For questions or feedback, please reach out to [Your Contact Information]

---

**Note**: This is a demo project for educational purposes and is not affiliated with LinkedIn. 