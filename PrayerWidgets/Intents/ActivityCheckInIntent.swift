//
//  CheckInPrayerIntent.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 29.10.25.
//

import AppIntents
import ActivityKit
import Foundation

/// App Intent for checking in a prayer from the Live Activity
/// MUST conform to LiveActivityIntent for Live Activity buttons to work!
struct ActivityCheckInIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Check In Prayer"
    static var description = IntentDescription("Record a prayer check-in from Live Activity")

    // Open the app to process the check-in
    static var openAppWhenRun: Bool = true

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

        // Queue the check-in in App Group UserDefaults
        if let prayerID = prayerID, let activityID = activityID {
            CheckInQueue.enqueue(prayerID: prayerID, activityID: activityID)
            print("✅ Check-in queued successfully")
            print("✅ App will open and process queue due to openAppWhenRun = true")
        } else {
            print("⚠️ Missing prayer ID or activity ID")
        }

        return .result()
    }
}
