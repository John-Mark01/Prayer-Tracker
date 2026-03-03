//
//  PrayerServiceTests.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Testing
import Foundation
@testable import Prayer_Tracker

@Suite("Prayer Service Tests")
@MainActor
struct PrayerServiceTests {

    @Test("Fetch all prayers calls repository")
    func fetchAllPrayers() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        let prayer = Prayer(title: "Test Prayer")
        mockPrayerRepo.prayersToReturn = [prayer]

        // Act
        let prayers = try await service.fetchAllPrayers()

        // Assert
        #expect(mockPrayerRepo.fetchAllCalled)
        #expect(prayers.count == 1)
        #expect(prayers.first?.title == "Test Prayer")
    }

    @Test("Create prayer sets correct sort order")
    func createPrayer() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        mockPrayerRepo.maxSortOrderToReturn = 2

        // Act
        let prayer = try await service.createPrayer(
            title: "New Prayer",
            subtitle: "Subtitle",
            iconName: "hands.sparkles",
            colorHex: "#FF0000"
        )

        // Assert
        #expect(mockPrayerRepo.insertCalled)
        #expect(mockPrayerRepo.insertedPrayers.count == 1)
        #expect(mockPrayerRepo.insertedPrayers.first?.title == "New Prayer")
        #expect(prayer.sortOrder == 3) // max + 1
    }

    @Test("Create prayer trims whitespace from title and subtitle")
    func createPrayerTrimsWhitespace() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        // Act
        let prayer = try await service.createPrayer(
            title: "  Whitespace Title  ",
            subtitle: "  Whitespace Subtitle  ",
            iconName: "hands.sparkles",
            colorHex: "#FF0000"
        )

        // Assert
        #expect(prayer.title == "Whitespace Title")
        #expect(prayer.subtitle == "Whitespace Subtitle")
    }

    @Test("Check in creates entry with correct timestamp")
    func checkIn() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        let prayer = Prayer(title: "Test Prayer")
        let timestamp = Date()

        // Act
        let entry = try await service.checkIn(for: prayer, at: timestamp)

        // Assert
        #expect(mockEntryRepo.insertCalled)
        #expect(mockEntryRepo.insertedEntries.count == 1)
        #expect(mockEntryRepo.insertedEntries.first?.timestamp == timestamp)
        #expect(mockEntryRepo.insertedEntries.first?.prayer?.id == prayer.id)
    }

    @Test("Delete prayer calls repository delete")
    func deletePrayer() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        let prayer = Prayer(title: "Test Prayer")

        // Act
        try await service.deletePrayer(prayer)

        // Assert
        #expect(mockPrayerRepo.deleteCalled)
        #expect(mockPrayerRepo.deletedPrayers.count == 1)
        #expect(mockPrayerRepo.deletedPrayers.first?.id == prayer.id)
    }

    @Test("Fetch all prayers propagates repository errors")
    func fetchAllPrayersError() async throws {
        // Arrange
        let mockPrayerRepo = MockPrayerRepository()
        let mockEntryRepo = MockEntryRepository()
        let service = PrayerService(prayerRepository: mockPrayerRepo, entryRepository: mockEntryRepo)

        mockPrayerRepo.shouldThrowError = true

        // Act & Assert
        do {
            _ = try await service.fetchAllPrayers()
            #expect(Bool(false), "Should have thrown an error")
        } catch {
            #expect(error != nil)
        }
    }
}
