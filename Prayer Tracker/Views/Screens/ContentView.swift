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

            AlarmsView()
                .tabItem {
                    Label("Alarms", systemImage: "bell.fill")
                }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Prayer.self, inMemory: true)
}
