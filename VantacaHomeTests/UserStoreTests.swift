import XCTest
@testable import VantacaHome

final class UserStoreTests: XCTestCase {
    private var store: UserStore!

    override func setUp() {
        store = UserStore()
    }

    func testPasswordResetLetsUserLogInWithNewPassword() throws {
        let code = try store.requestPasswordReset(for: "jpolk")
        XCTAssertEqual(code.count, 6)
        try store.resetPassword(for: "jpolk", code: code, newPassword: "NewPass123", confirm: "NewPass123")

        XCTAssertEqual(try store.authenticate(username: "jpolk", password: "NewPass123").name, "James Polk")
        XCTAssertThrowsError(try store.authenticate(username: "jpolk", password: "Homeowner1!"))
    }

    func testPasswordResetAcceptsEmail() throws {
        let code = try store.requestPasswordReset(for: "James.Polk@vantaca.tst")
        try store.resetPassword(for: "james.polk@vantaca.tst", code: code, newPassword: "NewPass123", confirm: "NewPass123")
        XCTAssertNoThrow(try store.authenticate(username: "jpolk", password: "NewPass123"))
    }

    func testPasswordResetRejectsUnknownUser() {
        XCTAssertThrowsError(try store.requestPasswordReset(for: "nobody")) {
            XCTAssertEqual($0 as? AuthError, .userNotFound)
        }
    }

    func testPasswordResetRejectsWrongCode() throws {
        let code = try store.requestPasswordReset(for: "jpolk")
        let wrong = code == "000000" ? "111111" : "000000"
        XCTAssertThrowsError(try store.resetPassword(for: "jpolk", code: wrong, newPassword: "NewPass123", confirm: "NewPass123")) {
            XCTAssertEqual($0 as? AuthError, .invalidCode)
        }
    }

    func testPasswordResetCodeIsSingleUse() throws {
        let code = try store.requestPasswordReset(for: "jpolk")
        try store.resetPassword(for: "jpolk", code: code, newPassword: "NewPass123", confirm: "NewPass123")
        XCTAssertThrowsError(try store.resetPassword(for: "jpolk", code: code, newPassword: "Other1234", confirm: "Other1234")) {
            XCTAssertEqual($0 as? AuthError, .invalidCode)
        }
    }

    func testPasswordResetValidatesNewPassword() throws {
        let code = try store.requestPasswordReset(for: "jpolk")
        XCTAssertThrowsError(try store.resetPassword(for: "jpolk", code: code, newPassword: "short", confirm: "short")) {
            XCTAssertEqual($0 as? AuthError, .weakPassword)
        }
        XCTAssertThrowsError(try store.resetPassword(for: "jpolk", code: code, newPassword: "NewPass123", confirm: "NewPass124")) {
            XCTAssertEqual($0 as? AuthError, .passwordMismatch)
        }
    }

    func testRegisterCreatesUserThatCanLogIn() throws {
        let user = try store.register(accountNumber: "10017220", email: "jane@example.com", username: "jdoe",
                                      password: "Welcome123", confirm: "Welcome123")
        XCTAssertEqual(user.username, "jdoe")
        XCTAssertEqual(try store.authenticate(username: "jdoe", password: "Welcome123").email, "jane@example.com")
    }

    func testRegisterValidation() {
        let cases: [(String, String, String, String, String, AuthError)] = [
            ("99999999", "jane@example.com", "jdoe", "Welcome123", "Welcome123", .unknownAccount),
            ("10017220", "jane", "jdoe", "Welcome123", "Welcome123", .invalidEmail),
            ("10017220", "jane@example.com", "jd", "Welcome123", "Welcome123", .invalidUsername),
            ("10017220", "jane@example.com", "JPolk", "Welcome123", "Welcome123", .usernameTaken),
            ("10017220", "james.polk@vantaca.tst", "jdoe", "Welcome123", "Welcome123", .emailTaken),
            ("10017220", "jane@example.com", "jdoe", "password", "password", .weakPassword),
            ("10017220", "jane@example.com", "jdoe", "Welcome123", "Welcome124", .passwordMismatch)
        ]
        for (account, email, username, password, confirm, expected) in cases {
            XCTAssertThrowsError(try store.register(accountNumber: account, email: email, username: username,
                                                    password: password, confirm: confirm)) {
                XCTAssertEqual($0 as? AuthError, expected)
            }
        }
        XCTAssertEqual(store.users.count, 1)
    }
}
