import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { PaymentHistoryView() }
                .tabItem { Label("Payments", systemImage: "dollarsign.circle") }
            if session.user?.isBoardMember == true {
                NavigationStack { BoardView() }
                    .tabItem { Label("Board", systemImage: "building.columns") }
                    .badge(session.pendingApprovalCount)
            }
            NavigationStack { ProfileView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(.vBlue)
    }
}
