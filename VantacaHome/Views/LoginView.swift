import SwiftUI

struct LoginView: View {
    @EnvironmentObject var session: AppSession
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showForgotPassword = false
    @State private var showCreateAccount = false

    var body: some View {
        NavigationStack {
            form
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(isPresented: $showForgotPassword) {
                    ForgotPasswordView { resetUsername in
                        username = resetUsername
                        password = ""
                        errorMessage = nil
                        successMessage = "Password updated. Log in with your new password."
                        showForgotPassword = false
                    }
                }
                .navigationDestination(isPresented: $showCreateAccount) {
                    CreateAccountView()
                }
        }
    }

    private var form: some View {
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

                if let successMessage {
                    Label(successMessage, systemImage: "checkmark.circle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.vGreen)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.vGreen.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .accessibilityIdentifier("successBanner")
                }

                FieldLabel(text: "User Name")
                TextField("", text: $username)
                    .textContentType(.username)
                    .boxed()
                    .accessibilityIdentifier("username")

                FieldLabel(text: "Password")
                SecureField("", text: $password)
                    .textContentType(.password)
                    .boxed()
                    .accessibilityIdentifier("password")

                Button("Forgot password?") { showForgotPassword = true }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.vBlue)
                    .accessibilityIdentifier("forgotPassword")

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.red)
                }

                PrimaryButton(title: "Log In", isLoading: isLoading) { logIn() }
                    .padding(.top, 12)
                    .accessibilityIdentifier("login")

                HStack(spacing: 4) {
                    Text("New to Vantaca Home?").foregroundStyle(Color.vSubtext)
                    Button("Create an account") { showCreateAccount = true }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.vBlue)
                        .accessibilityIdentifier("createAccountLink")
                }
                .font(.footnote)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
    }

    private func logIn() {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        Task {
            do {
                let user = try await AuthService.login(username: username, password: password)
                session.signIn(user)
            } catch {
                errorMessage = "System error. Please try again later."
            }
            isLoading = false
        }
    }
}
