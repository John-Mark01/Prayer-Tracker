//
//  AddPrayerViewModel.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable final class AddPrayerViewModel {

    // MARK: - Published State

    var title = ""
    var subtitle = ""
    var selectedIcon = "hands.sparkles.fill"
    var selectedColor = Color.green
    var showingIconPicker = false
    var errorMessage: String?

    // MARK: - Dependencies

    private let prayerService: PrayerServiceProtocol

    // MARK: - Initialization

    init(prayerService: PrayerServiceProtocol) {
        self.prayerService = prayerService
    }

    // MARK: - Computed Properties

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - View Actions

    func savePrayer() async -> Bool {
        guard isValid else {
            errorMessage = "Title is required"
            return false
        }

        do {
            _ = try await prayerService.createPrayer(
                title: title,
                subtitle: subtitle,
                iconName: selectedIcon,
                colorHex: selectedColor.toHex() ?? "#9333EA"
            )
            return true
        } catch {
            errorMessage = "Failed to save prayer: \(error.localizedDescription)"
            return false
        }
    }
}
