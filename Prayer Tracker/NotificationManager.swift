//
//  NotificationManager.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import UserNotifications
import Foundation

@MainActor
@Observable class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {
        // Set up notification categories for future actions
        setupNotificationCategories()
    }

    // MARK: - Authorization

    /// Request notification permission from user
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("❌ Error requesting notification authorization: \(error)")
            return false
        }
    }

    /// Check if notifications are authorized
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Scheduling

    /// Schedule a 5-minute warning notification before the prayer alarm
    /// Returns the notification identifier if successful
    func scheduleWarningNotification(for alarm: PrayerAlarm) async -> String? {
        // Check authorization first
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            print("⚠️ Notifications not authorized. Status: \(status)")
            return nil
        }

        // Cancel existing warning notification if any
        if let existingIdentifier = alarm.warningNotificationIdentifier {
            cancelNotification(identifier: existingIdentifier)
        }

        // Calculate warning time (5 minutes before alarm)
        var warningHour = alarm.hour
        var warningMinute = alarm.minute - 5

        // Handle negative minutes
        if warningMinute < 0 {
            warningMinute += 60
            warningHour -= 1
            if warningHour < 0 {
                warningHour = 23
            }
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Upcoming: \(alarm.displayTitle)"
        content.body = "Prayer time in 5 minutes"
        content.sound = .default
        content.categoryIdentifier = "PRAYER_WARNING"

        // Add metadata
        content.userInfo = [
            "notificationType": "warning",
            "alarmTitle": alarm.displayTitle,
            "hour": alarm.hour,
            "minute": alarm.minute,
            "durationMinutes": alarm.durationMinutes,
            "prayerID": alarm.prayer?.id.uuidString ?? "",
            "prayerSubtitle": alarm.prayer?.subtitle ?? "",
            "iconName": alarm.prayer?.iconName ?? "hands.sparkles.fill",
            "colorHex": alarm.prayer?.colorHex ?? "#9333EA"
        ]

        // Create daily repeating trigger
        var dateComponents = DateComponents()
        dateComponents.hour = warningHour
        dateComponents.minute = warningMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create unique identifier
        let identifier = "prayer-warning-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule notification
        do {
            try await center.add(request)
            print("✅ Scheduled warning notification for \(alarm.displayTitle) at \(String(format: "%02d:%02d", warningHour, warningMinute))")
            return identifier
        } catch {
            print("❌ Error scheduling warning notification: \(error)")
            return nil
        }
    }

    /// Schedule a daily repeating notification for a prayer alarm
    /// Returns the notification identifier if successful
    func scheduleAlarmNotification(for alarm: PrayerAlarm) async -> String? {
        // Check authorization first
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            print("⚠️ Notifications not authorized. Status: \(status)")
            return nil
        }

        // Cancel existing notification if any
        if let existingIdentifier = alarm.notificationIdentifier {
            cancelNotification(identifier: existingIdentifier)
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "It's time to pray for \(alarm.displayTitle)"
        content.body = "Take \(alarm.durationMinutes) minutes to pray"
        content.sound = .default
        content.badge = NSNumber(value: 1)
        content.categoryIdentifier = "PRAYER_ALARM"

        // Add prayer metadata for future use
        content.userInfo = [
            "notificationType": "alarm",
            "alarmTitle": alarm.displayTitle,
            "durationMinutes": alarm.durationMinutes,
            "hour": alarm.hour,
            "minute": alarm.minute,
            "prayerID": alarm.prayer?.id.uuidString ?? ""
        ]

        // Create daily repeating trigger
        var dateComponents = DateComponents()
        dateComponents.hour = alarm.hour
        dateComponents.minute = alarm.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create unique identifier
        let identifier = "prayer-alarm-\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule notification
        do {
            try await center.add(request)
            print("✅ Scheduled notification for \(alarm.displayTitle) at \(alarm.timeString)")
            return identifier
        } catch {
            print("❌ Error scheduling notification: \(error)")
            return nil
        }
    }

    // MARK: - Cancellation

    /// Cancel a notification by its identifier
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Canceled notification: \(identifier)")
    }

    /// Cancel all pending prayer alarm notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        print("🗑️ Canceled all notifications")
    }

    // MARK: - Categories & Actions

    private func setupNotificationCategories() {
        // Define notification actions for future Live Activity integration
        let startTimerAction = UNNotificationAction(
            identifier: "START_TIMER",
            title: "Start Prayer Timer",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Snooze 5 min",
            options: []
        )

        // Warning notification category (5 minutes before)
        let warningCategory = UNNotificationCategory(
            identifier: "PRAYER_WARNING",
            actions: [],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Alarm notification category (at prayer time)
        let alarmCategory = UNNotificationCategory(
            identifier: "PRAYER_ALARM",
            actions: [startTimerAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        center.setNotificationCategories([warningCategory, alarmCategory])
    }

    // MARK: - Debugging

    /// Get all pending notifications (for debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }

    /// Print all pending notifications (for debugging)
    func printPendingNotifications() async {
        let requests = await getPendingNotifications()
        print("📋 Pending notifications: \(requests.count)")
        for request in requests {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let date = trigger.nextTriggerDate() {
                print("  - \(request.identifier): \(request.content.title) at \(date)")
            }
        }
    }
}
