//
//  pethealthukApp.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

@main
struct pethealthukApp: App {
    @State private var appManager = AppManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appManager)
                .tint(Color.accentColor)
        }
    }
}
