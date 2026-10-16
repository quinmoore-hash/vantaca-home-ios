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

    static let savedCards = ["Visa XXXX-XXXX-XXXX-1433", "Mastercard XXXX-XXXX-XXXX-0999"]

    private static func date(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        "Incorrect user name or password. Please try again."
    }
}

enum AuthService {
    static func login(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        let username = normalized(username)
        guard let user = MockData.users.first(where: { normalized($0.username) == username && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        return user
    }

    static func normalized(_ username: String) -> String {
        username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

@MainActor
final class AppSession: ObservableObject {
    @Published var user: User?
    @Published var company: ManagementCompany?
    @Published var accounts: [HomeAccount] = []
    @Published var selectedAccountID: String = ""

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
    }
}
