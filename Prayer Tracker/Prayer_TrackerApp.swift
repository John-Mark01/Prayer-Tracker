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
    @State private var activePrayerState = ActivePrayerState()
    @Environment(\.scenePhase) private var scenePhase

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

        // Pass activePrayerState reference to notification delegate
        // Note: Using _wrappedValue to access @State in init
        notificationDelegate.activePrayerState = _activePrayerState.wrappedValue
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(activePrayerState)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Process pending operations when app becomes active
                Task {
                    await processPendingCheckIns()
                    await processPendingStartPrayer()
                }
            }
        }
    }

    // MARK: - URL Handling

    private func handleURL(_ url: URL) {
        print("🔗 Received URL: \(url.absoluteString)")

        if url.scheme == "prayertracker" {
            if url.host == "process-checkins" || url.path.contains("process-checkins") {
                print("✅ Processing check-ins from URL scheme")
                Task {
                    await processPendingCheckIns()
                }
            }
        }
    }

    // MARK: - Start Prayer Processing

    @MainActor
    func processPendingStartPrayer() async {
        print("🔄 Checking for pending start prayer signals")

        guard let defaults = UserDefaults(suiteName: AppGroup.identifier) else {
            return
        }

        // Check for pending start prayer activity ID
        guard let activityID = defaults.string(forKey: "pendingStartPrayerActivityID") else {
            return
        }

        print("🎬 Found pending start prayer for activity: \(activityID)")

        // Clear the pending signal
        defaults.removeObject(forKey: "pendingStartPrayerActivityID")
        defaults.removeObject(forKey: "pendingStartPrayerTimestamp")

        // Start the Live Activity countdown
        await LiveActivityManager.shared.startPrayerCountdown(activityID: activityID)

        // Start the in-app countdown if modal is showing
        if activePrayerState.activityID == activityID && activePrayerState.isReady {
            activePrayerState.beginCountdown()
            print("✅ In-app timer also started")
        }

        print("✅ Prayer countdown started from Live Activity button")
    }

    // MARK: - Check-In Processing

    @MainActor
    func processPendingCheckIns() async {
        print("🔄 processPendingCheckIns() called")
        let queue = CheckInQueue.getQueue()

        guard !queue.isEmpty else {
            print("ℹ️ No pending check-ins to process")
            return
        }

        print("📝 Processing \(queue.count) pending check-in(s)")

        let context = sharedModelContainer.mainContext
        var checkedInActivityIDs: [String] = []

        for checkIn in queue {
            // Find the prayer
            var prayer: Prayer? = nil
            if let uuid = UUID(uuidString: checkIn.prayerID) {
                let descriptor = FetchDescriptor<Prayer>(
                    predicate: #Predicate { $0.id == uuid }
                )
                prayer = try? context.fetch(descriptor).first
            }

            // Create the prayer entry
            let entry = PrayerEntry(timestamp: checkIn.timestamp, prayer: prayer)
            context.insert(entry)

            if let prayer = prayer {
                print("✅ Created check-in for: \(prayer.title)")
            } else {
                print("✅ Created generic check-in")
            }

            // Track activity IDs that were checked in
            checkedInActivityIDs.append(checkIn.activityID)

            // End the Live Activity
            await LiveActivityManager.shared.endActivity(activityID: checkIn.activityID)
        }

        // Save all entries
        do {
            try context.save()
            print("✅ Saved all check-ins to database")
        } catch {
            print("❌ Failed to save check-ins: \(error)")
        }

        // Clear the queue
        CheckInQueue.clearQueue()

        // If the current in-app prayer session was checked in from Live Activity, dismiss it
        if let currentActivityID = activePrayerState.activityID,
           checkedInActivityIDs.contains(currentActivityID) {
            print("🚪 Check-in was for current in-app session - dismissing modal")
            activePrayerState.reset()
        }
    }
}

// MARK: - Notification Delegate

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

        // Find the warning activity and transition it to ready
        let activities = Activity<PrayerActivityAttributes>.activities
        var activityID: String?

        if let activity = activities.first(where: { $0.content.state.phase == .warning }) {
            print("✅ Found warning activity: \(activity.id) - transitioning to ready")

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
