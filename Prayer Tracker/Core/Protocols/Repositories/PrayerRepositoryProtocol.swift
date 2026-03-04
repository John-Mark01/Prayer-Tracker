//
//  PrayerRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
protocol PrayerRepositoryProtocol {
    var prayers: [Prayer] { get }

    func fetchAll() throws
    func fetchById(_ id: UUID) throws -> Prayer?
    func insert(_ prayer: Prayer) throws
    func update(_ prayer: Prayer) throws
    func delete(_ prayer: Prayer) throws
    func getMaxSortOrder() throws -> Int
}
