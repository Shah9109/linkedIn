import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var notificationService = NotificationService()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Network Tab
            NetworkView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "person.2.fill" : "person.2")
                    Text("My Network")
                }
                .tag(1)
            
            // Post Tab
            PostCreationView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.square.fill" : "plus.square")
                    Text("Post")
                }
                .tag(2)
            
            // Jobs Tab
            JobsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "briefcase.fill" : "briefcase")
                    Text("Jobs")
                }
                .tag(3)
            
            // Notifications Tab
            NotificationsView()
                .tabItem {
                    ZStack {
                        Image(systemName: selectedTab == 4 ? "bell.fill" : "bell")
                        
                        if notificationService.unreadCount > 0 {
                            Text("\(notificationService.unreadCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(Constants.Colors.error)
                                .cornerRadius(8)
                                .offset(x: 8, y: -8)
                        }
                    }
                    Text("Notifications")
                }
                .tag(4)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 5 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(5)
        }
        .accentColor(Constants.Colors.primaryBlue)
        .environmentObject(notificationService)
        .onAppear {
            setupTabBarAppearance()
            notificationService.startListeningForNotifications()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Constants.Colors.primaryBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Constants.Colors.primaryBlue),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService())
} 