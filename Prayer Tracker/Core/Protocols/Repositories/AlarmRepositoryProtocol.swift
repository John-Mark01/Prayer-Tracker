//
//  AlarmRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

protocol AlarmRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [PrayerAlarm]
    func fetchById(_ id: UUID) async throws -> PrayerAlarm?
    func insert(_ alarm: PrayerAlarm) async throws
    func update(_ alarm: PrayerAlarm) async throws
    func delete(_ alarm: PrayerAlarm) async throws
}
