//
//  EntryRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class EntryRepository: EntryRepositoryProtocol {
    // MARK: - Published State

    private(set) var entries: [PrayerEntry] = []

    // MARK: - Private Properties

    private let modelContainer: ModelContainer

    private var context: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Initialization

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    // MARK: - Fetch Operations

    func fetchAll() throws {
        let descriptor = FetchDescriptor<PrayerEntry>(sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)])
        entries = try context.fetch(descriptor)
    }

    func entriesByPrayer(_ prayer: Prayer) -> [PrayerEntry] {
        entries.filter { $0.prayer?.id == prayer.id }
    }

    func entriesByDateRange(from startDate: Date, to endDate: Date) -> [PrayerEntry] {
        entries.filter { entry in
            entry.timestamp >= startDate && entry.timestamp <= endDate
        }
    }

    // MARK: - Write Operations

    func insert(_ entry: PrayerEntry) throws {
        context.insert(entry)
        try context.save()
        try fetchAll()  // Refresh cache
    }

    func delete(_ entry: PrayerEntry) throws {
        context.delete(entry)
        try context.save()
        try fetchAll()  // Refresh cache
    }
}
