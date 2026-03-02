//
//  EntryRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol EntryRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [PrayerEntry]
    func fetchByPrayer(_ prayer: Prayer) async throws -> [PrayerEntry]
    func fetchByDateRange(from startDate: Date, to endDate: Date) async throws -> [PrayerEntry]
    func insert(_ entry: PrayerEntry) async throws
    func delete(_ entry: PrayerEntry) async throws
}
