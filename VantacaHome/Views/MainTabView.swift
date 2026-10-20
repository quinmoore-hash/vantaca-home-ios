import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { AnnouncementsView() }
                .tabItem { Label("Community", systemImage: "megaphone") }
                .badge(session.unreadAnnouncementCount)
            NavigationStack { PaymentHistoryView() }
                .tabItem { Label("Payments", systemImage: "dollarsign.circle") }
            NavigationStack { ProfileView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(.vBlue)
    }
}
