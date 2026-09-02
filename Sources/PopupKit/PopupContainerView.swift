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
    @State private var dragOffset: CGFloat = 0

    private let dismissThreshold: CGFloat = 80

    var body: some View {
        ZStack(alignment: alignment) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    if content.isDismissibleByTapOutside {
                        dismiss()
                    }
                }

            draggablePopupView
                .transition(popupTransition)
        }
        .onAppear {
            #if canImport(UIKit)
            UIAccessibility.post(notification: .screenChanged, argument: content.accessibilityLabel)
            #endif
        }
    }

    @ViewBuilder
    private var draggablePopupView: some View {
        if content.isDismissibleByTapOutside {
            positionedPopupView
                .offset(y: dragOffset)
                .gesture(dragGesture)
        } else {
            positionedPopupView
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = rubberBandedOffset(for: value.translation.height)
            }
            .onEnded { value in
                let distance = signedAllowedTranslation(value.translation.height)
                let predicted = signedAllowedTranslation(value.predictedEndTranslation.height)
                if distance > dismissThreshold || predicted > dismissThreshold {
                    dismiss()
                } else {
                    withAnimation(.interactiveSpring()) {
                        dragOffset = 0
                    }
                }
            }
    }

    /// Projects a raw drag translation onto the popup's single allowed
    /// dismiss axis. Positive means "moving toward dismiss."
    private func signedAllowedTranslation(_ rawTranslation: CGFloat) -> CGFloat {
        switch position.dragDismissDirection {
        case .up: return -rawTranslation
        case .down: return rawTranslation
        }
    }

    /// Follows the finger 1:1 while dragging toward the dismiss direction;
    /// resists (rubber-bands) while dragging away from it.
    private func rubberBandedOffset(for rawTranslation: CGFloat) -> CGFloat {
        signedAllowedTranslation(rawTranslation) >= 0 ? rawTranslation : rawTranslation * 0.2
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
                .padding(.horizontal, 8)
                .padding(.top, 24)
        case .center:
            popupView
                .padding(.horizontal, 32)
        case .bottom:
            popupView
                .padding(.horizontal, 8)
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
            if position == .center {
                ErrorPopupView(message: message, theme: theme, dismiss: dismiss)
            } else {
                PopupBannerView(
                    icon: theme.errorIcon,
                    iconColor: .red,
                    message: message,
                    theme: theme,
                    isDismissible: true,
                    accessibilityLabel: content.accessibilityLabel,
                    dismiss: dismiss
                )
            }
        case .success(let message):
            if position == .center {
                SuccessPopupView(message: message, theme: theme, dismiss: dismiss)
            } else {
                PopupBannerView(
                    icon: theme.successIcon,
                    iconColor: .green,
                    message: message,
                    theme: theme,
                    isDismissible: true,
                    accessibilityLabel: content.accessibilityLabel,
                    dismiss: dismiss
                )
            }
        case .loading(let message):
            if position == .center {
                LoadingPopupView(message: message, theme: theme)
            } else {
                PopupBannerView(
                    icon: nil,
                    iconColor: .clear,
                    message: message,
                    theme: theme,
                    isDismissible: false,
                    accessibilityLabel: content.accessibilityLabel,
                    dismiss: dismiss
                )
            }
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
