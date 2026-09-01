import Foundation

public struct PopupAction: Identifiable {
    public let id = UUID()
    public let label: String
    public let handler: () -> Void

    public init(label: String, handler: @escaping () -> Void) {
        self.label = label
        self.handler = handler
    }
}

public enum PopupContent {
    case error(message: String)
    case success(message: String)
    case loading(message: String? = nil)
    case generic(title: String, message: String, primaryAction: PopupAction, secondaryAction: PopupAction? = nil)

    public var isDismissibleByTapOutside: Bool {
        switch self {
        case .loading:
            return false
        case .error, .success, .generic:
            return true
        }
    }

    public var accessibilityLabel: String {
        switch self {
        case .error(let message):
            return "Error: \(message)"
        case .success(let message):
            return "Success: \(message)"
        case .loading(let message):
            if let message {
                return "Loading: \(message)"
            }
            return "Loading"
        case .generic(let title, let message, _, _):
            return "\(title): \(message)"
        }
    }
}
