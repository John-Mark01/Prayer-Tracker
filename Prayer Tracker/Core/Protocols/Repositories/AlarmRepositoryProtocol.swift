//
//  AlarmRepositoryProtocol.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation

@MainActor
protocol AlarmRepositoryProtocol {
    var alarms: [PrayerAlarm] { get }

    func fetchAll() throws
    func fetchById(_ id: UUID) throws -> PrayerAlarm?
    func insert(_ alarm: PrayerAlarm) throws
    func update(_ alarm: PrayerAlarm) throws
    func delete(_ alarm: PrayerAlarm) throws
}
