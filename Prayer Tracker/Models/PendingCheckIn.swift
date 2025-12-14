//
//  PendingCheckIn.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import Foundation

struct PendingCheckIn: Codable {
    let prayerID: String
    let timestamp: Date
    let activityID: String

    init(prayerID: String, timestamp: Date, activityID: String) {
        self.prayerID = prayerID
        self.timestamp = timestamp
        self.activityID = activityID
    }
}
