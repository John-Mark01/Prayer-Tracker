//
//  ContentView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ActivePrayerState.self) private var activePrayerState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
                .tag(0)

            AlarmsView()
                .tabItem {
                    Label("Alarms", systemImage: "bell.fill")
                }
                .tag(1)
        }
        .tint(.appTint)
        .sheet(isPresented: Binding(
            get: { activePrayerState.isActive },
            set: { if !$0 { activePrayerState.reset() } }
        )) {
            ActivePrayerTimerView(prayerState: activePrayerState) {
                // Navigate to Today tab after check-in
                selectedTab = 0
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Prayer.self, inMemory: true)
}
