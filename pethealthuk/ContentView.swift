//
//  ContentView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppManager.self) private var appManager

    var body: some View {
        Group {
            if appManager.hasCompletedOnboarding && appManager.isLoggedIn {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: appManager.isLoggedIn)
        .animation(.easeInOut, value: appManager.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environment(AppManager.shared)
}
