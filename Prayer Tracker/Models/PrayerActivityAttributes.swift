//
//  PrayerActivityAttributes.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 29.10.25.
//

import ActivityKit
import Foundation

/// Defines the static and dynamic data for Prayer Live Activities
struct PrayerActivityAttributes: ActivityAttributes {
    /// Static data that doesn't change during the activity's lifetime
    public struct ContentState: Codable, Hashable {
        /// Current phase of the prayer activity
        var phase: ActivityPhase

        /// When the prayer timer started (nil during warning phase)
        var startTime: Date?

        /// Remaining seconds in the countdown (actively updated)
        var remainingSeconds: Int

        /// Total duration in seconds
        var totalSeconds: Int

        /// Current progress from 0.0 to 1.0 (actively updated)
        var currentProgress: Double

        /// When the activity was last updated
        var lastUpdateTime: Date
    }

    /// The prayer's UUID (for check-in)
    var prayerID: String?

    /// The prayer's title
    var prayerTitle: String

    /// The prayer's subtitle/description
    var prayerSubtitle: String

    /// SF Symbol icon name for the prayer
    var iconName: String

    /// Hex color string for the prayer
    var colorHex: String

    /// The scheduled alarm time
    var alarmTime: Date

    /// Prayer duration in minutes
    var durationMinutes: Int
}

/// Represents the different phases of a prayer activity
enum ActivityPhase: String, Codable, Hashable {
    /// 5-minute warning before prayer starts
    case warning

    /// Prayer timer is actively running
    case active

    /// Prayer timer has completed
    case completed
}
