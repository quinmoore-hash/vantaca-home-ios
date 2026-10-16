import SwiftUI

struct PaymentHistoryView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        List {
            Section { AccountPicker().listRowInsets(EdgeInsets()).listRowBackground(Color.clear) }
            Section("Payment History") {
                ForEach(session.selectedAccount?.payments ?? []) { PaymentRow(payment: $0) }
            }
        }
        .navigationTitle("Payments")
    }
}
