import XCTest
@testable import VantacaHome

@MainActor
final class BoardApprovalTests: XCTestCase {
    private func boardSession() -> AppSession {
        let session = AppSession()
        session.signIn(MockData.users[0])
        session.choose(MockData.companies[3])
        return session
    }

    func testBoardMemberStartsWithAllApprovalsPending() {
        let session = boardSession()
        XCTAssertFalse(session.approvals.isEmpty)
        XCTAssertEqual(session.pendingApprovalCount, session.approvals.count)
    }

    func testApproveAndDenyUpdateStatusInPlace() {
        let session = boardSession()
        let first = session.approvals[0].id
        let second = session.approvals[1].id

        session.decide(approvalID: first, approve: true)
        session.decide(approvalID: second, approve: false)

        XCTAssertEqual(session.approvals[0].status, .approved)
        XCTAssertEqual(session.approvals[1].status, .denied)
        XCTAssertEqual(session.pendingApprovalCount, session.approvals.count - 2)
    }

    func testDecisionIsFinal() {
        let session = boardSession()
        let id = session.approvals[0].id
        session.decide(approvalID: id, approve: true)
        session.decide(approvalID: id, approve: false)
        XCTAssertEqual(session.approvals[0].status, .approved)
    }

    func testUnknownIDIsIgnored() {
        let session = boardSession()
        session.decide(approvalID: "nope", approve: true)
        XCTAssertEqual(session.pendingApprovalCount, session.approvals.count)
    }

    func testNonBoardMemberHasNoApprovals() {
        let session = AppSession()
        session.signIn(User(username: "resident", password: "x", name: "Resident", email: "", phone: "", isBoardMember: false))
        session.choose(MockData.companies[3])
        XCTAssertTrue(session.approvals.isEmpty)
    }

    func testLogOutClearsApprovals() {
        let session = boardSession()
        session.logOut()
        XCTAssertTrue(session.approvals.isEmpty)
    }

    func testCollectedRatio() {
        let f = MockData.financials
        XCTAssertEqual(f.collectedRatio, f.collectedThisMonth / f.budgetThisMonth, accuracy: 0.0001)
    }
}
