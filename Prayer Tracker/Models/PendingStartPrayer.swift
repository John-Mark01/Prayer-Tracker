//
//  PendingStartPrayer.swift
//  Prayer Tracker
//
//  Created by Claude on 4.03.26.
//

import Foundation

/// Operation to start a prayer countdown from a Live Activity
struct PendingStartPrayer: PendingOperation {
    let activityID: String
    let timestamp: Date

    var operationType: OperationType {
        return .startPrayer
    }

    init(activityID: String, timestamp: Date = Date()) {
        self.activityID = activityID
        self.timestamp = timestamp
    }
}
