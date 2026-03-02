//
//  CalendarServiceProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol CalendarServiceProtocol: Sendable {
    func requestAccess() async -> Bool
    func createRecurringEvent(for alarm: PrayerAlarm) async -> String?
    func updateRecurringEvent(identifier: String, for alarm: PrayerAlarm) async -> Bool
    func deleteCalendarEvent(identifier: String) async -> Bool
}
