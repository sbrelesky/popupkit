import SwiftUI

struct GenericPopupView: View {
    let title: String
    let message: String
    let primaryAction: PopupAction
    let secondaryAction: PopupAction?
    let theme: PopupTheme

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.titleColor)
            Text(message)
                .font(.body)
                .foregroundStyle(theme.messageColor)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                if let secondaryAction {
                    Button(secondaryAction.label, action: secondaryAction.handler)
                        .buttonStyle(.bordered)
                }
                Button(primaryAction.label, action: primaryAction.handler)
                    .buttonStyle(.borderedProminent)
                    .tint(theme.accentColor)
            }
        }
        .padding(24)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            PopupContent.generic(
                title: title,
                message: message,
                primaryAction: primaryAction,
                secondaryAction: secondaryAction
            ).accessibilityLabel
        )
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    GenericPopupView(
        title: "Delete event?",
        message: "This can't be undone.",
        primaryAction: PopupAction(label: "Delete", handler: {}),
        secondaryAction: PopupAction(label: "Cancel", handler: {}),
        theme: .default
    )
}
