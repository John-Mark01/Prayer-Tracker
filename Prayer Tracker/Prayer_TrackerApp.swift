//
//  Prayer_TrackerApp.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData
import UserNotifications
import ActivityKit

@main
struct Prayer_TrackerApp: App {
    @State private var notificationDelegate = NotificationDelegate()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prayer.self,
            PrayerEntry.self,
            PrayerAlarm.self,
        ])

        do {
            // Check if App Group is configured
            if let appGroupURL = AppGroup.containerURL {
                // Use App Group container for shared access with widgets and Live Activities
                let storeURL = appGroupURL.appendingPathComponent("PrayerTracker.sqlite")
                let modelConfiguration = ModelConfiguration(url: storeURL)
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } else {
                // Use default persistent storage
                // This will store data in the app's documents directory
                print("⚠️ App Groups not configured - using default storage (data won't be shared with widgets)")
                return try ModelContainer(for: schema)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Notification Delegate

@MainActor
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Observable {
    /// Called when a notification is delivered while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("📬 NOTIFICATION RECEIVED IN FOREGROUND")
        let userInfo = notification.request.content.userInfo
        print("📦 Notification userInfo: \(userInfo)")

        // Check notification type
        if let notificationType = userInfo["notificationType"] as? String {
            print("🏷️ Notification type: \(notificationType)")
            if notificationType == "warning" {
                // Warning notification - start Live Activity
                await handleWarningNotification(userInfo: userInfo)

                // Still show the notification banner
                return [.banner, .sound]
            } else if notificationType == "alarm" {
                // Alarm notification - transition to active
                await handleAlarmNotification(userInfo: userInfo)

                // Still show the notification
                return [.banner, .sound, .badge]
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
        if let notificationType = userInfo["notificationType"] as? String {
            if notificationType == "warning" {
                // Warning tapped - start Live Activity
                await handleWarningNotification(userInfo: userInfo)
            } else if notificationType == "alarm" {
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
        let contentState = PrayerActivityAttributes.ContentState(
            phase: .warning,
            startTime: nil,
            elapsedSeconds: 0,
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

    /// Handle alarm notification - transition Live Activity to active
    private func handleAlarmNotification(userInfo: [AnyHashable: Any]) async {
        print("🔔 Alarm notification received - transitioning Live Activity to active")

        // Find the warning activity and transition it to active
        let activities = Activity<PrayerActivityAttributes>.activities

        if let activity = activities.first(where: { $0.content.state.phase == .warning }) {
            print("✅ Found warning activity: \(activity.id)")

            // Transition to active phase
            await LiveActivityManager.shared.transitionToActive(activityID: activity.id)
        } else {
            print("⚠️ No warning activity found to transition")
            print("📊 Total activities: \(activities.count)")
            for activity in activities {
                print("  - Activity \(activity.id): phase = \(activity.content.state.phase)")
            }
        }
    }
}
