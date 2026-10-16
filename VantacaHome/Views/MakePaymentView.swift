import SwiftUI

struct MakePaymentView: View {
    @EnvironmentObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var method = MockData.savedCards[0]
    @State private var paymentDate = Date()
    @State private var showConfirmation = false

    private var amountValue: Double? { Double(amount) }

    var body: some View {
        ScrollView {
            Card {
                Text("Account Info").font(.headline).foregroundStyle(Color.vText)
                AccountPicker()
                if let user = session.user {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name); Text(user.email); Text(user.phone)
                    }
                    .font(.subheadline).foregroundStyle(Color.vSubtext)
                }

                Divider().padding(.vertical, 4)

                FieldLabel(text: "Payment Amount")
                HStack(spacing: 2) {
                    Text("$").foregroundStyle(Color.vSubtext)
                    TextField("0.00", text: $amount).keyboardType(.decimalPad)
                }
                .boxed()

                FieldLabel(text: "New or saved payment methods")
                ForEach(MockData.savedCards + ["Pay with new card"], id: \.self) { option in
                    Button { method = option } label: {
                        HStack {
                            Image(systemName: method == option ? "largecircle.fill.circle" : "circle")
                                .foregroundStyle(method == option ? Color.vBlue : Color.vSubtext)
                            Text(option).font(.subheadline).foregroundStyle(Color.vText)
                        }
                    }
                }

                FieldLabel(text: "Payment Date")
                DatePicker("", selection: $paymentDate, in: Date()..., displayedComponents: .date)
                    .labelsHidden()

                PrimaryButton(title: "Continue", disabled: (amountValue ?? 0) <= 0) { showConfirmation = true }
                    .padding(.top, 8)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Make a Payment")
        .onAppear {
            if amount.isEmpty, let balance = session.selectedAccount?.balance {
                amount = String(format: "%.2f", balance)
            }
        }
        .alert("Confirm Payment", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Pay") {
                if let value = amountValue {
                    session.recordPayment(accountID: session.selectedAccountID, amount: value, method: method, date: paymentDate)
                }
                dismiss()
            }
        } message: {
            Text("Pay \((amountValue ?? 0).usd) with \(method)?")
        }
    }
}
