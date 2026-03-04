//
//  PrayerRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class PrayerRepository: PrayerRepositoryProtocol {
    // MARK: - Published State

    private(set) var prayers: [Prayer] = []

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
        let descriptor = FetchDescriptor<Prayer>(sortBy: [SortDescriptor(\Prayer.sortOrder)])
        prayers = try context.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> Prayer? {
        prayers.first { $0.id == id }
    }

    // MARK: - Write Operations

    func insert(_ prayer: Prayer) throws {
        context.insert(prayer)
        try context.save()
        try fetchAll()  // Refresh cache
    }

    func update(_ prayer: Prayer) throws {
        // Prayer is already in context, just save
        try context.save()
        try fetchAll()  // Refresh cache
    }

    func delete(_ prayer: Prayer) throws {
        context.delete(prayer)
        try context.save()
        try fetchAll()  // Refresh cache
    }

    // MARK: - Helper Methods

    func getMaxSortOrder() throws -> Int {
        guard let maxPrayer = prayers.max(by: { $0.sortOrder < $1.sortOrder }) else {
            return -1
        }
        return maxPrayer.sortOrder
    }
}
