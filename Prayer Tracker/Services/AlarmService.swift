//
//  AlarmService.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
final class AlarmService: AlarmServiceProtocol {
    private let alarmRepository: AlarmRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private let liveActivityService: LiveActivityServiceProtocol
    private let calendarService: CalendarServiceProtocol

    init(
        alarmRepository: AlarmRepositoryProtocol,
        notificationService: NotificationServiceProtocol,
        liveActivityService: LiveActivityServiceProtocol,
        calendarService: CalendarServiceProtocol
    ) {
        self.alarmRepository = alarmRepository
        self.notificationService = notificationService
        self.liveActivityService = liveActivityService
        self.calendarService = calendarService
    }

    func fetchAllAlarms() async throws -> [PrayerAlarm] {
        try alarmRepository.fetchAll()
        return alarmRepository.alarms
    }

    func createAlarm(
        title: String,
        hour: Int,
        minute: Int,
        durationMinutes: Int,
        reminderMinutesBefore: Int,
        enableCalendar: Bool,
        prayer: Prayer?
    ) async throws -> PrayerAlarm {
        let alarm = PrayerAlarm(
            title: title,
            hour: hour,
            minute: minute,
            durationMinutes: durationMinutes,
            isEnabled: true,
            prayer: prayer,
            addToCalendar: enableCalendar,
            hasReminder: reminderMinutesBefore > 0,
            reminderMinutesBefore: reminderMinutesBefore
        )

        // Insert alarm first
        try alarmRepository.insert(alarm)

        // Schedule notifications
        if alarm.isEnabled {
            alarm.notificationIdentifier = await notificationService.scheduleAlarmNotification(for: alarm)

            if alarm.hasReminder {
                alarm.warningNotificationIdentifier = await notificationService.scheduleWarningNotification(for: alarm)
            }
        }

        // Create calendar event if enabled
        if alarm.addToCalendar {
            alarm.calendarIdentifier = await calendarService.createRecurringEvent(for: alarm)
        }

        // Update alarm with identifiers
        try alarmRepository.update(alarm)

        return alarm
    }

    func toggleAlarm(_ alarm: PrayerAlarm) async throws {
        alarm.isEnabled.toggle()

        if alarm.isEnabled {
            // Re-schedule notifications
            alarm.notificationIdentifier = await notificationService.scheduleAlarmNotification(for: alarm)

            if alarm.hasReminder {
                alarm.warningNotificationIdentifier = await notificationService.scheduleWarningNotification(for: alarm)
            }

            // Re-create calendar event if needed
            if alarm.addToCalendar {
                alarm.calendarIdentifier = await calendarService.createRecurringEvent(for: alarm)
            }
        } else {
            // Cancel notifications
            if let notificationId = alarm.notificationIdentifier {
                await notificationService.cancelNotification(identifier: notificationId)
                alarm.notificationIdentifier = nil
            }

            if let warningId = alarm.warningNotificationIdentifier {
                await notificationService.cancelNotification(identifier: warningId)
                alarm.warningNotificationIdentifier = nil
            }

            // Delete calendar event
            if let calendarId = alarm.calendarIdentifier {
                _ = await calendarService.deleteCalendarEvent(identifier: calendarId)
                alarm.calendarIdentifier = nil
            }

            // End live activity
            if let activityId = alarm.liveActivityId {
                await liveActivityService.endActivity(activityID: activityId)
                alarm.liveActivityId = nil
            }
        }

        try alarmRepository.update(alarm)
    }

    func deleteAlarm(_ alarm: PrayerAlarm) async throws {
        // Cancel alarm notification
        if let notificationId = alarm.notificationIdentifier {
            await notificationService.cancelNotification(identifier: notificationId)
        }

        // Cancel warning notification
        if let warningId = alarm.warningNotificationIdentifier {
            await notificationService.cancelNotification(identifier: warningId)
        }

        // Delete calendar event
        if let calendarId = alarm.calendarIdentifier {
            _ = await calendarService.deleteCalendarEvent(identifier: calendarId)
        }

        // End live activity
        if let activityId = alarm.liveActivityId {
            await liveActivityService.endActivity(activityID: activityId)
        }

        // Delete from database
        try alarmRepository.delete(alarm)
    }

    func updateAlarm(_ alarm: PrayerAlarm) async throws {
        try alarmRepository.update(alarm)
    }
}
