//
//  StartPrayerIntent.swift
//  PrayerWidgets
//
//  Created by Claude on 1.11.25.
//

import AppIntents
import ActivityKit
import Foundation

// Ensure AppGroup is accessible
fileprivate struct AppGroupAccess {
    static let identifier = "group.johnmark.Prayer-Tracker"
}

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

        // Store in UserDefaults to signal app to start countdown
        if let activityID = activityID {
            if let defaults = UserDefaults(suiteName: AppGroupAccess.identifier) {
                defaults.set(activityID, forKey: "pendingStartPrayerActivityID")
                defaults.set(Date(), forKey: "pendingStartPrayerTimestamp")
                defaults.synchronize()  // Force immediate write
                print("✅ Start prayer signal stored in App Group")
                print("✅ App will open and start countdown due to openAppWhenRun = true")
            } else {
                print("❌ Failed to access App Group UserDefaults")
            }
        } else {
            print("⚠️ Missing activity ID")
        }

        return .result()
    }
}
