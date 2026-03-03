//
//  MockPrayerRepository.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
@testable import Prayer_Tracker

final class MockPrayerRepository: PrayerRepositoryProtocol {

    // MARK: - Tracking

    var fetchAllCalled = false
    var fetchByIdCalled = false
    var insertCalled = false
    var updateCalled = false
    var deleteCalled = false

    var insertedPrayers: [Prayer] = []
    var updatedPrayers: [Prayer] = []
    var deletedPrayers: [Prayer] = []
    var fetchByIdRequests: [UUID] = []

    // MARK: - Stubbed Data

    var prayersToReturn: [Prayer] = []
    var prayerToReturnById: Prayer?
    var maxSortOrderToReturn: Int = -1
    var shouldThrowError = false
    var errorToThrow: Error = NSError(domain: "test", code: 1)

    // MARK: - Protocol Implementation

    func fetchAll() async throws -> [Prayer] {
        fetchAllCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return prayersToReturn
    }

    func fetchById(_ id: UUID) async throws -> Prayer? {
        fetchByIdCalled = true
        fetchByIdRequests.append(id)

        if shouldThrowError {
            throw errorToThrow
        }

        return prayerToReturnById
    }

    func insert(_ prayer: Prayer) async throws {
        insertCalled = true
        insertedPrayers.append(prayer)

        if shouldThrowError {
            throw errorToThrow
        }

        prayersToReturn.append(prayer)
    }

    func update(_ prayer: Prayer) async throws {
        updateCalled = true
        updatedPrayers.append(prayer)

        if shouldThrowError {
            throw errorToThrow
        }
    }

    func delete(_ prayer: Prayer) async throws {
        deleteCalled = true
        deletedPrayers.append(prayer)

        if shouldThrowError {
            throw errorToThrow
        }

        prayersToReturn.removeAll { $0.id == prayer.id }
    }

    func getMaxSortOrder() async throws -> Int {
        if shouldThrowError {
            throw errorToThrow
        }

        return maxSortOrderToReturn
    }
}
