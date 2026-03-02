//
//  TodayViewModel.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import Observation

@MainActor
@Observable final class TodayViewModel {

    // MARK: - Published State

    private(set) var prayers: [Prayer] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let prayerService: PrayerServiceProtocol

    // MARK: - Initialization

    init(prayerService: PrayerServiceProtocol) {
        self.prayerService = prayerService
    }

    // MARK: - View Actions

    func loadPrayers() async {
        isLoading = true
        errorMessage = nil

        do {
            prayers = try await prayerService.fetchAllPrayers()
            isLoading = false
        } catch {
            errorMessage = "Failed to load prayers: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func checkIn(for prayer: Prayer) async {
        do {
            _ = try await prayerService.checkIn(for: prayer, at: Date())
            await loadPrayers()
        } catch {
            errorMessage = "Failed to check in: \(error.localizedDescription)"
        }
    }

    // MARK: - Computed Properties

    func todayCount(for prayer: Prayer) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return prayer.entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }.count
    }

    func todayEntries(for prayer: Prayer) -> [PrayerEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return prayer.entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }
}
