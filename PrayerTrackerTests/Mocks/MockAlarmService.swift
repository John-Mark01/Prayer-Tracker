//
//  MockAlarmService.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
@testable import Prayer_Tracker

final class MockAlarmService: AlarmServiceProtocol {

    // MARK: - Tracking

    var fetchAllAlarmsCalled = false
    var createAlarmCalled = false
    var toggleAlarmCalled = false
    var deleteAlarmCalled = false
    var updateAlarmCalled = false

    var toggledAlarms: [PrayerAlarm] = []
    var deletedAlarms: [PrayerAlarm] = []
    var updatedAlarms: [PrayerAlarm] = []

    // MARK: - Stubbed Data

    var alarmsToReturn: [PrayerAlarm] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 1)

    // MARK: - Protocol Implementation

    func fetchAllAlarms() async throws -> [PrayerAlarm] {
        fetchAllAlarmsCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return alarmsToReturn
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
        createAlarmCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

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
        alarmsToReturn.append(alarm)
        return alarm
    }

    func toggleAlarm(_ alarm: PrayerAlarm) async throws {
        toggleAlarmCalled = true
        toggledAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func deleteAlarm(_ alarm: PrayerAlarm) async throws {
        deleteAlarmCalled = true
        deletedAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }

        alarmsToReturn.removeAll { $0.title == alarm.title && $0.hour == alarm.hour }
    }

    func updateAlarm(_ alarm: PrayerAlarm) async throws {
        updateAlarmCalled = true
        updatedAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
