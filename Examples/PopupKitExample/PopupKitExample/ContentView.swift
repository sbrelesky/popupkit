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
        ZStack {
            LinearGradient(
                colors: [demoAccent.opacity(0.2), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                VStack(spacing: 8) {
                    Text("PopupKit Examples")
                        .font(.largeTitle.bold())
                    Text("Four branded popup types, one modifier.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 28)

                Button {
                    showError = true
                } label: {
                    Label("Show Error", systemImage: "exclamationmark.triangle.fill")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    showSuccess = true
                } label: {
                    Label("Show Success", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    startLoadingDemo()
                } label: {
                    Label("Show Loading", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }

                Button {
                    showGeneric = true
                } label: {
                    Label("Show Confirmation", systemImage: "trash.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(demoAccent)
            .controlSize(.large)
            .padding(.horizontal, 48)
        }
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
