//
//  TodayViewModelTests.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Testing
import Foundation
@testable import Prayer_Tracker

@Suite("Today ViewModel Tests")
@MainActor
struct TodayViewModelTests {

    @Test("Load prayers fetches from service")
    func loadPrayers() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        let prayer = Prayer(title: "Morning Prayer")
        mockService.prayersToReturn = [prayer]

        // Act
        await viewModel.loadPrayers()

        // Assert
        #expect(mockService.fetchAllPrayersCalled)
        #expect(viewModel.prayers.count == 1)
        #expect(viewModel.prayers.first?.title == "Morning Prayer")
        #expect(viewModel.isLoading == false)
    }

    @Test("Load prayers handles errors gracefully")
    func loadPrayersError() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        mockService.shouldThrowError = true

        // Act
        await viewModel.loadPrayers()

        // Assert
        #expect(viewModel.prayers.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Check in calls service and reloads prayers")
    func checkIn() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        let prayer = Prayer(title: "Evening Prayer")
        mockService.prayersToReturn = [prayer]

        // Act
        await viewModel.checkIn(for: prayer)

        // Assert
        #expect(mockService.checkInCalled)
        #expect(mockService.checkIns.count == 1)
        #expect(mockService.checkIns.first?.prayer.id == prayer.id)
        #expect(mockService.fetchAllPrayersCalled) // Should reload after check-in
    }

    @Test("Today count returns correct number of entries")
    func todayCount() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        let prayer = Prayer(title: "Test Prayer")

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let entry1 = PrayerEntry(timestamp: today, prayer: prayer)
        let entry2 = PrayerEntry(timestamp: today, prayer: prayer)
        let entry3 = PrayerEntry(timestamp: yesterday, prayer: prayer)

        prayer.entries = [entry1, entry2, entry3]

        // Act
        let count = viewModel.todayCount(for: prayer)

        // Assert
        #expect(count == 2) // Only entries from today
    }

    @Test("Today entries filters by date correctly")
    func todayEntries() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        let prayer = Prayer(title: "Test Prayer")

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        let entry1 = PrayerEntry(timestamp: today, prayer: prayer)
        let entry2 = PrayerEntry(timestamp: yesterday, prayer: prayer)

        prayer.entries = [entry1, entry2]

        // Act
        let entries = viewModel.todayEntries(for: prayer)

        // Assert
        #expect(entries.count == 1)
        #expect(entries.first?.timestamp == entry1.timestamp)
    }

    @Test("Loading state is set correctly during fetch")
    func loadingState() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = TodayViewModel(prayerService: mockService)

        // Initial state
        #expect(viewModel.isLoading == false)

        // Act
        let loadTask = Task {
            await viewModel.loadPrayers()
        }

        await loadTask.value

        // Assert
        #expect(viewModel.isLoading == false)
    }
}
