import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationService: NotificationService
    @State private var selectedFilter = NotificationFilter.all
    @State private var showMarkAllAsRead = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Filter Section
                filterSection
                
                // Content
                contentSection
            }
            .background(Constants.Colors.background)
            .navigationBarHidden(true)
            .onAppear {
                notificationService.fetchNotifications()
            }
        }
        .confirmationDialog("Mark all as read?", isPresented: $showMarkAllAsRead) {
            Button("Mark All as Read") {
                notificationService.markAllAsRead()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will mark all notifications as read.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            Text("Notifications")
                .font(Constants.Fonts.title2)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.label)
            
            Spacer()
            
            HStack(spacing: Constants.Spacing.md) {
                // Mark all as read
                if notificationService.unreadCount > 0 {
                    Button(action: { showMarkAllAsRead = true }) {
                        Image(systemName: "checkmark.circle")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.primaryBlue)
                    }
                }
                
                // Settings
                Button(action: { /* Handle settings */ }) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
        .overlay(
            Divider(), alignment: .bottom
        )
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.md) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    filterButton(filter: filter)
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(.vertical, Constants.Spacing.sm)
    }
    
    private func filterButton(filter: NotificationFilter) -> some View {
        Button(action: { selectedFilter = filter }) {
            HStack(spacing: Constants.Spacing.xs) {
                if filter != .all {
                    Image(systemName: filter.icon)
                        .font(.caption)
                }
                
                Text(filter.title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                
                if filter != .all {
                    let count = filteredNotifications.filter { $0.type == filter.notificationType }.count
                    if count > 0 {
                        Text("\(count)")
                            .font(Constants.Fonts.caption2)
                            .padding(.horizontal, Constants.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(selectedFilter == filter ? .white : Constants.Colors.primaryBlue)
                            .foregroundColor(selectedFilter == filter ? Constants.Colors.primaryBlue : .white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            .background(selectedFilter == filter ? Constants.Colors.primaryBlue : Constants.Colors.secondaryBackground)
            .foregroundColor(selectedFilter == filter ? .white : Constants.Colors.label)
            .cornerRadius(Constants.CornerRadius.large)
        }
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if notificationService.isLoading {
                loadingSection
            } else if filteredNotifications.isEmpty {
                emptyStateSection
            } else {
                notificationsList
            }
        }
    }
    
    // MARK: - Notifications List
    private var notificationsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredNotifications, id: \.id) { notification in
                    NotificationRowView(
                        notification: notification,
                        onTap: {
                            handleNotificationTap(notification)
                        },
                        onDelete: {
                            notificationService.deleteNotification(notification)
                        }
                    )
                    .onAppear {
                        if !notification.isRead {
                            notificationService.markAsRead(notification)
                        }
                    }
                }
            }
        }
        .refreshable {
            await refreshNotifications()
        }
    }
    
    // MARK: - Loading Section
    private var loadingSection: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { _ in
                    NotificationSkeletonView()
                }
            }
        }
    }
    
    // MARK: - Empty State Section
    private var emptyStateSection: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: selectedFilter == .all ? "bell.slash" : selectedFilter.icon)
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text(selectedFilter == .all ? "No notifications" : "No \(selectedFilter.title.lowercased())")
                    .font(Constants.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text(selectedFilter == .all ? "You're all caught up! New notifications will appear here." : "No \(selectedFilter.title.lowercased()) notifications to show.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            if selectedFilter != .all {
                Button("Show All Notifications") {
                    selectedFilter = .all
                }
                .padding(.horizontal, Constants.Spacing.lg)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.primaryBlue)
                .foregroundColor(.white)
                .cornerRadius(Constants.CornerRadius.large)
            }
        }
        .padding(.horizontal, Constants.Spacing.lg)
        .padding(.top, Constants.Spacing.xxl)
    }
    
    // MARK: - Computed Properties
    private var filteredNotifications: [Notification] {
        if selectedFilter == .all {
            return notificationService.notifications
        } else {
            return notificationService.notifications.filter { $0.type == selectedFilter.notificationType }
        }
    }
    
    // MARK: - Actions
    private func handleNotificationTap(_ notification: Notification) {
        // Handle navigation based on notification type
        switch notification.type {
        case .like, .comment, .share:
            // Navigate to post
            print("Navigate to post: \(notification.postId ?? "")")
        case .connectionRequest:
            // Navigate to connection requests
            print("Navigate to connection requests")
        case .connectionAccepted:
            // Navigate to user profile
            print("Navigate to user profile: \(notification.fromUserId ?? "")")
        case .message:
            // Navigate to chat
            print("Navigate to chat with: \(notification.fromUserId ?? "")")
        case .mention:
            // Navigate to post where mentioned
            print("Navigate to mention in post: \(notification.postId ?? "")")
        default:
            break
        }
    }
    
    @MainActor
    private func refreshNotifications() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        notificationService.refreshNotifications()
    }
}

