import SwiftUI

private struct PopupKitModifier: ViewModifier {
    @Binding var isPresented: Bool
    let content: PopupContent
    @Environment(\.popupTheme) private var theme

    func body(content base: Content) -> some View {
        base.overlay {
            if isPresented {
                PopupContainerView(content: content, theme: theme) {
                    isPresented = false
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

extension View {
    /// Presents a PopupKit popup when `isPresented` is `true`, matching the
    /// `.alert`/`.sheet` idiom. Only one popup may be presented per
    /// modifier attachment at a time.
    public func popupKit(isPresented: Binding<Bool>, content: PopupContent) -> some View {
        modifier(PopupKitModifier(isPresented: isPresented, content: content))
    }
}
