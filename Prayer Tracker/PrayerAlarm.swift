//
//  PrayerAlarm.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import Foundation
import SwiftData

@Model
final class PrayerAlarm {
    var title: String
    var hour: Int
    var minute: Int
    var durationMinutes: Int
    var isEnabled: Bool
    var notificationIdentifier: String?

    init(title: String, hour: Int, minute: Int, durationMinutes: Int = 5, isEnabled: Bool = true) {
        self.title = title
        self.hour = hour
        self.minute = minute
        self.durationMinutes = durationMinutes
        self.isEnabled = isEnabled
        self.notificationIdentifier = nil
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }
}
