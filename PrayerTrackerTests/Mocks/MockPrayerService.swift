//
//  MockPrayerService.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
@testable import Prayer_Tracker

final class MockPrayerService: PrayerServiceProtocol {

    // MARK: - Tracking

    var fetchAllPrayersCalled = false
    var fetchPrayerCalled = false
    var createPrayerCalled = false
    var updatePrayerCalled = false
    var deletePrayerCalled = false
    var checkInCalled = false
    var fetchTodayEntriesCalled = false

    var createdPrayers: [(title: String, subtitle: String, iconName: String, colorHex: String)] = []
    var updatedPrayers: [Prayer] = []
    var deletedPrayers: [Prayer] = []
    var checkIns: [(prayer: Prayer, timestamp: Date)] = []

    // MARK: - Stubbed Data

    var prayersToReturn: [Prayer] = []
    var prayerToReturn: Prayer?
    var entriesToReturn: [PrayerEntry] = []
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 1)

    // MARK: - Protocol Implementation

    func fetchAllPrayers() async throws -> [Prayer] {
        fetchAllPrayersCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return prayersToReturn
    }

    func fetchPrayer(byId id: UUID) async throws -> Prayer? {
        fetchPrayerCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return prayerToReturn
    }

    func createPrayer(title: String, subtitle: String, iconName: String, colorHex: String) async throws -> Prayer {
        createPrayerCalled = true
        createdPrayers.append((title, subtitle, iconName, colorHex))

        if shouldThrowError {
            throw errorToThrow
        }

        let prayer = Prayer(
            title: title,
            subtitle: subtitle,
            iconName: iconName,
            colorHex: colorHex,
            sortOrder: prayersToReturn.count
        )
        prayersToReturn.append(prayer)
        return prayer
    }

    func updatePrayer(_ prayer: Prayer) async throws {
        updatePrayerCalled = true
        updatedPrayers.append(prayer)

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func deletePrayer(_ prayer: Prayer) async throws {
        deletePrayerCalled = true
        deletedPrayers.append(prayer)

        if shouldThrowError {
            throw errorToThrow
        }

        prayersToReturn.removeAll { $0.id == prayer.id }
    }

    func checkIn(for prayer: Prayer, at timestamp: Date) async throws -> PrayerEntry {
        checkInCalled = true
        checkIns.append((prayer, timestamp))

        if shouldThrowError {
            throw errorToThrow
        }

        let entry = PrayerEntry(timestamp: timestamp, prayer: prayer)
        entriesToReturn.append(entry)
        return entry
    }

    func fetchTodayEntries(for prayer: Prayer) async throws -> [PrayerEntry] {
        fetchTodayEntriesCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return entriesToReturn
    }
}
