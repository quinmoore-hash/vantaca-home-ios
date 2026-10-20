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

enum AnnouncementCategory: String, CaseIterable, Identifiable {
    case general = "General"
    case maintenance = "Maintenance"
    case event = "Event"
    case board = "Board"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: "megaphone.fill"
        case .maintenance: "wrench.and.screwdriver.fill"
        case .event: "calendar"
        case .board: "person.3.fill"
        }
    }
}

struct Announcement: Identifiable {
    let id: Int
    let title: String
    let body: String
    let author: String
    let date: Date
    let category: AnnouncementCategory
    var isPinned = false
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

    static func announcements() -> [Announcement] {
        [
            Announcement(id: 1, title: "Pool Resurfacing Begins Monday",
                         body: "The community pool will be closed for resurfacing starting Monday and is expected to reopen in two weeks. Thank you for your patience while we complete this project funded by the special assessment.",
                         author: "Professional Management Company", date: date(daysFromNow: -1), category: .maintenance, isPinned: true),
            Announcement(id: 2, title: "Fall Block Party - Saturday 4 PM",
                         body: "Join your neighbors at the clubhouse lawn for food trucks, live music, and a kids' pumpkin patch. Please RSVP with the management office so we can plan for food.",
                         author: "Social Committee", date: date(daysFromNow: -2), category: .event),
            Announcement(id: 3, title: "Board Meeting Minutes Posted",
                         body: "Minutes from the October board meeting are now available. Highlights: the 2027 budget was approved and dues will remain $68/month.",
                         author: "Presidential Hills Board", date: date(daysFromNow: -4), category: .board),
            Announcement(id: 4, title: "Gate Code Changing Nov 1",
                         body: "The front gate access code will change on November 1. Your new code will be emailed to the address on file. Contact the office if you do not receive it.",
                         author: "Professional Management Company", date: date(daysFromNow: -6), category: .general),
            Announcement(id: 5, title: "Landscaping Crew Schedule",
                         body: "Mowing and leaf removal will now take place every Thursday between 8 AM and noon. Please move vehicles off the street where possible.",
                         author: "Grounds Committee", date: date(daysFromNow: -9), category: .maintenance),
            Announcement(id: 6, title: "Welcome New Residents!",
                         body: "Please welcome the families who moved into Constitution Ave this month. Stop by the clubhouse welcome table to say hello.",
                         author: "Social Committee", date: date(daysFromNow: -15), category: .general)
        ]
    }

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
    @Published var announcements: [Announcement] = []
    @Published var readAnnouncementIDs: Set<Int> = []

    var selectedAccount: HomeAccount? {
        accounts.first { $0.id == selectedAccountID }
    }

    var unreadAnnouncementCount: Int {
        announcements.filter { !readAnnouncementIDs.contains($0.id) }.count
    }

    func feed(category: AnnouncementCategory? = nil) -> [Announcement] {
        announcements
            .filter { category == nil || $0.category == category }
            .sorted { ($0.isPinned ? 1 : 0, $0.date) > ($1.isPinned ? 1 : 0, $1.date) }
    }

    func isRead(_ announcement: Announcement) -> Bool {
        readAnnouncementIDs.contains(announcement.id)
    }

    func markRead(_ announcement: Announcement) {
        readAnnouncementIDs.insert(announcement.id)
    }

    func signIn(_ user: User) {
        self.user = user
    }

    func choose(_ company: ManagementCompany) {
        self.company = company
        accounts = MockData.accounts()
        selectedAccountID = accounts.first?.id ?? ""
        announcements = MockData.announcements()
        readAnnouncementIDs = []
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
        announcements = []
        readAnnouncementIDs = []
    }
}
