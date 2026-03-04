//
//  Prayer_TrackerApp.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

@main
struct Prayer_TrackerApp: App {
    @State private var notificationDelegate = NotificationDelegate()
    @State private var activePrayerState = ActivePrayerState()
    @State private var localPersistanceContainer = PrayerDataManager.shared.container
    @Environment(\.scenePhase) private var scenePhase

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Pass activePrayerState reference to notification delegate
        // Note: Using _wrappedValue to access @State in init
        notificationDelegate.activePrayerState = _activePrayerState.wrappedValue
    }

    var body: some Scene {
        WindowGroup {
            TabBarScreen()
                .tint(.appTint)
                .environment(activePrayerState)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .modelContainer(localPersistanceContainer)
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
        print("📍 Using App Group: \(AppGroup.identifier)")

        guard let defaults = AppGroup.userDefaults else {
            print("❌ Failed to access App Group UserDefaults")
            return
        }

        // Check for pending start prayer activity ID
        guard let activityID = defaults.string(forKey: "pendingStartPrayerActivityID") else {
            print("ℹ️ No pending start prayer signal found")
            return
        }

        print("🎬 Found pending start prayer for activity: \(activityID)")

        // Clear the pending signal
        defaults.removeObject(forKey: "pendingStartPrayerActivityID")
        defaults.removeObject(forKey: "pendingStartPrayerTimestamp")

        // Start the Live Activity countdown
        print("▶️ Starting Live Activity countdown...")
        await LiveActivityManager.shared.startPrayerCountdown(activityID: activityID)

        // Start the in-app countdown if modal is showing
        print("🔍 Checking in-app state - activityID: \(activePrayerState.activityID ?? "nil"), isReady: \(activePrayerState.isReady)")
        if activePrayerState.activityID == activityID && activePrayerState.isReady {
            print("▶️ Starting in-app countdown...")
            activePrayerState.beginCountdown()
            print("✅ In-app timer also started")
        } else {
            print("ℹ️ In-app timer not in ready state or different activity")
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

        let context = localPersistanceContainer.mainContext
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
