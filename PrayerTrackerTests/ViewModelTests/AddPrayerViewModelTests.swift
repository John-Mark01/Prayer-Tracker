//
//  AddPrayerViewModelTests.swift
//  PrayerTrackerTests
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Testing
import SwiftUI
@testable import Prayer_Tracker

@Suite("Add Prayer ViewModel Tests")
@MainActor
struct AddPrayerViewModelTests {

    @Test("Initial state is empty")
    func initialState() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        // Assert
        #expect(viewModel.title.isEmpty)
        #expect(viewModel.subtitle.isEmpty)
        #expect(viewModel.selectedIcon == "hands.sparkles.fill")
        #expect(viewModel.selectedColor == .green)
        #expect(viewModel.showingIconPicker == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Is valid returns false for empty title")
    func isValidEmptyTitle() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = ""

        // Assert
        #expect(viewModel.isValid == false)
    }

    @Test("Is valid returns false for whitespace-only title")
    func isValidWhitespaceTitle() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = "   "

        // Assert
        #expect(viewModel.isValid == false)
    }

    @Test("Is valid returns true for non-empty title")
    func isValidNonEmptyTitle() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = "Morning Prayer"

        // Assert
        #expect(viewModel.isValid == true)
    }

    @Test("Save prayer creates prayer with correct data")
    func savePrayer() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = "Evening Prayer"
        viewModel.subtitle = "End the day"
        viewModel.selectedIcon = "moon.fill"
        viewModel.selectedColor = .blue

        // Act
        let success = await viewModel.savePrayer()

        // Assert
        #expect(success == true)
        #expect(mockService.createPrayerCalled)
        #expect(mockService.createdPrayers.count == 1)
        #expect(mockService.createdPrayers.first?.title == "Evening Prayer")
        #expect(mockService.createdPrayers.first?.subtitle == "End the day")
        #expect(mockService.createdPrayers.first?.iconName == "moon.fill")
    }

    @Test("Save prayer returns false for invalid title")
    func savePrayerInvalidTitle() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = ""

        // Act
        let success = await viewModel.savePrayer()

        // Assert
        #expect(success == false)
        #expect(mockService.createPrayerCalled == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Save prayer handles errors gracefully")
    func savePrayerError() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        mockService.shouldThrowError = true
        viewModel.title = "Test Prayer"

        // Act
        let success = await viewModel.savePrayer()

        // Assert
        #expect(success == false)
        #expect(viewModel.errorMessage != nil)
    }

    @Test("Color hex conversion works correctly")
    func colorHexConversion() async throws {
        // Arrange
        let mockService = MockPrayerService()
        let viewModel = AddPrayerViewModel(prayerService: mockService)

        viewModel.title = "Test"
        viewModel.selectedColor = .red

        // Act
        _ = await viewModel.savePrayer()

        // Assert
        #expect(mockService.createdPrayers.first?.colorHex != nil)
    }
}
