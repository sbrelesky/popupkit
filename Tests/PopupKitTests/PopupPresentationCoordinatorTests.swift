import XCTest
@testable import PopupKit

final class PopupPresentationCoordinatorTests: XCTestCase {
    func test_present_firstToken_becomesActive() {
        let coordinator = PopupPresentationCoordinator()
        var dismissCallCount = 0

        coordinator.present(token: UUID()) { dismissCallCount += 1 }

        XCTAssertEqual(dismissCallCount, 0)
    }

    func test_present_secondToken_dismissesFirst() {
        let coordinator = PopupPresentationCoordinator()
        let firstToken = UUID()
        var firstDismissCallCount = 0

        coordinator.present(token: firstToken) { firstDismissCallCount += 1 }
        coordinator.present(token: UUID()) { }

        XCTAssertEqual(firstDismissCallCount, 1)
    }

    func test_clear_activeToken_clearsState() {
        let coordinator = PopupPresentationCoordinator()
        let token = UUID()
        var dismissCallCount = 0

        coordinator.present(token: token) { dismissCallCount += 1 }
        coordinator.clear(token: token)
        coordinator.present(token: token) { dismissCallCount += 1 }

        XCTAssertEqual(dismissCallCount, 0)
    }

    func test_clear_staleToken_isNoOp() {
        let coordinator = PopupPresentationCoordinator()
        let activeToken = UUID()
        let staleToken = UUID()
        var activeDismissCallCount = 0

        coordinator.present(token: activeToken) { activeDismissCallCount += 1 }
        coordinator.clear(token: staleToken)
        coordinator.present(token: UUID()) { }

        XCTAssertEqual(activeDismissCallCount, 1)
    }
}
