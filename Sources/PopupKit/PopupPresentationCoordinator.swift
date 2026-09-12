import SwiftUI

final class PopupPresentationCoordinator: ObservableObject {
    private var activeToken: UUID?
    private var activeDismiss: (() -> Void)?

    func present(token: UUID, dismiss: @escaping () -> Void) {
        if let activeToken, activeToken != token {
            activeDismiss?()
        }
        activeToken = token
        activeDismiss = dismiss
    }

    func clear(token: UUID) {
        if activeToken == token {
            activeToken = nil
            activeDismiss = nil
        }
    }
}

private struct PopupPresentationCoordinatorKey: EnvironmentKey {
    static let defaultValue = PopupPresentationCoordinator()
}

extension EnvironmentValues {
    var popupPresentationCoordinator: PopupPresentationCoordinator {
        get { self[PopupPresentationCoordinatorKey.self] }
        set { self[PopupPresentationCoordinatorKey.self] = newValue }
    }
}
