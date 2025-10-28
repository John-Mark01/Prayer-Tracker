//
//  Prayer.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import Foundation
import SwiftData

@Model
final class Prayer: Identifiable {
    var id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var colorHex: String
    var createdDate: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \PrayerEntry.prayer)
    var entries: [PrayerEntry]

    @Relationship(deleteRule: .cascade, inverse: \PrayerAlarm.prayer)
    var alarms: [PrayerAlarm]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        iconName: String = "hands.sparkles.fill",
        colorHex: String = "#9333EA",
        createdDate: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdDate = createdDate
        self.sortOrder = sortOrder
        self.entries = []
        self.alarms = []
    }
}
