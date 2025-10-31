//
//  CheckInIntent.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import AppIntents
import SwiftData

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Prayer"
    static var description = IntentDescription("Add a prayer check-in")

    func perform() async throws -> some IntentResult {
        // Create prayer entry
        let schema = Schema([PrayerEntry.self, PrayerAlarm.self])

        do {
            let container: ModelContainer

            if let appGroupURL = AppGroup.containerURL {
                let storeURL = appGroupURL.appendingPathComponent("PrayerTracker.sqlite")
                let config = ModelConfiguration(url: storeURL)
                container = try ModelContainer(for: schema, configurations: [config])
            } else {
                container = try ModelContainer(for: schema)
            }

            let context = ModelContext(container)
            let entry = PrayerEntry(timestamp: Date())
            context.insert(entry)

            try context.save()

            return .result()
        } catch {
            print("Failed to save prayer entry from widget: \(error)")
            throw error
        }
    }
}
