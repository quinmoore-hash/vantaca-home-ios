import SwiftUI

@main
struct VantacaHomeApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        if session.user == nil {
            LoginView()
        } else if session.company == nil {
            SelectCompanyView()
        } else {
            MainTabView()
        }
    }
}
