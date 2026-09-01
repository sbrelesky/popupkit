import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PopupContainerView: View {
    let content: PopupContent
    let theme: PopupTheme
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if content.isDismissibleByTapOutside {
                        dismiss()
                    }
                }

            popupView
                .padding(.horizontal, 32)
                .transition(.scale.combined(with: .opacity))
        }
        .onAppear {
            #if canImport(UIKit)
            UIAccessibility.post(notification: .screenChanged, argument: content.accessibilityLabel)
            #endif
        }
    }

    @ViewBuilder
    private var popupView: some View {
        switch content {
        case .error(let message):
            ErrorPopupView(message: message, theme: theme, dismiss: dismiss)
        case .success(let message):
            SuccessPopupView(message: message, theme: theme, dismiss: dismiss)
        case .loading(let message):
            LoadingPopupView(message: message, theme: theme)
        case .generic(let title, let message, let primaryAction, let secondaryAction):
            GenericPopupView(
                title: title,
                message: message,
                primaryAction: primaryAction,
                secondaryAction: secondaryAction,
                theme: theme
            )
        }
    }
}
