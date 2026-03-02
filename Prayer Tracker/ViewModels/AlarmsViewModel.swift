//
//  AlarmsViewModel.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import Observation

@MainActor
@Observable final class AlarmsViewModel {

    // MARK: - Published State

    private(set) var alarms: [PrayerAlarm] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let alarmService: AlarmServiceProtocol

    // MARK: - Initialization

    init(alarmService: AlarmServiceProtocol) {
        self.alarmService = alarmService
    }

    // MARK: - View Actions

    func loadAlarms() async {
        isLoading = true
        errorMessage = nil

        do {
            alarms = try await alarmService.fetchAllAlarms()
            isLoading = false
        } catch {
            errorMessage = "Failed to load alarms: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func toggleAlarm(_ alarm: PrayerAlarm) async {
        do {
            try await alarmService.toggleAlarm(alarm)
            await loadAlarms()
        } catch {
            errorMessage = "Failed to toggle alarm: \(error.localizedDescription)"
        }
    }

    func deleteAlarm(_ alarm: PrayerAlarm) async {
        do {
            try await alarmService.deleteAlarm(alarm)
            await loadAlarms()
        } catch {
            errorMessage = "Failed to delete alarm: \(error.localizedDescription)"
        }
    }

    // MARK: - Computed Properties

    func groupedAlarms(prayers: [Prayer]) -> [(prayer: Prayer?, alarms: [PrayerAlarm])] {
        let grouped = Dictionary(grouping: alarms) { $0.prayer }

        var result: [(Prayer?, [PrayerAlarm])] = []

        // Add prayers with alarms
        for prayer in prayers {
            if let prayerAlarms = grouped[prayer], !prayerAlarms.isEmpty {
                result.append((prayer, prayerAlarms))
            }
        }

        // Add orphaned alarms (no prayer associated)
        if let orphanedAlarms = grouped[nil], !orphanedAlarms.isEmpty {
            result.append((nil, orphanedAlarms))
        }

        return result
    }
}
