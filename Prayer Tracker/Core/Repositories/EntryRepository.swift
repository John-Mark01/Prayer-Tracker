//
//  EntryRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData

actor EntryRepository: EntryRepositoryProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }

    func fetchAll() async throws -> [PrayerEntry] {
        let descriptor = FetchDescriptor<PrayerEntry>(sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)])
        return try await context.fetch(descriptor)
    }

    func fetchByPrayer(_ prayer: Prayer) async throws -> [PrayerEntry] {
        let prayerId = prayer.id
        let descriptor = FetchDescriptor<PrayerEntry>(
            predicate: #Predicate { $0.prayer?.id == prayerId },
            sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)]
        )
        return try await context.fetch(descriptor)
    }

    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [PrayerEntry] {
        let descriptor = FetchDescriptor<PrayerEntry>(
            predicate: #Predicate { entry in
                entry.timestamp >= startDate && entry.timestamp <= endDate
            },
            sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)]
        )
        return try await context.fetch(descriptor)
    }

    func insert(_ entry: PrayerEntry) async throws {
        await context.insert(entry)
        try await context.save()
    }

    func delete(_ entry: PrayerEntry) async throws {
        await context.delete(entry)
        try await context.save()
    }
}
