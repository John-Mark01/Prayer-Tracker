//
//  PrayerRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol PrayerRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [Prayer]
    func fetchById(_ id: UUID) async throws -> Prayer?
    func insert(_ prayer: Prayer) async throws
    func update(_ prayer: Prayer) async throws
    func delete(_ prayer: Prayer) async throws
    func getMaxSortOrder() async throws -> Int
}
