//
//  CheckInPrayerIntent.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 29.10.25.
//

import AppIntents
import SwiftData
import ActivityKit

/// App Intent for checking in a prayer from the Live Activity
struct CheckInPrayerIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In Prayer"
    static var description = IntentDescription("Record a prayer check-in from Live Activity")

    // This makes the intent open the app, which is required for proper execution
    static var openAppWhenRun: Bool = false

    /// The prayer UUID to check in
    @Parameter(title: "Prayer ID")
    var prayerID: String?

    /// The Live Activity ID to end
    @Parameter(title: "Activity ID")
    var activityID: String?

    init() {}

    init(prayerID: String?, activityID: String?) {
        self.prayerID = prayerID
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        print("🙏🙏🙏 CheckInPrayerIntent TRIGGERED")
        print("📦 Prayer ID: \(prayerID ?? "nil")")
        print("📦 Activity ID: \(activityID ?? "nil")")

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

            // Find the prayer if ID is provided
            var prayer: Prayer? = nil
            if let prayerIDString = prayerID,
               let uuid = UUID(uuidString: prayerIDString) {
                print("🔍 Looking for prayer with UUID: \(uuid)")
                let descriptor = FetchDescriptor<Prayer>(
                    predicate: #Predicate { $0.id == uuid }
                )
                prayer = try context.fetch(descriptor).first
                if let prayer = prayer {
                    print("✅ Found prayer: \(prayer.title)")
                } else {
                    print("⚠️ Prayer not found with UUID: \(uuid)")
                }
            } else {
                print("⚠️ No valid prayer ID provided")
            }

            // Create the entry
            let entry = PrayerEntry(timestamp: Date(), prayer: prayer)
            context.insert(entry)

            try context.save()

            print("✅✅✅ PRAYER ENTRY CREATED SUCCESSFULLY")
            if let prayer = prayer {
                print("📝 Check-in recorded for: \(prayer.title)")
            } else {
                print("📝 Generic check-in recorded (no specific prayer)")
            }

            // End the Live Activity if ID is provided
            if let activityIDString = activityID {
                print("🎬 Ending Live Activity: \(activityIDString)")
                await endLiveActivity(activityID: activityIDString)
            } else {
                print("⚠️ No activity ID provided, ending all prayer activities")
                await endAllPrayerActivities()
            }

            return .result()
        } catch {
            print("❌❌❌ FAILED TO SAVE PRAYER ENTRY")
            print("❌ Error: \(error)")
            throw error
        }
    }

    /// End the Live Activity with the given ID
    private func endLiveActivity(activityID: String) async {
        let activities = Activity<PrayerActivityAttributes>.activities
        print("📊 Total active activities: \(activities.count)")

        for activity in activities {
            if activity.id == activityID {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("✅✅✅ ENDED LIVE ACTIVITY: \(activityID)")
                return
            }
        }
        print("⚠️ Live Activity not found with ID: \(activityID)")
        print("💡 Attempting to end any completed activity instead...")
        await endAllPrayerActivities()
    }

    /// End all prayer Live Activities (fallback)
    private func endAllPrayerActivities() async {
        let activities = Activity<PrayerActivityAttributes>.activities
        for activity in activities {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("✅ Ended activity: \(activity.id)")
        }
    }
}
