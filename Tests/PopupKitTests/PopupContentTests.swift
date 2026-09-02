import XCTest
@testable import PopupKit

final class PopupContentTests: XCTestCase {
    func test_loading_isNotDismissibleByTapOutside() {
        XCTAssertFalse(PopupContent.loading(message: "Please wait").isDismissibleByTapOutside)
    }

    func test_error_isDismissibleByTapOutside() {
        XCTAssertTrue(PopupContent.error(message: "Something went wrong").isDismissibleByTapOutside)
    }

    func test_success_isDismissibleByTapOutside() {
        XCTAssertTrue(PopupContent.success(message: "Saved").isDismissibleByTapOutside)
    }

    func test_generic_isDismissibleByTapOutside() {
        let action = PopupAction(label: "OK") {}
        let content = PopupContent.generic(title: "Confirm", message: "Are you sure?", primaryAction: action)
        XCTAssertTrue(content.isDismissibleByTapOutside)
    }

    func test_error_accessibilityLabel_includesMessage() {
        XCTAssertEqual(
            PopupContent.error(message: "Network unavailable").accessibilityLabel,
            "Error: Network unavailable"
        )
    }

    func test_loading_accessibilityLabel_withoutMessage_fallsBackToPlainLabel() {
        XCTAssertEqual(PopupContent.loading().accessibilityLabel, "Loading")
    }

    func test_loading_accessibilityLabel_withMessage_includesMessage() {
        XCTAssertEqual(
            PopupContent.loading(message: "Uploading").accessibilityLabel,
            "Loading: Uploading"
        )
    }

    func test_error_defaultPosition_isTop() {
        XCTAssertEqual(PopupContent.error(message: "Network unavailable").defaultPosition, .top)
    }

    func test_success_defaultPosition_isTop() {
        XCTAssertEqual(PopupContent.success(message: "Saved").defaultPosition, .top)
    }

    func test_loading_defaultPosition_isCenter() {
        XCTAssertEqual(PopupContent.loading().defaultPosition, .center)
    }

    func test_generic_defaultPosition_isCenter() {
        let action = PopupAction(label: "OK") {}
        let content = PopupContent.generic(title: "Confirm", message: "Are you sure?", primaryAction: action)
        XCTAssertEqual(content.defaultPosition, .center)
    }
}
