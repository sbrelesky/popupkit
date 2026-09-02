public enum PopupPosition: Sendable, Equatable {
    case top
    case center
    case bottom
}

enum DragDismissDirection: Equatable {
    case up
    case down
}

extension PopupPosition {
    var dragDismissDirection: DragDismissDirection {
        switch self {
        case .top:
            return .up
        case .center, .bottom:
            return .down
        }
    }
}
