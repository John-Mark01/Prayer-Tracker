//
//  PrayerServiceProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
protocol PrayerServiceProtocol {
    func fetchAllPrayers() async throws -> [Prayer]
    func fetchPrayer(byId id: UUID) async throws -> Prayer?
    func createPrayer(title: String, subtitle: String, iconName: String, colorHex: String) async throws -> Prayer
    func updatePrayer(_ prayer: Prayer) async throws
    func deletePrayer(_ prayer: Prayer) async throws
    func checkIn(for prayer: Prayer, at timestamp: Date) async throws -> PrayerEntry
    func fetchTodayEntries(for prayer: Prayer) async throws -> [PrayerEntry]
}
