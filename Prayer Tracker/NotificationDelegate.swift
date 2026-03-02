//
//  NotificationDelegate.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import SwiftUI
import UserNotifications
import ActivityKit

@MainActor
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Observable {
    /// Reference to active prayer state for in-app timer
    var activePrayerState: ActivePrayerState?

    /// Called when a notification is delivered while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("📬 NOTIFICATION RECEIVED IN FOREGROUND")
        let userInfo = notification.request.content.userInfo
        print("📦 Notification userInfo: \(userInfo)")

        // Check notification type
        if let string = userInfo["notificationType"] as? String,
           let notificationType = NotificationType(rawValue: string) {
            print("🏷️ Notification type: \(notificationType)")
            if notificationType == .warning {
                // Warning notification - start Live Activity
                await handleWarningNotification(userInfo: userInfo)

                // Still show the notification banner
                return [.banner, .sound]
                
            } else if notificationType == .alarm {
                // Alarm notification - transition to active
                await handleAlarmNotification(userInfo: userInfo)

                // Still show the notification
                return [.banner, .sound]
            }
        }

        return [.banner, .sound, .badge]
    }

    /// Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        // Check notification type
        if let string = userInfo["notificationType"] as? String,
           let notificationType = NotificationType(rawValue: string) {
            if notificationType == .warning {
                // Warning tapped - start Live Activity
                await handleWarningNotification(userInfo: userInfo)
            } else if notificationType == .alarm {
                // Alarm tapped - transition to active
                await handleAlarmNotification(userInfo: userInfo)
            }
        }
    }

    /// Handle warning notification - start Live Activity
    private func handleWarningNotification(userInfo: [AnyHashable: Any]) async {
        print("🔔 Warning notification received - starting Live Activity")

        guard let prayerTitle = userInfo["alarmTitle"] as? String,
              let hour = userInfo["hour"] as? Int,
              let minute = userInfo["minute"] as? Int,
              let durationMinutes = userInfo["durationMinutes"] as? Int else {
            print("⚠️ Missing data in warning notification")
            return
        }

        // Extract prayer data
        let prayerID = userInfo["prayerID"] as? String
        let prayerSubtitle = userInfo["prayerSubtitle"] as? String ?? ""
        let iconName = userInfo["iconName"] as? String ?? "hands.sparkles.fill"
        let colorHex = userInfo["colorHex"] as? String ?? "#9333EA"

        // Calculate alarm time
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard var alarmTime = calendar.date(from: components) else {
            print("⚠️ Failed to calculate alarm time")
            return
        }

        // If the time has already passed today, schedule for tomorrow
        if alarmTime <= now {
            alarmTime = calendar.date(byAdding: .day, value: 1, to: alarmTime) ?? alarmTime
        }

        // Create attributes
        let attributes = PrayerActivityAttributes(
            prayerID: prayerID,
            prayerTitle: prayerTitle,
            prayerSubtitle: prayerSubtitle,
            iconName: iconName,
            colorHex: colorHex,
            alarmTime: alarmTime,
            durationMinutes: durationMinutes
        )

        // Create initial content state (warning phase)
        let durationSeconds = durationMinutes * 60
        let contentState = PrayerActivityAttributes.ContentState(
            phase: .warning,
            startTime: nil,
            remainingSeconds: durationSeconds,
            totalSeconds: durationSeconds,
            currentProgress: 0.0,
            lastUpdateTime: Date()
        )

        do {
            // Try to start the Live Activity
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )

            print("✅ Live Activity started successfully: \(activity.id)")
        } catch {
            print("⚠️ Could not start Live Activity: \(error.localizedDescription)")
            print("ℹ️ This is expected if app is terminated. Live Activity will start when user opens app or taps notification.")
        }
    }

    /// Handle alarm notification - transition Live Activity to ready state
    private func handleAlarmNotification(userInfo: [AnyHashable: Any]) async {
        print("🔔 Alarm notification received - transitioning to ready state")
        
        let prayer = userInfo["alarmTitle"] as? String ?? ""
        let prayerID = userInfo["prayerID"] as? String ?? ""

        // Find the warning activity and transition it to ready
        let activities = Activity<PrayerActivityAttributes>.activities
        var activityID: String?

        if let activity = activities.first(where: { $0.attributes.prayerID == prayerID }) {
            print("✅ Found active activity: \(activity.id) for prayer: \(prayer) - transitioning to ready")

            // Transition to ready phase (NOT active - waiting for user to start)
            await LiveActivityManager.shared.transitionToReady(activityID: activity.id)
            activityID = activity.id
        } else {
            print("⚠️ No warning activity found - starting new Live Activity in ready phase")
            print("📊 Total activities: \(activities.count)")

            // Start a new Live Activity directly in ready phase
            // This handles the case when app was backgrounded during warning notification
            activityID = await startAlarmLiveActivity(userInfo: userInfo)
            for activity in activities {
                print("  - Activity \(activity.id): phase = \(activity.content.state.phase)")
            }
        }

        // Start in-app prayer timer in READY state (not counting yet)
        activePrayerState?.startPrayer(from: userInfo)

        // Set the activity ID so we can transition it later
        if let activityID = activityID {
            activePrayerState?.setActivityID(activityID)
        }
    }

    /// Start a Live Activity directly in ready phase (when alarm fires without warning)
    private func startAlarmLiveActivity(userInfo: [AnyHashable: Any]) async -> String? {
        print("🚀 Starting Live Activity in ready phase")

        guard let prayerTitle = userInfo["alarmTitle"] as? String,
              let durationMinutes = userInfo["durationMinutes"] as? Int,
              let hour = userInfo["hour"] as? Int,
              let minute = userInfo["minute"] as? Int else {
            print("⚠️ Missing data in alarm notification")
            return nil
        }

        // Extract prayer data
        let prayerID = userInfo["prayerID"] as? String
        let prayerSubtitle = userInfo["prayerSubtitle"] as? String ?? ""
        let iconName = userInfo["iconName"] as? String ?? "hands.sparkles.fill"
        let colorHex = userInfo["colorHex"] as? String ?? "#9333EA"

        // Calculate alarm time
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard let alarmTime = calendar.date(from: components) else {
            print("⚠️ Failed to calculate alarm time")
            return nil
        }

        // Create attributes
        let attributes = PrayerActivityAttributes(
            prayerID: prayerID,
            prayerTitle: prayerTitle,
            prayerSubtitle: prayerSubtitle,
            iconName: iconName,
            colorHex: colorHex,
            alarmTime: alarmTime,
            durationMinutes: durationMinutes
        )

        // Create content state in READY phase (waiting for user to start)
        let durationSeconds = durationMinutes * 60
        let contentState = PrayerActivityAttributes.ContentState(
            phase: .ready,
            startTime: nil,  // No start time yet
            remainingSeconds: durationSeconds,
            totalSeconds: durationSeconds,
            currentProgress: 0.0,
            lastUpdateTime: now
        )

        // Set stale date to 90 minutes for auto-cancel timeout
        let staleDate = now.addingTimeInterval(90 * 60)

        do {
            // Request the Live Activity
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: staleDate),
                pushType: nil
            )

            print("✅ Live Activity started in ready phase: \(activity.id)")
            print("⏸️ Waiting for user to start prayer (90 min timeout)")

            // Don't start progress timer yet - wait for user to tap Start Prayer

            return activity.id
        } catch {
            print("⚠️ Could not start Live Activity: \(error.localizedDescription)")
            return nil
        }
    }
}
