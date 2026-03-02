//
//  AlarmRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData

actor AlarmRepository: AlarmRepositoryProtocol {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    @MainActor
    private var context: ModelContext {
        modelContainer.mainContext
    }

    func fetchAll() async throws -> [PrayerAlarm] {
        let descriptor = FetchDescriptor<PrayerAlarm>(
            sortBy: [
                SortDescriptor(\PrayerAlarm.hour),
                SortDescriptor(\PrayerAlarm.minute)
            ]
        )
        return try await context.fetch(descriptor)
    }

    func fetchById(_ id: UUID) async throws -> PrayerAlarm? {
        // Note: PrayerAlarm doesn't have id property, need to add it or use different lookup
        // For now, returning nil - this should be addressed in model refactoring
        return nil
    }

    func insert(_ alarm: PrayerAlarm) async throws {
        await context.insert(alarm)
        try await context.save()
    }

    func update(_ alarm: PrayerAlarm) async throws {
        try await context.save()
    }

    func delete(_ alarm: PrayerAlarm) async throws {
        await context.delete(alarm)
        try await context.save()
    }
}
