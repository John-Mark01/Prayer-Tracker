//
//  PrayerRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData

actor PrayerRepository: PrayerRepositoryProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }

    nonisolated func fetchAll() async throws -> [Prayer] {
        let descriptor = FetchDescriptor<Prayer>(sortBy: [SortDescriptor(\Prayer.sortOrder)])
        return try await context.fetch(descriptor)
    }

    nonisolated func fetchById(_ id: UUID) async throws -> Prayer? {
        let descriptor = FetchDescriptor<Prayer>(predicate: #Predicate { $0.id == id })
        return try await context.fetch(descriptor).first
    }

    nonisolated func insert(_ prayer: Prayer) async throws {
        await context.insert(prayer)
        try await context.save()
    }

    nonisolated func update(_ prayer: Prayer) async throws {
        try await context.save()
    }

    nonisolated func delete(_ prayer: Prayer) async throws {
        await context.delete(prayer)
        try await context.save()
    }

    func getMaxSortOrder() async throws -> Int {
        let descriptor = FetchDescriptor<Prayer>(sortBy: [SortDescriptor(\Prayer.sortOrder, order: .reverse)])
        guard let prayer = try await context.fetch(descriptor).first else { return -1 }
        return prayer.sortOrder
    }
}
