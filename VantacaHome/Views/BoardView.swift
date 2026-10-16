import SwiftUI

struct BoardView: View {
    @EnvironmentObject var session: AppSession
    private let financials = MockData.financials

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Card {
                    Text("Financial Snapshot").font(.headline).foregroundStyle(Color.vText)
                    HStack(spacing: 12) {
                        Metric(title: "Operating", value: financials.operatingBalance.usd)
                        Metric(title: "Reserve", value: financials.reserveBalance.usd)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Collected this month").foregroundStyle(Color.vSubtext)
                            Spacer()
                            Text("\(financials.collectedThisMonth.usd) of \(financials.budgetThisMonth.usd)")
                                .fontWeight(.semibold).foregroundStyle(Color.vText)
                        }
                        .font(.footnote)
                        ProgressView(value: financials.collectedRatio).tint(.vGreen)
                    }
                    HStack {
                        Label("Delinquent (\(financials.delinquentAccounts) accounts)", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Spacer()
                        Text(financials.delinquencyTotal.usd).fontWeight(.semibold).foregroundStyle(Color.vText)
                    }
                    .font(.footnote)
                }

                Card {
                    HStack {
                        Text("Pending Approvals").font(.headline).foregroundStyle(Color.vText)
                        Spacer()
                        Text("\(session.pendingApprovalCount) pending").font(.caption).foregroundStyle(Color.vSubtext)
                    }
                    ForEach(session.approvals) { ApprovalRow(request: $0) }
                }

                Card {
                    Text("Community Documents").font(.headline).foregroundStyle(Color.vText)
                    ForEach(MockData.documents) { doc in
                        NavigationLink { DocumentDetailView(document: doc) } label: {
                            HStack {
                                Image(systemName: "doc.text").foregroundStyle(Color.vBlue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(doc.title).font(.subheadline.weight(.medium)).foregroundStyle(Color.vText)
                                    Text("\(doc.category) · Updated \(doc.updated)").font(.caption).foregroundStyle(Color.vSubtext)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundStyle(Color.vSubtext)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle("Board")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct Metric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(Color.vSubtext)
            Text(value).font(.headline).foregroundStyle(Color.vText).minimumScaleFactor(0.7).lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.vBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ApprovalRow: View {
    @EnvironmentObject var session: AppSession
    let request: ApprovalRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(request.kind) · \(request.id)").font(.caption).foregroundStyle(Color.vSubtext)
                    Text(request.title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText)
                    Text(request.detail).font(.caption).foregroundStyle(Color.vSubtext)
                }
                Spacer()
                if let amount = request.amount {
                    Text(amount.usd).font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText)
                }
            }
            if request.status == .pending {
                HStack(spacing: 10) {
                    PrimaryButton(title: "Approve") { session.decide(approvalID: request.id, approve: true) }
                    Button { session.decide(approvalID: request.id, approve: false) } label: {
                        Text("Deny").fontWeight(.semibold)
                            .frame(maxWidth: .infinity, minHeight: 46)
                            .foregroundStyle(.red)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red))
                    }
                }
            } else {
                Label(request.status.rawValue,
                      systemImage: request.status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(request.status == .approved ? Color.vGreen : .red)
            }
            Divider()
        }
    }
}

struct DocumentDetailView: View {
    let document: CommunityDocument

    var body: some View {
        ScrollView {
            Card {
                Text(document.category).font(.caption).foregroundStyle(Color.vSubtext)
                Text(document.title).font(.title3.weight(.bold)).foregroundStyle(Color.vText)
                Text("Updated \(document.updated)").font(.caption).foregroundStyle(Color.vSubtext)
                Divider()
                Text(document.body).font(.body).foregroundStyle(Color.vText)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle(document.category)
        .navigationBarTitleDisplayMode(.inline)
    }
}
