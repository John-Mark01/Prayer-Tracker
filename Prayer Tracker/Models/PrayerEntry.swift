//
//  PrayerEntry.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import Foundation
import SwiftData

@Model
final class PrayerEntry {
    var timestamp: Date
    var title: String?
    var prayer: Prayer?

    init(timestamp: Date = Date(), title: String? = nil, prayer: Prayer? = nil) {
        self.timestamp = timestamp
        self.title = title
        self.prayer = prayer
    }
}
