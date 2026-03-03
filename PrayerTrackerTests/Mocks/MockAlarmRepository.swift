//
//  MockAlarmRepository.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
@testable import Prayer_Tracker

final class MockAlarmRepository: AlarmRepositoryProtocol {

    // MARK: - Tracking

    var fetchAllCalled = false
    var fetchByIdCalled = false
    var insertCalled = false
    var updateCalled = false
    var deleteCalled = false

    var insertedAlarms: [PrayerAlarm] = []
    var updatedAlarms: [PrayerAlarm] = []
    var deletedAlarms: [PrayerAlarm] = []

    // MARK: - Stubbed Data

    var alarmsToReturn: [PrayerAlarm] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 1)

    // MARK: - Protocol Implementation

    func fetchAll() async throws -> [PrayerAlarm] {
        fetchAllCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return alarmsToReturn
    }

    func fetchById(_ id: UUID) async throws -> PrayerAlarm? {
        fetchByIdCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return nil
    }

    func insert(_ alarm: PrayerAlarm) async throws {
        insertCalled = true
        insertedAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }

        alarmsToReturn.append(alarm)
    }

    func update(_ alarm: PrayerAlarm) async throws {
        updateCalled = true
        updatedAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func delete(_ alarm: PrayerAlarm) async throws {
        deleteCalled = true
        deletedAlarms.append(alarm)

        if shouldThrowError {
            throw errorToThrow
        }

        alarmsToReturn.removeAll { $0.title == alarm.title && $0.hour == alarm.hour }
    }
}
