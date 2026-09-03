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

    func test_defaultTheme_hasRedErrorIconColor() {
        XCTAssertEqual(PopupTheme.default.errorIconColor, .red)
    }

    func test_defaultTheme_hasGreenSuccessIconColor() {
        XCTAssertEqual(PopupTheme.default.successIconColor, .green)
    }

    func test_defaultTheme_hasHeadlineTitleFont() {
        XCTAssertEqual(PopupTheme.default.titleFont, .headline)
    }

    func test_defaultTheme_hasBodyMessageFont() {
        XCTAssertEqual(PopupTheme.default.messageFont, .body)
    }
}
