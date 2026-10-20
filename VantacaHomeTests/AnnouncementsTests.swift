import XCTest
@testable import VantacaHome

@MainActor
final class AnnouncementsTests: XCTestCase {
    private func session() -> AppSession {
        let session = AppSession()
        session.choose(MockData.companies[3])
        return session
    }

    func testFeedShowsPinnedFirstThenNewest() {
        let feed = session().feed()
        XCTAssertTrue(feed[0].isPinned)
        let rest = feed.dropFirst().map(\.date)
        XCTAssertEqual(rest, rest.sorted(by: >))
    }

    func testFeedFiltersByCategory() {
        let feed = session().feed(category: .maintenance)
        XCTAssertFalse(feed.isEmpty)
        XCTAssertTrue(feed.allSatisfy { $0.category == .maintenance })
    }

    func testMarkReadReducesUnreadCount() {
        let session = session()
        let total = session.announcements.count
        XCTAssertEqual(session.unreadAnnouncementCount, total)
        session.markRead(session.announcements[0])
        session.markRead(session.announcements[0])
        XCTAssertEqual(session.unreadAnnouncementCount, total - 1)
        XCTAssertTrue(session.isRead(session.announcements[0]))
    }

    func testLogOutClearsAnnouncements() {
        let session = session()
        session.logOut()
        XCTAssertTrue(session.announcements.isEmpty)
        XCTAssertEqual(session.unreadAnnouncementCount, 0)
    }
}
