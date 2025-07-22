import SwiftUI

struct NetworkView: View {
    @StateObject private var connectionService = ConnectionService()
    @State private var selectedSegment = 0
    @State private var searchText = ""
    @State private var showConnectionRequest = false
    @State private var selectedUser: User?
    
    private let segments = ["Discover", "Connections", "Requests"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Segment Control
                segmentControl
                
                // Content
                contentSection
            }
            .background(Constants.Colors.background)
            .navigationBarHidden(true)
            .onAppear {
                connectionService.fetchUsers()
            }
        }
        .sheet(isPresented: $showConnectionRequest) {
            if let user = selectedUser {
                ConnectionRequestView(user: user, connectionService: connectionService)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.sm) {
            HStack {
                Text("My Network")
                    .font(Constants.Fonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.label)
                
                Spacer()
                
                Button(action: { /* Handle invitations */ }) {
                    Image(systemName: "person.badge.plus")
                        .font(.title3)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Constants.Colors.secondaryLabel)
                
                TextField("Search professionals", text: $searchText)
                    .onChange(of: searchText) { query in
                        connectionService.searchUsers(query: query)
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            .background(Constants.Colors.secondaryBackground)
            .cornerRadius(Constants.CornerRadius.medium)
            .padding(.horizontal, Constants.Spacing.md)
            
            Divider()
        }
    }
    
    // MARK: - Segment Control
    private var segmentControl: some View {
        Picker("Network Sections", selection: $selectedSegment) {
            ForEach(0..<segments.count, id: \.self) { index in
                Text(segments[index])
                    .tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.sm)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        TabView(selection: $selectedSegment) {
            // Discover Users
            discoverUsersView
                .tag(0)
            
            // My Connections
            connectionsView
                .tag(1)
            
            // Connection Requests
            requestsView
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(Constants.Animation.medium, value: selectedSegment)
    }
    
    // MARK: - Discover Users View
    private var discoverUsersView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                if connectionService.isLoading {
                    ForEach(0..<5, id: \.self) { _ in
                        UserSkeletonView()
                    }
                } else {
                    ForEach(connectionService.users, id: \.id) { user in
                        UserCardView(
                            user: user,
                            connectionStatus: connectionService.getConnectionStatus(with: user),
                            primaryAction: {
                                selectedUser = user
                                showConnectionRequest = true
                            },
                            secondaryAction: nil
                        )
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.md)
        }
        .refreshable {
            await refreshUsers()
        }
    }
    
    // MARK: - Connections View
    private var connectionsView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                if connectionService.connections.isEmpty {
                    emptyConnectionsView
                } else {
                    ForEach(connectionService.connections, id: \.id) { user in
                        UserCardView(
                            user: user,
                            connectionStatus: .accepted,
                            primaryAction: {
                                // Navigate to profile or start conversation
                            },
                            secondaryAction: {
                                connectionService.removeConnection(user)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.md)
        }
        .refreshable {
            await refreshConnections()
        }
    }
    
    // MARK: - Requests View
    private var requestsView: some View {
        ScrollView {
            LazyVStack(spacing: Constants.Spacing.md) {
                if connectionService.pendingRequests.isEmpty {
                    emptyRequestsView
                } else {
                    ForEach(connectionService.pendingRequests, id: \.id) { request in
                        ConnectionRequestCardView(
                            request: request,
                            onAccept: {
                                connectionService.acceptConnectionRequest(request)
                            },
                            onDecline: {
                                connectionService.declineConnectionRequest(request)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.md)
        }
    }
    
    // MARK: - Empty States
    private var emptyConnectionsView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "person.2.circle")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text("No connections yet")
                    .font(Constants.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Start building your professional network by connecting with colleagues and industry professionals.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
            
            Button("Discover People") {
                selectedSegment = 0
            }
            .padding(.horizontal, Constants.Spacing.lg)
            .padding(.vertical, Constants.Spacing.sm)
            .background(Constants.Colors.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(Constants.CornerRadius.large)
        }
        .padding(.top, Constants.Spacing.xxl)
    }
    
    private var emptyRequestsView: some View {
        VStack(spacing: Constants.Spacing.lg) {
            Image(systemName: "tray.circle")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.secondaryLabel)
            
            VStack(spacing: Constants.Spacing.sm) {
                Text("No pending requests")
                    .font(Constants.Fonts.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.label)
                
                Text("Connection requests from other professionals will appear here.")
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.secondaryLabel)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Constants.Spacing.xxl)
    }
    
    // MARK: - Actions
    @MainActor
    private func refreshUsers() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        connectionService.refreshConnections()
    }
    
    @MainActor
    private func refreshConnections() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        connectionService.refreshConnections()
    }
}

// MARK: - User Card View
struct UserCardView: View {
    let user: User
    let connectionStatus: ConnectionStatus?
    let primaryAction: () -> Void
    let secondaryAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack(alignment: .top, spacing: Constants.Spacing.md) {
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
                                .font(Constants.Fonts.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(user.fullName)
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let headline = user.headline {
                        Text(headline)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(2)
                    }
                    
                    if let location = user.location {
                        HStack {
                            Image(systemName: "location")
                                .font(.caption)
                            Text(location)
                                .font(Constants.Fonts.caption1)
                        }
                        .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    // Mutual connections
                    Text("\(Int.random(in: 0...50)) mutual connections")
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                Spacer()
                
                // More button
                Button(action: { /* More options */ }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
            }
            
            // Skills
            if !user.skills.isEmpty {
                HStack {
                    ForEach(user.skills.prefix(3), id: \.self) { skill in
                        Text(skill)
                            .font(Constants.Fonts.caption2)
                            .padding(.horizontal, Constants.Spacing.sm)
                            .padding(.vertical, Constants.Spacing.xs)
                            .background(Constants.Colors.lightBlue.opacity(0.3))
                            .cornerRadius(Constants.CornerRadius.small)
                    }
                    
                    if user.skills.count > 3 {
                        Text("+\(user.skills.count - 3) more")
                            .font(Constants.Fonts.caption2)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                    }
                    
                    Spacer()
                }
            }
            
            // Action Buttons
            HStack(spacing: Constants.Spacing.md) {
                Button(action: primaryAction) {
                    Text(primaryButtonText)
                        .font(Constants.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(primaryButtonColor)
                        .cornerRadius(Constants.CornerRadius.large)
                }
                
                if let secondaryAction = secondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryButtonText)
                            .font(Constants.Fonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.label)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Constants.Colors.secondaryBackground)
                            .cornerRadius(Constants.CornerRadius.large)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                                    .stroke(Constants.Colors.border, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var primaryButtonText: String {
        switch connectionStatus {
        case .accepted:
            return "Message"
        case .pending:
            return "Pending"
        default:
            return "Connect"
        }
    }
    
    private var primaryButtonColor: Color {
        switch connectionStatus {
        case .pending:
            return Constants.Colors.border
        default:
            return Constants.Colors.primaryBlue
        }
    }
    
    private var secondaryButtonText: String {
        switch connectionStatus {
        case .accepted:
            return "Remove"
        default:
            return "Follow"
        }
    }
}

// MARK: - Connection Request Card View
struct ConnectionRequestCardView: View {
    let request: ConnectionRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack(alignment: .top, spacing: Constants.Spacing.md) {
                // Profile Image
                AsyncImage(url: URL(string: request.fromUser.profileImageURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Constants.Colors.lightGray)
                        .overlay(
                            Text(request.fromUser.fullName.initials)
                                .font(Constants.Fonts.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        )
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Text(request.fromUser.fullName)
                        .font(Constants.Fonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                    
                    if let headline = request.fromUser.headline {
                        Text(headline)
                            .font(Constants.Fonts.body)
                            .foregroundColor(Constants.Colors.secondaryLabel)
                            .lineLimit(2)
                    }
                    
                    Text(request.connection.createdAt.timeAgoDisplay())
                        .font(Constants.Fonts.caption1)
                        .foregroundColor(Constants.Colors.secondaryLabel)
                }
                
                Spacer()
            }
            
            // Request Message
            if let message = request.connection.requestMessage {
                Text(message)
                    .font(Constants.Fonts.body)
                    .foregroundColor(Constants.Colors.label)
                    .padding(Constants.Spacing.sm)
                    .background(Constants.Colors.lightBlue.opacity(0.3))
                    .cornerRadius(Constants.CornerRadius.medium)
            }
            
            // Action Buttons
            HStack(spacing: Constants.Spacing.md) {
                Button(action: onDecline) {
                    Text("Decline")
                        .font(Constants.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.label)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Constants.Colors.secondaryBackground)
                        .cornerRadius(Constants.CornerRadius.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.CornerRadius.large)
                                .stroke(Constants.Colors.border, lineWidth: 1)
                        )
                }
                
                Button(action: onAccept) {
                    Text("Accept")
                        .font(Constants.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Constants.Colors.primaryBlue)
                        .cornerRadius(Constants.CornerRadius.large)
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.background)
        .cornerRadius(Constants.CornerRadius.medium)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - User Skeleton View
struct UserSkeletonView: View {
    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            HStack(alignment: .top, spacing: Constants.Spacing.md) {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 64, height: 64)
                    .shimmer(isLoading: true)
                
                VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 150, height: 20)
                        .shimmer(isLoading: true)
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 200, height: 16)
                        .shimmer(isLoading: true)
                    
                    Rectangle()
                        .fill(Constants.Colors.lightGray)
                        .frame(width: 100, height: 12)
                        .shimmer(isLoading: true)
                }
                
                Spacer()
            }
            
            HStack(spacing: Constants.Spacing.md) {
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(height: 40)
                    .shimmer(isLoading: true)
                
                Rectangle()
                    .fill(Constants.Colors.lightGray)
                    .frame(height: 40)
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
    NetworkView()
} 