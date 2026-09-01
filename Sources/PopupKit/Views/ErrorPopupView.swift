import SwiftUI

struct ErrorPopupView: View {
    let message: String
    let theme: PopupTheme
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: theme.errorIcon)
                .font(.system(size: 32))
                .foregroundStyle(.red)
            Text(message)
                .font(.body)
                .foregroundStyle(theme.messageColor)
                .multilineTextAlignment(.center)
            Button("Dismiss", action: dismiss)
                .buttonStyle(.borderedProminent)
                .tint(theme.accentColor)
        }
        .padding(24)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(PopupContent.error(message: message).accessibilityLabel)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    ErrorPopupView(message: "Something went wrong. Please try again.", theme: .default, dismiss: {})
}
