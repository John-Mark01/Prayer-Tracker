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
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var showingSettings = false

    var body: some View {
        TabView {
            
            //Today Screen
            Tab("Today", systemImage: "house.fill") {
                NavigationStack {
                    TodayScreen()
                }
            }
            
            //Alarms Screen
            Tab("Alarms", systemImage: "bell.fill") {
                NavigationStack {
                    AlarmsScreen()
                }
            }
            
            //Settings Screen
            Tab("Settings", systemImage: "gear", role: .search) {
                NavigationStack {
                    SettingsScreen()
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { activePrayerState.isActive },
            set: { if !$0 { activePrayerState.reset() } }
        )) {
            ActivePrayerTimerView(prayerState: activePrayerState) {}
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsScreen()
            }
        }
    }
}

#Preview {
    TabBarScreen()
        .modelContainer(for: Prayer.self, inMemory: true)
        .environment(SubscriptionManager())
        .environment(ActivePrayerState())
}
