//
//  WidgetCheckInIntent.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import AppIntents
import SwiftData
import Foundation

struct WidgetCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Prayer"
    static var description = IntentDescription("Add a prayer check-in from widget")

    // Widget check-ins write directly to SwiftData (no need to open app)
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Prayer ID")
    var prayerId: String?

    func perform() async throws -> some IntentResult {
        do {
            let context = PrayerDataManager.shared.newContext()

            // Find the prayer if prayerId is provided
            var prayer: Prayer?
            if let prayerIdString = prayerId,
                let uuid = UUID(uuidString: prayerIdString) {
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
