//
//  CalendarService.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
final class CalendarService: CalendarServiceProtocol {
    private let manager: CalendarManager

    init(manager: CalendarManager = .shared) {
        self.manager = manager
    }

    nonisolated func requestAccess() async -> Bool {
        await manager.requestCalendarAccess()
    }

    nonisolated func createRecurringEvent(for alarm: PrayerAlarm) async -> String? {
        await manager.createCalendarEvent(for: alarm)
    }

    nonisolated func updateRecurringEvent(identifier: String, for alarm: PrayerAlarm) async -> Bool {
        // Delete old event and create new one
        let deleted = await deleteCalendarEvent(identifier: identifier)
        guard deleted else { return false }

        let newIdentifier = await createRecurringEvent(for: alarm)
        return newIdentifier != nil
    }

    nonisolated func deleteCalendarEvent(identifier: String) async -> Bool {
        await MainActor.run {
            manager.deleteCalendarEvent(identifier: identifier)
        }
    }
}
