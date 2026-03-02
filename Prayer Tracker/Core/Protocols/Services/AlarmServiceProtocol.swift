//
//  AlarmServiceProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol AlarmServiceProtocol: Sendable {
    func fetchAllAlarms() async throws -> [PrayerAlarm]
    func createAlarm(
        title: String,
        hour: Int,
        minute: Int,
        durationMinutes: Int,
        reminderMinutesBefore: Int,
        enableCalendar: Bool,
        prayer: Prayer?
    ) async throws -> PrayerAlarm
    func toggleAlarm(_ alarm: PrayerAlarm) async throws
    func deleteAlarm(_ alarm: PrayerAlarm) async throws
    func updateAlarm(_ alarm: PrayerAlarm) async throws
}
