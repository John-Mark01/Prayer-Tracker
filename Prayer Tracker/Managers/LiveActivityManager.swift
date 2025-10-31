//
//  LiveActivityManager.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 29.10.25.
//

import ActivityKit
import Foundation

@MainActor
@Observable class LiveActivityManager {
    static let shared = LiveActivityManager()

    // Store active timers for each running activity
    private var activeTimers: [String: Timer] = [:]

    private init() {}

    // MARK: - Authorization

    /// Check if Live Activities are enabled
    func areActivitiesEnabled() -> Bool {
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }

    // MARK: - Starting Activities

    /// Start a warning Live Activity 5 minutes before prayer time
    /// Returns the activity ID if successful
    func startWarningActivity(for alarm: PrayerAlarm) async -> String? {
        guard areActivitiesEnabled() else {
            print("⚠️ Live Activities are not enabled")
            return nil
        }

        // Calculate alarm time (next occurrence)
        let alarmTime = nextAlarmDate(hour: alarm.hour, minute: alarm.minute)
        let durationSeconds = alarm.durationMinutes * 60

        // Create attributes (static data)
        let attributes = PrayerActivityAttributes(
            prayerID: alarm.prayer?.id.uuidString,
            prayerTitle: alarm.displayTitle,
            prayerSubtitle: alarm.prayer?.subtitle ?? "",
            iconName: alarm.prayer?.iconName ?? "hands.sparkles.fill",
            colorHex: alarm.prayer?.colorHex ?? "#9333EA",
            alarmTime: alarmTime,
            durationMinutes: alarm.durationMinutes
        )

        // Create initial content state (warning phase)
        let contentState = PrayerActivityAttributes.ContentState(
            phase: .warning,
            startTime: nil,
            remainingSeconds: durationSeconds,
            totalSeconds: durationSeconds,
            currentProgress: 0.0,
            lastUpdateTime: Date()
        )

        do {
            // Request the Live Activity
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )

            print("✅ Started warning Live Activity: \(activity.id)")
            return activity.id
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            return nil
        }
    }

    // MARK: - Transitioning Activities

    /// Transition activity from warning to active phase (when alarm time hits)
    func transitionToActive(activityID: String) async {
        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found: \(activityID)")
            return
        }

        let durationSeconds = activity.attributes.durationMinutes * 60
        let startTime = Date()

        // Create updated content state (active phase)
        let newState = PrayerActivityAttributes.ContentState(
            phase: .active,
            startTime: startTime,
            remainingSeconds: durationSeconds,
            totalSeconds: durationSeconds,
            currentProgress: 0.0,
            lastUpdateTime: Date()
        )

        // Set stale date for when the timer ends
        let staleDate = startTime.addingTimeInterval(TimeInterval(durationSeconds))

        await activity.update(
            ActivityContent(state: newState, staleDate: staleDate)
        )
        print("✅ Transitioned activity to active: \(activityID)")

        // Start the progress update timer
        startProgressUpdates(activityID: activityID, durationSeconds: durationSeconds)
    }

    // MARK: - Active Progress Updates

    /// Start a timer that updates the activity state every second
    private func startProgressUpdates(activityID: String, durationSeconds: Int) {
        // Cancel any existing timer for this activity
        stopProgressUpdates(activityID: activityID)

        print("🔄 Starting progress updates for activity: \(activityID)")

        // Create a repeating timer that fires every second
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.updateActivityProgress(activityID: activityID)
            }
        }

        // Store the timer
        activeTimers[activityID] = timer

        // Also add to common run loop to ensure it fires even in background
        RunLoop.current.add(timer, forMode: .common)
    }

    /// Update the activity progress based on elapsed time
    private func updateActivityProgress(activityID: String) async {
        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found during update: \(activityID)")
            stopProgressUpdates(activityID: activityID)
            return
        }

        guard activity.content.state.phase == .active,
              let startTime = activity.content.state.startTime else {
            print("⚠️ Activity not in active phase")
            stopProgressUpdates(activityID: activityID)
            return
        }

        let totalSeconds = activity.content.state.totalSeconds
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let remaining = max(0, totalSeconds - elapsed)
        let progress = min(1.0, Double(elapsed) / Double(totalSeconds))

        // Check if timer has completed
        if remaining <= 0 {
            print("⏱️ Timer completed, transitioning to completed state")
            await transitionToCompleted(activityID: activityID)
            return
        }

        // Update the activity state
        let newState = PrayerActivityAttributes.ContentState(
            phase: .active,
            startTime: startTime,
            remainingSeconds: remaining,
            totalSeconds: totalSeconds,
            currentProgress: progress,
            lastUpdateTime: Date()
        )

        await activity.update(
            ActivityContent(state: newState, staleDate: activity.content.staleDate)
        )

        // Log every 10 seconds to avoid spam
        if elapsed % 10 == 0 {
            print("🔄 Updated progress: \(remaining)s remaining, \(Int(progress * 100))% complete")
        }
    }

    /// Stop progress updates for an activity
    private func stopProgressUpdates(activityID: String) {
        if let timer = activeTimers[activityID] {
            timer.invalidate()
            activeTimers.removeValue(forKey: activityID)
            print("🛑 Stopped progress updates for activity: \(activityID)")
        }
    }

    // MARK: - Completion

    /// Transition activity to completed phase (when timer finishes)
    private func transitionToCompleted(activityID: String) async {
        // Stop the timer first
        stopProgressUpdates(activityID: activityID)

        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found for completion: \(activityID)")
            return
        }

        let newState = PrayerActivityAttributes.ContentState(
            phase: .completed,
            startTime: activity.content.state.startTime,
            remainingSeconds: 0,
            totalSeconds: activity.content.state.totalSeconds,
            currentProgress: 1.0,
            lastUpdateTime: Date()
        )

        // Set dismissal for 5 minutes from now
        let dismissalDate = Date().addingTimeInterval(300) // 5 minutes

        await activity.update(
            ActivityContent(state: newState, staleDate: dismissalDate)
        )
        print("✅ Prayer timer completed: \(activityID)")

        // Auto-dismiss after 5 minutes
        scheduleAutoDismissal(activityID: activityID, delayMinutes: 5)
    }

    // MARK: - Auto-dismissal

    /// Schedule automatic dismissal of the activity after a delay
    private func scheduleAutoDismissal(activityID: String, delayMinutes: Int) {
        Task {
            // Wait for the delay period
            try? await Task.sleep(nanoseconds: UInt64(delayMinutes * 60) * 1_000_000_000)

            // End the activity if it still exists
            await endActivity(activityID: activityID, dismissalPolicy: .default)
        }
    }

    // MARK: - Ending Activities

    /// End a Live Activity
    func endActivity(activityID: String, dismissalPolicy: ActivityUIDismissalPolicy = .immediate) async {
        // Stop any active timer
        stopProgressUpdates(activityID: activityID)

        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found: \(activityID)")
            return
        }

        await activity.end(nil, dismissalPolicy: dismissalPolicy)
        print("✅ Ended Live Activity: \(activityID)")
    }

    /// End all active prayer Live Activities
    func endAllActivities() async {
        // Stop all timers
        for (activityID, timer) in activeTimers {
            timer.invalidate()
            print("🛑 Stopped timer for: \(activityID)")
        }
        activeTimers.removeAll()

        // End all activities
        for activity in Activity<PrayerActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        print("✅ Ended all Live Activities")
    }

    // MARK: - Helper Methods

    /// Find an active Live Activity by ID
    private func findActivity(id: String) -> Activity<PrayerActivityAttributes>? {
        return Activity<PrayerActivityAttributes>.activities.first { $0.id == id }
    }

    /// Calculate the next occurrence of the alarm time
    private func nextAlarmDate(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard let alarmDate = calendar.date(from: components) else {
            return now
        }

        // If the time has already passed today, schedule for tomorrow
        if alarmDate <= now {
            return calendar.date(byAdding: .day, value: 1, to: alarmDate) ?? alarmDate
        }

        return alarmDate
    }

    // MARK: - Debugging

    /// Get count of active Live Activities
    func activeActivityCount() -> Int {
        return Activity<PrayerActivityAttributes>.activities.count
    }

    /// Print all active Live Activities
    func printActiveActivities() {
        let activities = Activity<PrayerActivityAttributes>.activities
        print("📋 Active Live Activities: \(activities.count)")
        for activity in activities {
            print("  - \(activity.id): \(activity.attributes.prayerTitle) - Phase: \(activity.content.state.phase)")
        }
        print("📋 Active Timers: \(activeTimers.count)")
    }
}
