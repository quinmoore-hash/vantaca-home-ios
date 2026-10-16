import SwiftUI

struct User {
    let username: String
    let password: String
    let name: String
    let email: String
    let phone: String
    let isBoardMember: Bool
}

struct ManagementCompany: Identifiable, Hashable {
    let id: Int
    let name: String
    let community: String
    let extraCommunities: Int
}

struct Payment: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let method: String
    let memo: String
}

struct HomeAccount: Identifiable {
    let id: String
    let address: String
    let association: String
    var balance: Double
    var monthlyDues: Double
    var dueDate: Date
    var payments: [Payment]
    var autoDraftEnabled = false
}

struct AssociationFinancials {
    let operatingBalance: Double
    let reserveBalance: Double
    let collectedThisMonth: Double
    let budgetThisMonth: Double
    let delinquencyTotal: Double
    let delinquentAccounts: Int

    var collectedRatio: Double { budgetThisMonth > 0 ? min(1, collectedThisMonth / budgetThisMonth) : 0 }
}

enum ApprovalStatus: String {
    case pending = "Pending"
    case approved = "Approved"
    case denied = "Denied"
}

struct ApprovalRequest: Identifiable {
    let id: String
    let kind: String
    let title: String
    let detail: String
    var amount: Double?
    var status: ApprovalStatus = .pending
}

struct CommunityDocument: Identifiable {
    let id: String
    let title: String
    let category: String
    let updated: String
    let body: String
}

enum MockData {
    static let users = [
        User(username: "jpolk", password: "Homeowner1!", name: "James Polk",
             email: "james.polk@vantaca.tst", phone: "(212) 555-1212", isBoardMember: true)
    ]

    static let companies = [
        ManagementCompany(id: 1, name: "Full House Management", community: "Tanner Brownstones", extraCommunities: 0),
        ManagementCompany(id: 2, name: "Community Property Management", community: "Ocean Lakes", extraCommunities: 3),
        ManagementCompany(id: 3, name: "Better Management Team", community: "Magnolia Pines", extraCommunities: 0),
        ManagementCompany(id: 4, name: "Professional Management Company", community: "Presidential Hills", extraCommunities: 10)
    ]

    static func accounts() -> [HomeAccount] {
        [
            HomeAccount(id: "10017220", address: "2021 Pennsylvania Ave Unit 111, Washington, DC 20500",
                        association: "Presidential Hills, Inc", balance: 68.00, monthlyDues: 68.00,
                        dueDate: date(daysFromNow: 12), payments: [
                            Payment(date: date(daysFromNow: -18), amount: 68.00, method: "Visa XXXX-1433", memo: "Monthly Assessment"),
                            Payment(date: date(daysFromNow: -49), amount: 68.00, method: "Visa XXXX-1433", memo: "Monthly Assessment"),
                            Payment(date: date(daysFromNow: -80), amount: 250.00, method: "Checking XXXX-8812", memo: "Special Assessment - Pool"),
                            Payment(date: date(daysFromNow: -80), amount: 68.00, method: "Checking XXXX-8812", memo: "Monthly Assessment")
                        ]),
            HomeAccount(id: "10017221", address: "1600 Constitution Ave Unit 204, Washington, DC 20500",
                        association: "Presidential Hills, Inc", balance: 136.00, monthlyDues: 68.00,
                        dueDate: date(daysFromNow: 12), payments: [
                            Payment(date: date(daysFromNow: -49), amount: 68.00, method: "Mastercard XXXX-0999", memo: "Monthly Assessment")
                        ])
        ]
    }

    static let financials = AssociationFinancials(
        operatingBalance: 142_380.55, reserveBalance: 318_904.12,
        collectedThisMonth: 38_420.00, budgetThisMonth: 46_240.00,
        delinquencyTotal: 12_615.00, delinquentAccounts: 23)

