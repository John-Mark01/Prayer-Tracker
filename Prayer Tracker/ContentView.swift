//
//  ContentView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            AlarmsView()
                .tabItem {
                    Label("Alarms", systemImage: "bell.fill")
                }
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
