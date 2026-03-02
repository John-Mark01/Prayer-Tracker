//
//  NotificationServiceProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import UserNotifications

protocol NotificationServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func checkAuthorizationStatus() async -> UNAuthorizationStatus

    func scheduleAlarmNotification(for alarm: PrayerAlarm) async -> String?
    func scheduleWarningNotification(for alarm: PrayerAlarm) async -> String?

    func cancelNotification(identifier: String) async
    func cancelAllNotifications() async

    func getPendingNotifications() async -> [UNNotificationRequest]
}
