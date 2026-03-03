//
//  PrayerRepositoryTests.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Testing
import SwiftData
@testable import Prayer_Tracker

@Suite("Prayer Repository Tests")
struct PrayerRepositoryTests {

    @Test("Fetch all prayers returns empty array initially")
    func fetchAllEmpty() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)

        // Act
        let prayers = try await repository.fetchAll()

        // Assert
        #expect(prayers.isEmpty)
    }

    @Test("Insert prayer adds it to database")
    func insertPrayer() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)
        let prayer = Prayer(title: "Morning Prayer", subtitle: "Start the day", iconName: "sun.max", colorHex: "#FF0000")

        // Act
        try await repository.insert(prayer)
        let allPrayers = try await repository.fetchAll()

        // Assert
        #expect(allPrayers.count == 1)
        #expect(allPrayers.first?.title == "Morning Prayer")
        #expect(allPrayers.first?.subtitle == "Start the day")
    }

    @Test("Fetch by ID returns correct prayer")
    func fetchById() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)
        let prayer = Prayer(title: "Evening Prayer", iconName: "moon.fill", colorHex: "#0000FF")
        try await repository.insert(prayer)

        // Act
        let fetched = try await repository.fetchById(prayer.id)

        // Assert
        #expect(fetched != nil)
        #expect(fetched?.id == prayer.id)
        #expect(fetched?.title == "Evening Prayer")
    }

    @Test("Delete prayer removes it from database")
    func deletePrayer() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)
        let prayer = Prayer(title: "Test Prayer", iconName: "hands.sparkles", colorHex: "#00FF00")
        try await repository.insert(prayer)

        // Act
        try await repository.delete(prayer)
        let allPrayers = try await repository.fetchAll()

        // Assert
        #expect(allPrayers.isEmpty)
    }

    @Test("Get max sort order returns correct value")
    func getMaxSortOrder() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)

        let prayer1 = Prayer(title: "Prayer 1", sortOrder: 0)
        let prayer2 = Prayer(title: "Prayer 2", sortOrder: 5)
        let prayer3 = Prayer(title: "Prayer 3", sortOrder: 2)

        try await repository.insert(prayer1)
        try await repository.insert(prayer2)
        try await repository.insert(prayer3)

        // Act
        let maxOrder = try await repository.getMaxSortOrder()

        // Assert
        #expect(maxOrder == 5)
    }

    @Test("Fetch all returns prayers sorted by sort order")
    func fetchAllSorted() async throws {
        // Arrange
        let container = try ModelContainer(
            for: Prayer.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let repository = PrayerRepository(modelContainer: container)

        let prayer1 = Prayer(title: "Prayer C", sortOrder: 2)
        let prayer2 = Prayer(title: "Prayer A", sortOrder: 0)
        let prayer3 = Prayer(title: "Prayer B", sortOrder: 1)

        try await repository.insert(prayer1)
        try await repository.insert(prayer2)
        try await repository.insert(prayer3)

        // Act
        let prayers = try await repository.fetchAll()

        // Assert
        #expect(prayers.count == 3)
        #expect(prayers[0].title == "Prayer A")
        #expect(prayers[1].title == "Prayer B")
        #expect(prayers[2].title == "Prayer C")
    }
}
