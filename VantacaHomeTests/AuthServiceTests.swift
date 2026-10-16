import XCTest
@testable import VantacaHome

final class AuthServiceTests: XCTestCase {
    func testLoginSucceedsWithValidCredentials() async throws {
        let user = try await AuthService.login(username: "jpolk", password: "Homeowner1!")
        XCTAssertEqual(user.name, "James Polk")
    }

    func testUserNameIgnoresCaseAndSurroundingWhitespace() async throws {
        for username in ["Jpolk", "JPolk", "JPOLK", "jpolk ", " jpolk", "Jpolk ", "\tjpolk\n"] {
            let user = try await AuthService.login(username: username, password: "Homeowner1!")
            XCTAssertEqual(user.name, "James Polk", "Login failed for \"\(username)\"")
        }
    }

    func testLoginFailsWithWrongPassword() async {
        await assertInvalidCredentials(username: "jpolk", password: "wrong")
    }

    func testPasswordIsCaseSensitive() async {
        await assertInvalidCredentials(username: "jpolk", password: "homeowner1!")
        await assertInvalidCredentials(username: "jpolk", password: "HOMEOWNER1!")
    }

    func testLoginFailsWithUnknownUser() async {
        await assertInvalidCredentials(username: "jpolk2", password: "Homeowner1!")
    }

    func testInvalidCredentialsMessageIsHelpful() {
        XCTAssertEqual(AuthError.invalidCredentials.localizedDescription,
                       "Incorrect user name or password. Please try again.")
    }

    private func assertInvalidCredentials(username: String, password: String, line: UInt = #line) async {
        do {
            _ = try await AuthService.login(username: username, password: password)
            XCTFail("Expected failure for \"\(username)\" / \"\(password)\"", line: line)
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials, line: line)
        }
    }
}
