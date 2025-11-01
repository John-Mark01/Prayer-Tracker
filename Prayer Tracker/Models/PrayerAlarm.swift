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
    var warningNotificationIdentifier: String?
    var calendarIdentifier: String?
    var liveActivityId: String?
    var addToCalendar: Bool
    var hasReminder: Bool
    var reminderMinutesBefore: Int
    var prayer: Prayer?

    init(title: String, hour: Int, minute: Int, durationMinutes: Int = 5, isEnabled: Bool = true, prayer: Prayer? = nil, addToCalendar: Bool = false, hasReminder: Bool = false, reminderMinutesBefore: Int = 5) {
        self.title = title
        self.hour = hour
        self.minute = minute
        self.durationMinutes = durationMinutes
        self.isEnabled = isEnabled
        self.notificationIdentifier = nil
        self.warningNotificationIdentifier = nil
        self.calendarIdentifier = nil
        self.liveActivityId = nil
        self.addToCalendar = addToCalendar
        self.hasReminder = hasReminder
        self.reminderMinutesBefore = reminderMinutesBefore
        self.prayer = prayer
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    // Use prayer's title if available, otherwise fall back to alarm's title
    var displayTitle: String {
        prayer?.title ?? title
    }
}
