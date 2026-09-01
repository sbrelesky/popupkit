import SwiftUI

struct LoadingPopupView: View {
    let message: String?
    let theme: PopupTheme

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(theme.loadingTintColor)
            if let message {
                Text(message)
                    .font(.body)
                    .foregroundStyle(theme.messageColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(PopupContent.loading(message: message).accessibilityLabel)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    LoadingPopupView(message: "Uploading photo…", theme: .default)
}
