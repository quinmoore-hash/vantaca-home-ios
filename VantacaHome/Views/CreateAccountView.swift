import SwiftUI

struct CreateAccountView: View {
    @EnvironmentObject var session: AppSession
    var store = UserStore.shared

    @State private var accountNumber = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirm = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            Card {
                Text("Create an Account")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.vText)
                Text("Your account number is printed on your HOA statement.")
                    .font(.subheadline)
                    .foregroundStyle(Color.vSubtext)

                FieldLabel(text: "Account Number")
                TextField("e.g. 10017220", text: $accountNumber)
                    .keyboardType(.numberPad)
                    .boxed()
                    .accessibilityIdentifier("accountNumber")

                FieldLabel(text: "Email")
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .boxed()
                    .accessibilityIdentifier("email")

                FieldLabel(text: "User Name")
                TextField("", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .boxed()
                    .accessibilityIdentifier("newUsername")

                FieldLabel(text: "Password")
                SecureField("", text: $password)
                    .textContentType(.newPassword)
                    .boxed()
                    .accessibilityIdentifier("newPassword")

                FieldLabel(text: "Confirm Password")
                SecureField("", text: $confirm)
                    .textContentType(.newPassword)
                    .boxed()
                    .accessibilityIdentifier("confirmPassword")

                Text("At least 8 characters, including a number.")
                    .font(.footnote)
                    .foregroundStyle(Color.vSubtext)

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.red)
                }

                PrimaryButton(title: "Create Account",
                              disabled: [accountNumber, email, username, password, confirm].contains(where: \.isEmpty)) {
                    submit()
                }
                .padding(.top, 8)
                .accessibilityIdentifier("createAccount")
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        errorMessage = nil
        do {
            let user = try store.register(accountNumber: accountNumber, email: email, username: username,
                                          password: password, confirm: confirm)
            session.signIn(user)
        } catch {
            errorMessage = (error as? AuthError)?.message ?? "Something went wrong."
        }
    }
}
