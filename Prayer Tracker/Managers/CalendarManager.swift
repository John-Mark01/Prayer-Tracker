//
//  CalendarManager.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import Foundation
internal import EventKit

@MainActor
@Observable class CalendarManager {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    private init() {}

    // MARK: - Authorization

    /// Request calendar permission from user
    func requestCalendarAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            return granted
        } catch {
            print("❌ Error requesting calendar access: \(error)")
            return false
        }
    }

    /// Check if calendar access is authorized
    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }

    // MARK: - Event Creation

    /// Create a recurring calendar event for a prayer alarm
    /// Returns the event identifier if successful
    func createCalendarEvent(for alarm: PrayerAlarm) async -> String? {
        // Check authorization first
        let status = checkAuthorizationStatus()
        guard status == .fullAccess else {
            print("⚠️ Calendar not authorized. Status: \(status)")
            return nil
        }

        // Ensure default calendar exists
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            print("❌ No default calendar found")
            return nil
        }

        // Create event
        let event = EKEvent(eventStore: eventStore)
        event.title = "🙏 \(alarm.displayTitle)"
        event.notes = "Prayer time - \(alarm.durationMinutes) minutes"
        event.calendar = defaultCalendar

        // Set start time (next occurrence of alarm time)
        let startDate = nextAlarmDate(hour: alarm.hour, minute: alarm.minute)
        event.startDate = startDate

        // Set end time (start + duration)
        let durationInSeconds = TimeInterval(alarm.durationMinutes * 60)
        event.endDate = startDate.addingTimeInterval(durationInSeconds)

        // Set daily recurrence (never ends)
        let recurrenceRule = EKRecurrenceRule(
            recurrenceWith: .daily,
            interval: 1,
            end: nil
        )
        event.addRecurrenceRule(recurrenceRule)

        // Add alert at event start time (optional, calendar can alert too)
        let eventAlarm = EKAlarm(relativeOffset: 0) // At event time
        event.addAlarm(eventAlarm)

        // Save event
        do {
            try eventStore.save(event, span: .futureEvents, commit: true)
            print("✅ Created calendar event for \(alarm.displayTitle) at \(alarm.timeString)")
            return event.eventIdentifier
        } catch {
            print("❌ Error creating calendar event: \(error)")
            return nil
        }
    }

    // MARK: - Event Deletion

    /// Delete a calendar event by its identifier
    func deleteCalendarEvent(identifier: String) -> Bool {
        guard let event = eventStore.event(withIdentifier: identifier) else {
            print("⚠️ Event not found: \(identifier)")
            return false
        }

        do {
            try eventStore.remove(event, span: .futureEvents, commit: true)
            print("🗑️ Deleted calendar event: \(identifier)")
            return true
        } catch {
            print("❌ Error deleting calendar event: \(error)")
            return false
        }
    }

    // MARK: - Helper Methods

    /// Calculate the next occurrence of the alarm time
    /// If the time hasn't passed today, returns today's date
    /// If the time has already passed, returns tomorrow's date
    private func nextAlarmDate(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()

        // Get today's date components
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard var alarmDate = calendar.date(from: components) else {
            return now
        }

        // If alarm time has already passed today, schedule for tomorrow
        if alarmDate < now {
            if let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: alarmDate) {
                alarmDate = tomorrowDate
            }
        }

        return alarmDate
    }

    // MARK: - Debugging

    /// Get all calendar events (for debugging)
    func getUpcomingEvents() -> [EKEvent] {
        guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
            return []
        }

        let now = Date()
        let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: now) ?? now

        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: oneMonthLater,
            calendars: [defaultCalendar]
        )

        return eventStore.events(matching: predicate)
    }

    /// Print all prayer events (for debugging)
    func printPrayerEvents() {
        let events = getUpcomingEvents().filter { $0.title.hasPrefix("🙏") }
        print("📅 Prayer calendar events: \(events.count)")
        for event in events {
            print("  - \(event.title ?? "Untitled"): \(event.startDate)")
        }
    }
}
