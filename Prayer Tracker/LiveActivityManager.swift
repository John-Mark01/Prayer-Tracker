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
            elapsedSeconds: 0,
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

        // Create updated content state (active phase)
        let newState = PrayerActivityAttributes.ContentState(
            phase: .active,
            startTime: Date(),
            elapsedSeconds: 0,
            lastUpdateTime: Date()
        )

        // Set stale date for when the timer ends
        let staleDate = Date().addingTimeInterval(TimeInterval(activity.attributes.durationMinutes * 60))

        await activity.update(
            ActivityContent(state: newState, staleDate: staleDate)
        )
        print("✅ Transitioned activity to active: \(activityID)")

        // Schedule automatic completion when timer ends
        scheduleAutoCompletion(activityID: activityID, durationMinutes: activity.attributes.durationMinutes)
    }

    // MARK: - Auto-completion

    /// Schedule automatic completion when timer ends
    private func scheduleAutoCompletion(activityID: String, durationMinutes: Int) {
        Task {
            // Wait for the prayer duration
            try? await Task.sleep(nanoseconds: UInt64(durationMinutes * 60) * 1_000_000_000)

            // Timer completed - transition to completed state
            await transitionToCompleted(activityID: activityID)
        }
    }

    /// Transition activity to completed phase (when timer finishes)
    private func transitionToCompleted(activityID: String) async {
        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found for completion: \(activityID)")
            return
        }

        let newState = PrayerActivityAttributes.ContentState(
            phase: .completed,
            startTime: activity.content.state.startTime,
            elapsedSeconds: activity.attributes.durationMinutes * 60,
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
        guard let activity = findActivity(id: activityID) else {
            print("⚠️ Activity not found: \(activityID)")
            return
        }

        await activity.end(nil, dismissalPolicy: dismissalPolicy)
        print("✅ Ended Live Activity: \(activityID)")
    }

    /// End all active prayer Live Activities
    func endAllActivities() async {
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
    }
}
