import SwiftUI

struct ForgotPasswordView: View {
    var store = UserStore.shared
    let onReset: (String) -> Void

    @State private var identifier = ""
    @State private var code: String?
    @State private var enteredCode = ""
    @State private var newPassword = ""
    @State private var confirm = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            Card {
                Text("Reset Password")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.vText)

                if let code {
                    Label("Demo mode: no email is sent. Your verification code is \(code).", systemImage: "envelope.badge")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.vNavy)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.vBlue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .accessibilityIdentifier("demoCode")

                    FieldLabel(text: "6-Digit Code")
                    TextField("", text: $enteredCode)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .boxed()
                        .accessibilityIdentifier("resetCode")

                    FieldLabel(text: "New Password")
                    SecureField("", text: $newPassword)
                        .textContentType(.newPassword)
                        .boxed()
                        .accessibilityIdentifier("newPassword")

                    FieldLabel(text: "Confirm New Password")
                    SecureField("", text: $confirm)
                        .textContentType(.newPassword)
                        .boxed()
                        .accessibilityIdentifier("confirmPassword")

                    Text("At least 8 characters, including a number.")
                        .font(.footnote)
                        .foregroundStyle(Color.vSubtext)
                } else {
                    Text("Enter your user name or email and we'll send you a 6-digit code.")
                        .font(.subheadline)
                        .foregroundStyle(Color.vSubtext)

                    FieldLabel(text: "User Name or Email")
                    TextField("", text: $identifier)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .boxed()
                        .accessibilityIdentifier("resetIdentifier")
                }

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.red)
                }

                PrimaryButton(title: code == nil ? "Send Code" : "Reset Password",
                              disabled: code == nil ? identifier.isEmpty : enteredCode.isEmpty || newPassword.isEmpty) {
                    submit()
                }
                .padding(.top, 8)
                .accessibilityIdentifier("resetSubmit")
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func submit() {
        errorMessage = nil
        do {
            if code == nil {
                code = try store.requestPasswordReset(for: identifier)
            } else {
                try store.resetPassword(for: identifier, code: enteredCode, newPassword: newPassword, confirm: confirm)
                onReset(store.user(matching: identifier)?.username ?? identifier)
            }
        } catch {
            errorMessage = (error as? AuthError)?.message ?? "Something went wrong."
        }
    }
}
