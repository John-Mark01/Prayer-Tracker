//
//  LiveActivityService.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
final class LiveActivityService: LiveActivityServiceProtocol {
    private let manager: LiveActivityManager

    init(manager: LiveActivityManager = .shared) {
        self.manager = manager
    }

    func areActivitiesEnabled() -> Bool {
        manager.areActivitiesEnabled()
    }

    nonisolated func startWarningActivity(for alarm: PrayerAlarm) async -> String? {
        await manager.startWarningActivity(for: alarm)
    }

    nonisolated func transitionToReady(activityID: String) async {
        await manager.transitionToReady(activityID: activityID)
    }

    nonisolated func startPrayerCountdown(activityID: String) async {
        await manager.startPrayerCountdown(activityID: activityID)
    }

    nonisolated func endActivity(activityID: String) async {
        await manager.endActivity(activityID: activityID)
    }

    nonisolated func endAllActivities() async {
        await manager.endAllActivities()
    }

    func activeActivityCount() -> Int {
        manager.activeActivityCount()
    }
}
