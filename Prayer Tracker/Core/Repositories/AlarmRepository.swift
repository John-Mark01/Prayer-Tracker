//
//  AlarmRepository.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class AlarmRepository: AlarmRepositoryProtocol {
    // MARK: - Published State

    private(set) var alarms: [PrayerAlarm] = []

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
        let descriptor = FetchDescriptor<PrayerAlarm>(
            sortBy: [
                SortDescriptor(\PrayerAlarm.hour),
                SortDescriptor(\PrayerAlarm.minute)
            ]
        )
        alarms = try context.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> PrayerAlarm? {
        // Note: PrayerAlarm doesn't have id property
        // Search by UUID if needed, or return nil
        return nil
    }

    // MARK: - Write Operations

    func insert(_ alarm: PrayerAlarm) throws {
        context.insert(alarm)
        try context.save()
        try fetchAll()  // Refresh cache
    }

    func update(_ alarm: PrayerAlarm) throws {
        try context.save()
        try fetchAll()  // Refresh cache
    }

    func delete(_ alarm: PrayerAlarm) throws {
        context.delete(alarm)
        try context.save()
        try fetchAll()  // Refresh cache
    }
}
