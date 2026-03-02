//
//  LiveActivityServiceProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol LiveActivityServiceProtocol: Sendable {
    func areActivitiesEnabled() -> Bool

    func startWarningActivity(for alarm: PrayerAlarm) async -> String?
    func transitionToReady(activityID: String) async
    func startPrayerCountdown(activityID: String) async
    func endActivity(activityID: String) async
    func endAllActivities() async

    func activeActivityCount() -> Int
}
