import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: AppSession
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            Card {
                VStack(spacing: 20) {
                    VantacaLogo(size: 72)
                    Text("Welcome! Let's Get Started")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.vText)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)

                FieldLabel(text: "User Name")
                TextField("", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .boxed()
                    .accessibilityIdentifier("username")

                FieldLabel(text: "Password")
                SecureField("", text: $password)
                    .textContentType(.password)
                    .boxed()
                    .accessibilityIdentifier("password")

                Text("Need password help? Visit your homeowner portal via desktop for assistance.")
                    .font(.footnote)
                    .foregroundStyle(Color.vSubtext)

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.red)
                }

                PrimaryButton(title: "Log In", isLoading: isLoading) { logIn() }
                    .padding(.top, 12)
                    .accessibilityIdentifier("login")
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
    }

    private func logIn() {
        errorMessage = nil
        isLoading = true
        Task {
            do {
                let user = try await AuthService.login(username: username, password: password)
                session.signIn(user)
            } catch AuthError.invalidCredentials {
                errorMessage = AuthError.invalidCredentials.errorDescription
            } catch {
                errorMessage = "Something went wrong. Please try again."
            }
            isLoading = false
        }
    }
}
