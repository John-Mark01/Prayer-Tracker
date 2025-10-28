//
//  Prayer_TrackerApp.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

@main
struct Prayer_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prayer.self,
            PrayerEntry.self,
            PrayerAlarm.self,
        ])

        do {
            // Check if App Group is configured
            if let appGroupURL = AppGroup.containerURL {
                // Use App Group container for shared access with widgets and Live Activities
                let storeURL = appGroupURL.appendingPathComponent("PrayerTracker.sqlite")
                let modelConfiguration = ModelConfiguration(url: storeURL)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } else {
                // Use default persistent storage
                // This will store data in the app's documents directory
                print("⚠️ App Groups not configured - using default storage (data won't be shared with widgets)")
                return try ModelContainer(for: schema)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
