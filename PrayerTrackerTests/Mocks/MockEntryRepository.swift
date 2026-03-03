//
//  MockEntryRepository.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
@testable import Prayer_Tracker

final class MockEntryRepository: EntryRepositoryProtocol {

    // MARK: - Tracking

    var fetchAllCalled = false
    var fetchByPrayerCalled = false
    var fetchByDateRangeCalled = false
    var insertCalled = false
    var deleteCalled = false

    var insertedEntries: [PrayerEntry] = []
    var deletedEntries: [PrayerEntry] = []

    // MARK: - Stubbed Data

    var entriesToReturn: [PrayerEntry] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 1)

    // MARK: - Protocol Implementation

    func fetchAll() async throws -> [PrayerEntry] {
        fetchAllCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return entriesToReturn
    }

    func fetchByPrayer(_ prayer: Prayer) async throws -> [PrayerEntry] {
        fetchByPrayerCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return entriesToReturn.filter { $0.prayer?.id == prayer.id }
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [PrayerEntry] {
        fetchByDateRangeCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return entriesToReturn.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }

    func insert(_ entry: PrayerEntry) async throws {
        insertCalled = true
        insertedEntries.append(entry)

        if shouldThrowError {
            throw errorToThrow
        }

        entriesToReturn.append(entry)
    }

    func delete(_ entry: PrayerEntry) async throws {
        deleteCalled = true
        deletedEntries.append(entry)

        if shouldThrowError {
            throw errorToThrow
        }
    }
}
