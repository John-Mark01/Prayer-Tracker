//
//  NotificationService.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService: NotificationServiceProtocol {
    private let manager: NotificationManager

    init(manager: NotificationManager = .shared) {
        self.manager = manager
    }

    nonisolated func requestAuthorization() async -> Bool {
        await manager.requestAuthorization()
    }

    nonisolated func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        await manager.checkAuthorizationStatus()
    }

    nonisolated func scheduleAlarmNotification(for alarm: PrayerAlarm) async -> String? {
        await manager.scheduleAlarmNotification(for: alarm)
    }

    nonisolated func scheduleWarningNotification(for alarm: PrayerAlarm) async -> String? {
        await manager.scheduleWarningNotification(for: alarm)
    }

    nonisolated func cancelNotification(identifier: String) async {
        await MainActor.run {
            manager.cancelNotification(identifier: identifier)
        }
    }

    nonisolated func cancelAllNotifications() async {
        await MainActor.run {
            manager.cancelAllNotifications()
        }
    }

    nonisolated func getPendingNotifications() async -> [UNNotificationRequest] {
        await manager.getPendingNotifications()
    }
}
