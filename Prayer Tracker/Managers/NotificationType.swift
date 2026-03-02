//
//  NotificationType.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import Foundation

enum NotificationType: String {
    case warning
    case alarm
}

enum NotificationCategory: String {
    case startTimer = "START_TIMER"
    case snooze = "SNOOZE"
    case warning = "PRAYER_WARNING"
    case alarm = "PRAYER_ALARM"
    
}
