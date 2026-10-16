import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        List {
            if let user = session.user {
                Section("Contact Info") {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                    LabeledContent("Phone", value: user.phone)
                }
            }
            Section("Management Company") {
                LabeledContent("Company", value: session.company?.name ?? "")
                Button("Switch Management Company") { session.company = nil }
            }
            Section {
                Button("Log Out", role: .destructive) { session.logOut() }
            }
        }
        .navigationTitle("Account")
    }
}
