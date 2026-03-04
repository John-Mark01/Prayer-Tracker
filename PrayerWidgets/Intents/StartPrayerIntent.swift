//
//  StartPrayerIntent.swift
//  PrayerWidgets
//
//  Created by Claude on 1.11.25.
//

import AppIntents
import ActivityKit
import Foundation

/// App Intent for starting a prayer from the Live Activity
/// MUST conform to LiveActivityIntent for Live Activity buttons to work!
struct StartPrayerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start Prayer"
    static var description = IntentDescription("Begin the prayer countdown timer")

    // Open the app to start the countdown
    static var openAppWhenRun: Bool = true

    /// The Live Activity ID to transition
    @Parameter(title: "Activity ID")
    var activityID: String?

    init() {}

    init(activityID: String?) {
        self.activityID = activityID
    }

    func perform() async throws -> some IntentResult {
        print("🙏 StartPrayerIntent TRIGGERED")
        print("📦 Activity ID: \(activityID ?? "nil")")

        // Queue the operation for the app to process
        if let activityID = activityID {
            let operation = PendingStartPrayer(activityID: activityID)
            OperationQueue.enqueue(operation, key: .startPrayers)
            print("✅ Start prayer operation queued successfully")
            print("✅ App will open and process queue due to openAppWhenRun = true")
        } else {
            print("⚠️ Missing activity ID")
        }

        return .result()
    }
}
