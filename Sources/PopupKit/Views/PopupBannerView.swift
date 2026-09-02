import SwiftUI

struct PopupBannerView: View {
    let icon: String?
    let iconColor: Color
    let message: String?
    let theme: PopupTheme
    let isDismissible: Bool
    let accessibilityLabel: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            leadingIndicator

            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(theme.messageColor)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if isDismissible {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.messageColor)
                }
                .accessibilityLabel("Dismiss")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isModal)
    }

    @ViewBuilder
    private var leadingIndicator: some View {
        if let icon {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
        } else {
            ProgressView()
                .tint(theme.loadingTintColor)
        }
    }
}

#Preview("Error banner") {
    PopupBannerView(
        icon: PopupTheme.default.errorIcon,
        iconColor: .red,
        message: "Network request failed.",
        theme: .default,
        isDismissible: true,
        accessibilityLabel: PopupContent.error(message: "Network request failed.").accessibilityLabel,
        dismiss: {}
    )
    .padding()
}

#Preview("Loading banner") {
    PopupBannerView(
        icon: nil,
        iconColor: .clear,
        message: "Syncing…",
        theme: .default,
        isDismissible: false,
        accessibilityLabel: PopupContent.loading(message: "Syncing…").accessibilityLabel,
        dismiss: {}
    )
    .padding()
}