    static func approvals() -> [ApprovalRequest] {
        [
            ApprovalRequest(id: "ARC-1042", kind: "Architectural Request", title: "Backyard fence replacement",
                            detail: "2045 Madison Dr · 6 ft cedar privacy fence"),
            ApprovalRequest(id: "ARC-1045", kind: "Architectural Request", title: "Solar panels on south roof",
                            detail: "1812 Monroe Ct · 14 black-frame panels"),
            ApprovalRequest(id: "INV-5531", kind: "Invoice", title: "GreenScape Landscaping - October",
                            detail: "Common area mowing and mulch", amount: 4_850.00),
            ApprovalRequest(id: "INV-5537", kind: "Invoice", title: "AquaClear Pool Services",
                            detail: "Pool pump motor replacement", amount: 2_195.00)
        ]
    }

    static let documents = [
        CommunityDocument(id: "budget", title: "2027 Operating Budget", category: "Budget", updated: "Sep 30, 2026",
                          body: "Total annual budget: $554,880\n\nLandscaping: $58,200\nPool & Amenities: $41,500\nUtilities: $96,300\nManagement Fees: $72,000\nInsurance: $64,880\nReserve Contribution: $120,000\nRepairs & Maintenance: $102,000\n\nMonthly assessment remains $68.00 per unit."),
        CommunityDocument(id: "bylaws", title: "Association Bylaws", category: "Governing Documents", updated: "Mar 12, 2024",
                          body: "Article III - Board of Directors\n\nThe affairs of the Association shall be managed by a Board of five (5) directors elected by the members. Directors serve staggered two-year terms.\n\nArticle IV - Meetings\n\nThe Board shall meet at least quarterly. A majority of directors constitutes a quorum."),
        CommunityDocument(id: "minutes", title: "Board Meeting Minutes - September", category: "Meeting Minutes", updated: "Sep 18, 2026",
                          body: "Present: J. Polk (President), A. Adams, T. Jefferson, D. Madison\n\n1. Approved August financials.\n2. Reviewed reserve study; pool resurfacing scheduled for spring.\n3. Tabled clubhouse rental policy to October meeting.\n\nMeeting adjourned at 8:12 PM.")
    ]

    static let savedCards = ["Visa XXXX-XXXX-XXXX-1433", "Mastercard XXXX-XXXX-XXXX-0999"]

    private static func date(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
}

enum AuthError: Error {
    case invalidCredentials
}

enum AuthService {
    static func login(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        guard let user = MockData.users.first(where: { $0.username == username && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        return user
    }
}

@MainActor
final class AppSession: ObservableObject {
    @Published var user: User?
    @Published var company: ManagementCompany?
    @Published var accounts: [HomeAccount] = []
    @Published var selectedAccountID: String = ""
    @Published var approvals: [ApprovalRequest] = []

    var selectedAccount: HomeAccount? {
        accounts.first { $0.id == selectedAccountID }
    }

    func signIn(_ user: User) {
        self.user = user
    }

    func choose(_ company: ManagementCompany) {
        self.company = company
        accounts = MockData.accounts()
        selectedAccountID = accounts.first?.id ?? ""
        approvals = user?.isBoardMember == true ? MockData.approvals() : []
    }

    var pendingApprovalCount: Int {
        approvals.filter { $0.status == .pending }.count
    }

    func decide(approvalID: String, approve: Bool) {
        guard let i = approvals.firstIndex(where: { $0.id == approvalID }),
              approvals[i].status == .pending else { return }
        approvals[i].status = approve ? .approved : .denied
    }

    func recordPayment(accountID: String, amount: Double, method: String, date: Date) {
        guard let i = accounts.firstIndex(where: { $0.id == accountID }) else { return }
        accounts[i].balance = max(0, accounts[i].balance - amount)
        accounts[i].payments.insert(Payment(date: date, amount: amount, method: method, memo: "Online Payment"), at: 0)
    }

    func enableAutoDraft(accountID: String) {
        guard let i = accounts.firstIndex(where: { $0.id == accountID }) else { return }
        accounts[i].autoDraftEnabled = true
    }

    func logOut() {
        user = nil
        company = nil
        accounts = []
        approvals = []
    }
}
