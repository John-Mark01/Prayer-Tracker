//
//  AlarmsViewModelTests.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Testing
import Foundation
@testable import Prayer_Tracker

@Suite("Alarms ViewModel Tests")
@MainActor
struct AlarmsViewModelTests {

    @Test("Load data fetches alarms and prayers")
    func loadData() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        let prayer = Prayer(title: "Morning Prayer")
        let alarm = PrayerAlarm(title: "Morning Alarm", hour: 6, minute: 0, prayer: prayer)

        mockPrayerService.prayersToReturn = [prayer]
        mockAlarmService.alarmsToReturn = [alarm]

        // Act
        await viewModel.loadData()

        // Assert
        #expect(mockAlarmService.fetchAllAlarmsCalled)
        #expect(mockPrayerService.fetchAllPrayersCalled)
        #expect(viewModel.alarms.count == 1)
        #expect(viewModel.prayers.count == 1)
        #expect(viewModel.isLoading == false)
    }

    @Test("Toggle alarm calls service")
    func toggleAlarm() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        let alarm = PrayerAlarm(title: "Test Alarm", hour: 10, minute: 30)

        // Act
        await viewModel.toggleAlarm(alarm)

        // Assert
        #expect(mockAlarmService.toggleAlarmCalled)
        #expect(mockAlarmService.toggledAlarms.count == 1)
        #expect(mockAlarmService.fetchAllAlarmsCalled) // Should reload after toggle
    }

    @Test("Delete alarm calls service")
    func deleteAlarm() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        let alarm = PrayerAlarm(title: "Test Alarm", hour: 10, minute: 30)

        // Act
        await viewModel.deleteAlarm(alarm)

        // Assert
        #expect(mockAlarmService.deleteAlarmCalled)
        #expect(mockAlarmService.deletedAlarms.count == 1)
        #expect(mockAlarmService.fetchAllAlarmsCalled) // Should reload after delete
    }

    @Test("Delete alarms at offsets deletes correct alarms")
    func deleteAlarmsAtOffsets() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        let alarm1 = PrayerAlarm(title: "Alarm 1", hour: 6, minute: 0)
        let alarm2 = PrayerAlarm(title: "Alarm 2", hour: 12, minute: 0)
        let alarm3 = PrayerAlarm(title: "Alarm 3", hour: 18, minute: 0)

        let alarmsList = [alarm1, alarm2, alarm3]
        let offsets = IndexSet([0, 2]) // Delete first and third

        // Act
        await viewModel.deleteAlarms(at: offsets, from: alarmsList)

        // Assert
        #expect(mockAlarmService.deletedAlarms.count == 2)
        #expect(mockAlarmService.deletedAlarms[0].title == "Alarm 1")
        #expect(mockAlarmService.deletedAlarms[1].title == "Alarm 3")
    }

    @Test("Grouped alarms organizes by prayer correctly")
    func groupedAlarms() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        let prayer1 = Prayer(title: "Morning Prayer", sortOrder: 0)
        let prayer2 = Prayer(title: "Evening Prayer", sortOrder: 1)

        let alarm1 = PrayerAlarm(title: "Morning Alarm 1", hour: 6, minute: 0, prayer: prayer1)
        let alarm2 = PrayerAlarm(title: "Morning Alarm 2", hour: 7, minute: 0, prayer: prayer1)
        let alarm3 = PrayerAlarm(title: "Evening Alarm", hour: 18, minute: 0, prayer: prayer2)
        let alarm4 = PrayerAlarm(title: "Orphan Alarm", hour: 12, minute: 0, prayer: nil)

        mockPrayerService.prayersToReturn = [prayer1, prayer2]
        mockAlarmService.alarmsToReturn = [alarm1, alarm2, alarm3, alarm4]

        await viewModel.loadData()

        // Act
        let grouped = viewModel.groupedAlarms

        // Assert
        #expect(grouped.count == 3) // 2 prayers + 1 orphaned group

        // First group should be prayer1 with 2 alarms
        #expect(grouped[0].prayer?.title == "Morning Prayer")
        #expect(grouped[0].alarms.count == 2)

        // Second group should be prayer2 with 1 alarm
        #expect(grouped[1].prayer?.title == "Evening Prayer")
        #expect(grouped[1].alarms.count == 1)

        // Third group should be orphaned alarms
        #expect(grouped[2].prayer == nil)
        #expect(grouped[2].alarms.count == 1)
    }

    @Test("Load data handles errors gracefully")
    func loadDataError() async throws {
        // Arrange
        let mockAlarmService = MockAlarmService()
        let mockPrayerService = MockPrayerService()
        let viewModel = AlarmsViewModel(alarmService: mockAlarmService, prayerService: mockPrayerService)

        mockAlarmService.shouldThrowError = true

        // Act
        await viewModel.loadData()

        // Assert
        #expect(viewModel.alarms.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
}
