import SwiftUI

struct SuccessPopupView: View {
    let message: String
    let theme: PopupTheme
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: theme.successIcon)
                .font(.system(size: 32))
                .foregroundStyle(theme.successIconColor)
            Text(message)
                .font(theme.messageFont)
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
        .accessibilityLabel(PopupContent.success(message: message).accessibilityLabel)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    SuccessPopupView(message: "Your changes have been saved.", theme: .default, dismiss: {})
}
