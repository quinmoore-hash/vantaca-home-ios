import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { PaymentHistoryView() }
                .tabItem { Label("Payments", systemImage: "dollarsign.circle") }
            NavigationStack { ProfileView() }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tint(.vBlue)
    }
}
