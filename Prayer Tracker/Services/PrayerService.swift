//
//  PrayerService.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
final class PrayerService: PrayerServiceProtocol {
    private let prayerRepository: PrayerRepositoryProtocol
    private let entryRepository: EntryRepositoryProtocol

    init(
        prayerRepository: PrayerRepositoryProtocol,
        entryRepository: EntryRepositoryProtocol
    ) {
        self.prayerRepository = prayerRepository
        self.entryRepository = entryRepository
    }

    // MARK: - Prayer Operations

    func fetchAllPrayers() async throws -> [Prayer] {
        try prayerRepository.fetchAll()
        try entryRepository.fetchAll()
        return prayerRepository.prayers
    }

    func fetchPrayer(byId id: UUID) async throws -> Prayer? {
        try prayerRepository.fetchById(id)
    }

    func createPrayer(
        title: String,
        subtitle: String,
        iconName: String,
        colorHex: String
    ) async throws -> Prayer {
        let sortOrder = try prayerRepository.getMaxSortOrder() + 1
        let prayer = Prayer(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            subtitle: subtitle.trimmingCharacters(in: .whitespacesAndNewlines),
            iconName: iconName,
            colorHex: colorHex,
            sortOrder: sortOrder
        )
        try prayerRepository.insert(prayer)
        return prayer
    }

    func updatePrayer(_ prayer: Prayer) async throws {
        try prayerRepository.update(prayer)
    }

    func deletePrayer(_ prayer: Prayer) async throws {
        try prayerRepository.delete(prayer)
    }

    // MARK: - Entry Operations

    func checkIn(for prayer: Prayer, at timestamp: Date) async throws -> PrayerEntry {
        let entry = PrayerEntry(timestamp: timestamp, prayer: prayer)
        try entryRepository.insert(entry)
        return entry
    }

    func fetchTodayEntries(for prayer: Prayer) async throws -> [PrayerEntry] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()

        return entryRepository.entriesByDateRange(from: today, to: tomorrow)
            .filter { $0.prayer?.id == prayer.id }
    }
}
