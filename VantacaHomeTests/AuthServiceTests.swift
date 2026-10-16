import XCTest
@testable import VantacaHome

final class AuthServiceTests: XCTestCase {
    func testLoginSucceedsWithValidCredentials() async throws {
        let user = try await AuthService.login(username: "jpolk", password: "Homeowner1!")
        XCTAssertEqual(user.name, "James Polk")
    }

    func testLoginFailsWithWrongPassword() async {
        do {
            _ = try await AuthService.login(username: "jpolk", password: "wrong")
            XCTFail("Expected failure")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }
}
