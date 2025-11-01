//
//  CheckInIntent.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import AppIntents
import SwiftData
import Foundation

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Prayer"
    static var description = IntentDescription("Add a prayer check-in")

    @Parameter(title: "Prayer ID")
    var prayerId: String?

    func perform() async throws -> some IntentResult {
        // Create prayer entry
        let schema = Schema([Prayer.self, PrayerEntry.self, PrayerAlarm.self])

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

            // Find the prayer if prayerId is provided
            var prayer: Prayer?
            if let prayerIdString = prayerId, let uuid = UUID(uuidString: prayerIdString) {
                let prayerDescriptor = FetchDescriptor<Prayer>(
                    predicate: #Predicate<Prayer> { p in
                        p.id == uuid
                    }
                )
                prayer = try context.fetch(prayerDescriptor).first
            }

            let entry = PrayerEntry(timestamp: Date())

            // Associate with prayer if found
            if let prayer = prayer {
                entry.prayer = prayer
            }

            context.insert(entry)
            try context.save()

            return .result()
        } catch {
            print("Failed to save prayer entry from widget: \(error)")
            throw error
        }
    }
}
