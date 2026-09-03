import SwiftUI

public struct PopupTheme: Sendable {
    public var backgroundColor: Color
    public var titleColor: Color
    public var messageColor: Color
    public var accentColor: Color
    public var cornerRadius: CGFloat
    public var errorIcon: String
    public var successIcon: String
    public var loadingTintColor: Color
    public var errorIconColor: Color
    public var successIconColor: Color
    public var titleFont: Font
    public var messageFont: Font

    public init(
        backgroundColor: Color? = nil,
        titleColor: Color = .primary,
        messageColor: Color = .secondary,
        accentColor: Color = .accentColor,
        cornerRadius: CGFloat = 16,
        errorIcon: String = "exclamationmark.triangle.fill",
        successIcon: String = "checkmark.circle.fill",
        loadingTintColor: Color = .accentColor,
        errorIconColor: Color = .red,
        successIconColor: Color = .green,
        titleFont: Font = .headline,
        messageFont: Font = .body
    ) {
        self.backgroundColor = backgroundColor ?? Self.defaultBackgroundColor
        self.titleColor = titleColor
        self.messageColor = messageColor
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.errorIcon = errorIcon
        self.successIcon = successIcon
        self.loadingTintColor = loadingTintColor
        self.errorIconColor = errorIconColor
        self.successIconColor = successIconColor
        self.titleFont = titleFont
        self.messageFont = messageFont
    }

    public static let `default` = PopupTheme()

    /// iOS ships the real intended background; the macOS/AppKit and
    /// generic branches only exist so this package's tests can run
    /// locally via `swift test` on a Mac — PopupKit itself is iOS-only.
    static var defaultBackgroundColor: Color {
        #if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
        #elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.gray.opacity(0.15)
        #endif
    }
}

private struct PopupThemeKey: EnvironmentKey {
    static let defaultValue = PopupTheme.default
}

extension EnvironmentValues {
    public var popupTheme: PopupTheme {
        get { self[PopupThemeKey.self] }
        set { self[PopupThemeKey.self] = newValue }
    }
}

extension View {
    public func popupTheme(_ theme: PopupTheme) -> some View {
        environment(\.popupTheme, theme)
    }
}
