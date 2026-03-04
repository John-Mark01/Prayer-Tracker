//
//  PendingCheckIn.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import Foundation

/// Operation to check in a prayer from a Live Activity
struct PendingCheckIn: PendingOperation {
    let prayerID: String
    let timestamp: Date
    let activityID: String

    var operationType: OperationType {
        return .checkIn
    }

    init(prayerID: String, timestamp: Date = Date(), activityID: String) {
        self.prayerID = prayerID
        self.timestamp = timestamp
        self.activityID = activityID
    }
}
