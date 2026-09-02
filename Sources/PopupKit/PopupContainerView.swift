import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct PopupContainerView: View {
    let content: PopupContent
    let theme: PopupTheme
    let position: PopupPosition
    let dismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: alignment) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if content.isDismissibleByTapOutside {
                        dismiss()
                    }
                }

            positionedPopupView
                .transition(popupTransition)
        }
        .onAppear {
            #if canImport(UIKit)
            UIAccessibility.post(notification: .screenChanged, argument: content.accessibilityLabel)
            #endif
        }
    }

    private var alignment: Alignment {
        switch position {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        }
    }

    @ViewBuilder
    private var positionedPopupView: some View {
        switch position {
        case .top:
            popupView
                .padding(.horizontal, 32)
                .padding(.top, 24)
        case .center:
            popupView
                .padding(.horizontal, 32)
        case .bottom:
            popupView
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
    }

    private var popupTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }
        switch position {
        case .top:
            return .move(edge: .top).combined(with: .opacity)
        case .center:
            return .scale.combined(with: .opacity)
        case .bottom:
            return .move(edge: .bottom).combined(with: .opacity)
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
