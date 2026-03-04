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

    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let alarmService: AlarmServiceProtocol
    private let prayerService: PrayerServiceProtocol
    private let alarmRepository: AlarmRepositoryProtocol
    private let prayerRepository: PrayerRepositoryProtocol

    // MARK: - Initialization

    init(
        alarmService: AlarmServiceProtocol,
        prayerService: PrayerServiceProtocol,
        alarmRepository: AlarmRepositoryProtocol,
        prayerRepository: PrayerRepositoryProtocol
    ) {
        self.alarmService = alarmService
        self.prayerService = prayerService
        self.alarmRepository = alarmRepository
        self.prayerRepository = prayerRepository
    }

    // MARK: - Computed Properties (Observe Repositories)

    var alarms: [PrayerAlarm] {
        alarmRepository.alarms
    }

    var prayers: [Prayer] {
        prayerRepository.prayers
    }

    var groupedAlarms: [(prayer: Prayer?, alarms: [PrayerAlarm])] {
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

    // MARK: - View Actions

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await alarmService.fetchAllAlarms()
            _ = try await prayerService.fetchAllPrayers()
            isLoading = false
        } catch {
            errorMessage = "Failed to load data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func toggleAlarm(_ alarm: PrayerAlarm) async {
        do {
            try await alarmService.toggleAlarm(alarm)
        } catch {
            errorMessage = "Failed to toggle alarm: \(error.localizedDescription)"
        }
    }

    func deleteAlarm(_ alarm: PrayerAlarm) async {
        do {
            try await alarmService.deleteAlarm(alarm)
        } catch {
            errorMessage = "Failed to delete alarm: \(error.localizedDescription)"
        }
    }

    func deleteAlarms(at offsets: IndexSet, from alarmsList: [PrayerAlarm]) async {
        for index in offsets {
            let alarm = alarmsList[index]
            await deleteAlarm(alarm)
        }
    }
}
