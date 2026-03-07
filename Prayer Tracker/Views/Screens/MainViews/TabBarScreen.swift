//
//  ContentView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct TabBarScreen: View {
    @Environment(ActivePrayerState.self) private var activePrayerState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayScreen()
            }
            .tag(0)
            .tabItem { Label("Today", systemImage: "house.fill") }
            
            NavigationStack {
                AlarmsScreen()
            }
            .tag(1)
            .tabItem { Label("Alarms", systemImage: "bell.fill") }
        }
        .sheet(isPresented: Binding(
            get: { activePrayerState.isActive },
            set: { if !$0 { activePrayerState.reset() } }
        )) {
            ActivePrayerTimerView(prayerState: activePrayerState) {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    TabBarScreen()
        .modelContainer(for: Prayer.self, inMemory: true)
}
