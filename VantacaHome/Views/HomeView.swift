import SwiftUI

struct HomeView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AccountPicker()

                if let account = session.selectedAccount {
                    Card {
                        Text("Current Balance").font(.subheadline).foregroundStyle(Color.vSubtext)
                        Text(account.balance.usd)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundStyle(Color.vText)
                        HStack {
                            Text("Next due \(account.dueDate.formatted(date: .abbreviated, time: .omitted))")
                            Spacer()
                            if account.autoDraftEnabled {
                                Label("Auto-Draft On", systemImage: "checkmark.seal.fill").foregroundStyle(Color.vGreen)
                            }
                        }
                        .font(.footnote)
                        .foregroundStyle(Color.vSubtext)

                        NavigationLink { MakePaymentView() } label: {
                            Text("Make a Payment").fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(Color.vBlue).foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        NavigationLink { AutoDraftView() } label: {
                            Text("Set Up Auto-Draft").fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .foregroundStyle(Color.vBlue)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.vBlue))
                        }
                    }

                    if let latest = session.feed().first {
                        Card {
                            HStack {
                                Text("Latest Announcement").font(.headline).foregroundStyle(Color.vText)
                                Spacer()
                                NavigationLink("See All") { AnnouncementsView() }.font(.subheadline)
                            }
                            NavigationLink {
                                AnnouncementDetailView(announcement: latest)
                            } label: {
                                AnnouncementRow(announcement: latest, isRead: session.isRead(latest))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Card {
                        HStack {
                            Text("Recent Payments").font(.headline).foregroundStyle(Color.vText)
                            Spacer()
                        }
                        ForEach(account.payments.prefix(3)) { PaymentRow(payment: $0) }
                    }
                }
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationTitle(session.company?.community ?? "Home")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccountPicker: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        Menu {
            ForEach(session.accounts) { account in
                Button("\(account.id) - \(account.address)") { session.selectedAccountID = account.id }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Account \(session.selectedAccount?.id ?? "")").font(.caption).foregroundStyle(Color.vSubtext)
                    Text(session.selectedAccount?.address ?? "").font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.vText).lineLimit(1)
                }
                Spacer()
                Image(systemName: "chevron.down").foregroundStyle(Color.vSubtext)
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.vBorder))
        }
    }
}

struct PaymentRow: View {
    let payment: Payment

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(payment.memo).font(.subheadline.weight(.medium)).foregroundStyle(Color.vText)
                Text("\(payment.date.formatted(date: .abbreviated, time: .omitted)) · \(payment.method)")
                    .font(.caption).foregroundStyle(Color.vSubtext)
            }
            Spacer()
            Text(payment.amount.usd).font(.subheadline.weight(.semibold)).foregroundStyle(Color.vText)
        }
        .padding(.vertical, 4)
    }
}
