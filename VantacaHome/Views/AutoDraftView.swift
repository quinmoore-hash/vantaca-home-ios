import SwiftUI

struct AutoDraftView: View {
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var accountType = "Checking"
    @State private var startDate = Date()
    @State private var accountNumber = ""
    @State private var confirmAccountNumber = ""
    @State private var routingNumber = ""
    @State private var enrolled = false

    private var isValid: Bool {
        !accountNumber.isEmpty && accountNumber == confirmAccountNumber
            && routingNumber.count == 9 && routingNumber.allSatisfy(\.isNumber)
    }

    var body: some View {
        ScrollView {
            Card {
                FieldLabel(text: "Account Type")
                Picker("Account Type", selection: $accountType) {
                    Text("Checking").tag("Checking")
                    Text("Savings").tag("Savings")
                }
                .pickerStyle(.segmented)

                FieldLabel(text: "Start Date")
                DatePicker("", selection: $startDate, in: Date()..., displayedComponents: .date).labelsHidden()

                FieldLabel(text: "\(accountType) Account Number")
                TextField("", text: $accountNumber).keyboardType(.numberPad).boxed()
                FieldLabel(text: "Confirm \(accountType) Account Number")
                TextField("", text: $confirmAccountNumber).keyboardType(.numberPad).boxed()
                FieldLabel(text: "Bank Routing Number")
                TextField("", text: $routingNumber).keyboardType(.numberPad).boxed()

                if let account = session.selectedAccount {
                    Text("These properties will be included in the Auto-Draft:")
                        .font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText).padding(.top, 8)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Association: \(account.association)").font(.caption.weight(.bold))
                        HStack(alignment: .top) {
                            Text(account.id).frame(width: 80, alignment: .leading)
                            Text(account.address)
                        }
                        .font(.caption)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.vBackground)
                }

                PrimaryButton(title: "Enroll in Auto-Draft", disabled: !isValid) {
                    session.enableAutoDraft(accountID: session.selectedAccountID)
                    enrolled = true
                }
                .padding(.top, 8)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Auto-Draft")
        .alert("You're enrolled!", isPresented: $enrolled) {
            Button("Done") { dismiss() }
        } message: {
            Text("Your dues will be drafted automatically starting \(startDate.formatted(date: .abbreviated, time: .omitted)).")
        }
    }
}
