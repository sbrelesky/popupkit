//
//  PopupKitExampleApp.swift
//  PopupKitExample
//
//  Created by Shane Brelesky on 9/1/26.
//

import SwiftUI
import PopupKit

let demoAccent = Color(red: 4/255, green: 161/255, blue: 209/255)

private let demoTheme = PopupTheme(
    accentColor: demoAccent,
    cornerRadius: 24,
    loadingTintColor: demoAccent
)

@main
struct PopupKitExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .popupTheme(demoTheme)
        }
    }
}


#Preview {
    ContentView()
        .popupTheme(demoTheme)
}
