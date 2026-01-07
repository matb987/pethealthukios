//
//  MainTabView.swift
//  pethealthuk
//
//  Created by Matthew Brain on 11/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            MyPetsView()
                .tabItem {
                    Label("My Pets", systemImage: "pawprint.fill")
                }
                .tag(1)

            SymptomCheckerView()
                .tabItem {
                    Label("Symptoms", systemImage: "stethoscope")
                }
                .tag(2)

            ClinicFinderView()
                .tabItem {
                    Label("Clinics", systemImage: "map.fill")
                }
                .tag(3)

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(Color("AccentColor"))
    }
}

#Preview {
    MainTabView()
        .environment(AppManager.shared)
}
