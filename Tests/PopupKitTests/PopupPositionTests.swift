import XCTest
@testable import PopupKit

final class PopupPositionTests: XCTestCase {
    func test_top_dragDismissDirection_isUp() {
        XCTAssertEqual(PopupPosition.top.dragDismissDirection, .up)
    }

    func test_center_dragDismissDirection_isDown() {
        XCTAssertEqual(PopupPosition.center.dragDismissDirection, .down)
    }

    func test_bottom_dragDismissDirection_isDown() {
        XCTAssertEqual(PopupPosition.bottom.dragDismissDirection, .down)
    }
}
