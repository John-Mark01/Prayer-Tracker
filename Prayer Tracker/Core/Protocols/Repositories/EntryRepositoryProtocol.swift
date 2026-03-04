//
//  EntryRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
protocol EntryRepositoryProtocol {
    var entries: [PrayerEntry] { get }

    func fetchAll() throws
    func entriesByPrayer(_ prayer: Prayer) -> [PrayerEntry]
    func entriesByDateRange(from startDate: Date, to endDate: Date) -> [PrayerEntry]
    func insert(_ entry: PrayerEntry) throws
    func delete(_ entry: PrayerEntry) throws
}
