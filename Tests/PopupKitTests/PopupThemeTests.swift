import XCTest
@testable import PopupKit

final class PopupThemeTests: XCTestCase {
    func test_defaultTheme_hasPositiveCornerRadius() {
        XCTAssertGreaterThan(PopupTheme.default.cornerRadius, 0)
    }

    func test_defaultTheme_hasNonEmptyIcons() {
        XCTAssertFalse(PopupTheme.default.errorIcon.isEmpty)
        XCTAssertFalse(PopupTheme.default.successIcon.isEmpty)
    }
}
