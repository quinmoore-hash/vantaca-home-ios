import SwiftUI

struct User {
    let username: String
    var password: String
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
    static let seedUsers = [
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

enum AuthError: Error {
    case invalidCredentials
    case userNotFound
    case invalidCode
    case unknownAccount
    case invalidEmail
    case invalidUsername
    case usernameTaken
    case emailTaken
    case weakPassword
    case passwordMismatch

    var message: String {
        switch self {
        case .invalidCredentials: return "System error. Please try again later."
        case .userNotFound: return "We couldn't find a user with that user name or email."
        case .invalidCode: return "That code is incorrect. Please check it and try again."
        case .unknownAccount: return "We couldn't find that account number. It's printed on your HOA statement."
        case .invalidEmail: return "Please enter a valid email address."
        case .invalidUsername: return "User name must be at least 4 characters with no spaces."
        case .usernameTaken: return "That user name is already taken."
        case .emailTaken: return "An account with that email already exists."
        case .weakPassword: return "Password must be at least 8 characters and include a number."
        case .passwordMismatch: return "Passwords do not match."
        }
    }
}

/// In-memory user store (mock backend). State resets when the app restarts.
final class UserStore {
    static let shared = UserStore()

    private(set) var users: [User]
    private var resetCodes: [String: String] = [:]
    private let accountNumbers: Set<String>

    init(users: [User] = MockData.seedUsers, accountNumbers: Set<String> = Set(MockData.accounts().map(\.id))) {
        self.users = users
        self.accountNumbers = accountNumbers
    }

    func authenticate(username: String, password: String) throws -> User {
        guard let user = users.first(where: { $0.username == username && $0.password == password }) else {
            throw AuthError.invalidCredentials
        }
        return user
    }

    /// Looks up a user by user name or email and returns a mock 6-digit code (shown in the UI, no email is sent).
    func requestPasswordReset(for identifier: String) throws -> String {
        guard let user = find(identifier) else { throw AuthError.userNotFound }
        let code = String(format: "%06d", Int.random(in: 0...999_999))
        resetCodes[user.username] = code
        return code
    }

    func resetPassword(for identifier: String, code: String, newPassword: String, confirm: String) throws {
        guard let i = index(of: identifier) else { throw AuthError.userNotFound }
        guard let expected = resetCodes[users[i].username], expected == code.trimmingCharacters(in: .whitespaces) else {
            throw AuthError.invalidCode
        }
        try Self.validate(password: newPassword, confirm: confirm)
        users[i].password = newPassword
        resetCodes[users[i].username] = nil
    }

    func register(accountNumber: String, email: String, username: String, password: String, confirm: String) throws -> User {
        let account = accountNumber.trimmingCharacters(in: .whitespaces)
        let email = email.trimmingCharacters(in: .whitespaces)
        let username = username.trimmingCharacters(in: .whitespaces)
        guard accountNumbers.contains(account) else { throw AuthError.unknownAccount }
        guard email.contains("@"), email.split(separator: "@").last?.contains(".") == true else { throw AuthError.invalidEmail }
        guard username.count >= 4, !username.contains(" ") else { throw AuthError.invalidUsername }
        guard find(username) == nil else { throw AuthError.usernameTaken }
        guard find(email) == nil else { throw AuthError.emailTaken }
        try Self.validate(password: password, confirm: confirm)
        let user = User(username: username, password: password, name: username, email: email, phone: "", isBoardMember: false)
        users.append(user)
        return user
    }

    static func validate(password: String, confirm: String) throws {
        guard password.count >= 8, password.contains(where: \.isNumber) else { throw AuthError.weakPassword }
        guard password == confirm else { throw AuthError.passwordMismatch }
    }

    private func index(of identifier: String) -> Int? {
        let key = identifier.trimmingCharacters(in: .whitespaces).lowercased()
        return users.firstIndex { $0.username.lowercased() == key || $0.email.lowercased() == key }
    }

    func user(matching identifier: String) -> User? {
        index(of: identifier).map { users[$0] }
    }

    private func find(_ identifier: String) -> User? { user(matching: identifier) }
}

enum AuthService {
    static var store = UserStore.shared

    static func login(username: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 600_000_000)
        return try store.authenticate(username: username, password: password)
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
