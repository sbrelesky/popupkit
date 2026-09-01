//
//  ContentView.swift
//  PopupKitExample
//
//  Created by Shane Brelesky on 9/1/26.
//

import SwiftUI
import PopupKit

struct ContentView: View {
    @State private var showError = false
    @State private var showSuccess = false
    @State private var showLoading = false
    @State private var showGeneric = false

    var body: some View {
        VStack(spacing: 20) {
            Text("PopupKit Examples")
                .font(.title2.bold())

            Button("Show Error") { showError = true }
            Button("Show Success") { showSuccess = true }
            Button("Show Loading") { startLoadingDemo() }
            Button("Show Confirmation") { showGeneric = true }
        }
        .buttonStyle(.bordered)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .popupKit(isPresented: $showError, content: .error(message: "Network request failed."))
        .popupKit(isPresented: $showSuccess, content: .success(message: "Your profile was updated."))
        .popupKit(isPresented: $showLoading, content: .loading(message: "Syncing…"))
        .popupKit(
            isPresented: $showGeneric,
            content: .generic(
                title: "Delete this item?",
                message: "This action cannot be undone.",
                primaryAction: PopupAction(label: "Delete") { showGeneric = false },
                secondaryAction: PopupAction(label: "Cancel") { showGeneric = false }
            )
        )
    }

    /// Loading popups are never user-dismissible; the caller clears them once
    /// its async work finishes. This simulates that completion.
    private func startLoadingDemo() {
        showLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLoading = false
        }
    }
}

#Preview {
    ContentView()
}