// MARK: - Notification Filter Enum
enum NotificationFilter: String, CaseIterable {
    case all = "all"
    case likes = "likes"
    case comments = "comments"
    case connections = "connections"
    case messages = "messages"
    case mentions = "mentions"
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .likes:
            return "Likes"
        case .comments:
            return "Comments"
        case .connections:
            return "Connections"
        case .messages:
            return "Messages"
        case .mentions:
            return "Mentions"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "bell"
        case .likes:
            return "heart.fill"
        case .comments:
            return "bubble.left.fill"
        case .connections:
            return "person.2.fill"
        case .messages:
            return "message.fill"
        case .mentions:
            return "at"
        }
    }
    
    var notificationType: NotificationType {
        switch self {
        case .all:
            return .like // This won't be used
        case .likes:
            return .like
        case .comments:
            return .comment
        case .connections:
            return .connectionRequest
        case .messages:
            return .message
        case .mentions:
            return .mention
        }
    }
}

// MARK: - Notification Row View
struct NotificationRowView: View {
    let notification: Notification
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.md) {
                // Profile Image or Icon
                if let profileImageURL = notification.fromUserProfileImageURL {
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Constants.Colors.lightGray)
                            .overlay(
                                Text(notification.fromUserName?.initials ?? "")
                                    .font(Constants.Fonts.caption1)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            )
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(notification.type.color).opacity(0.2))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: notification.type.icon)
                            .font(.title3)
                            .foregroundColor(Color(notification.type.color))
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(notification.message)
                        .font(Constants.Fonts.body)
                        .foregroundColor(Constants.Colors.label)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(notification.createdAt.timeAgoDisplay())
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Spacer()
                
                VStack {
                    // Unread indicator
                    if !notification.isRead {
                        Circle()
                            .fill(Constants.Colors.primaryBlue)
                            .frame(width: 8, height: 8)
                    }
                    
                    Spacer()
                    
                    // Action buttons for connection requests
                    if notification.type == .connectionRequest && !notification.actionTaken {
                        connectionActionButtons
                    }
                }
            }
            .padding(Constants.Spacing.md)
            .background(notification.isRead ? Constants.Colors.background : Constants.Colors.lightBlue.opacity(0.1))
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
    
    private var connectionActionButtons: some View {
        HStack(spacing: Constants.Spacing.xs) {
            Button("Accept") {
                // Handle accept
            }
            .font(Constants.Fonts.caption2)
            .padding(.horizontal, Constants.Spacing.sm)
            .padding(.vertical, Constants.Spacing.xs)
            .background(Constants.Colors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(Constants.CornerRadius.small)
            
            Button("Decline") {
                // Handle decline
            }
            .font(Constants.Fonts.caption2)
            .padding(.horizontal, Constants.Spacing.sm)
            .padding(.vertical, Constants.Spacing.xs)
            .background(Constants.Colors.secondaryBackground)
            .foregroundColor(Constants.Colors.label)
            .cornerRadius(Constants.CornerRadius.small)
        }
    }
}

// MARK: - Notification Skeleton View
struct NotificationSkeletonView: View {
    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            Circle()
                .fill(Constants.Colors.lightGray)
                .frame(width: 48, height: 48)
                .shimmer(isLoading: true)
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(height: 16)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 100, height: 12)
                    .shimmer(isLoading: true)
            }
            
            Spacer()
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
    }
}

#Preview {
    NotificationsView()
        .environmentObject(NotificationService())
} 