//
//  AppGroup.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import Foundation

enum AppGroup {
    static let identifier = "group.com.johnmark.prayertracker"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}

// MARK: - Pending Check-In Model

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

// MARK: - Check-In Queue Manager

class CheckInQueue {
    private static let queueKey = "pendingCheckIns"

    /// Add a check-in to the pending queue
    static func enqueue(prayerID: String, activityID: String) {
        print("📥 CheckInQueue.enqueue() called")
        print("   Prayer ID: \(prayerID)")
        print("   Activity ID: \(activityID)")

        guard let defaults = AppGroup.userDefaults else {
            print("❌ Failed to access App Group UserDefaults")
            print("   Identifier: \(AppGroup.identifier)")
            return
        }

        print("✅ App Group UserDefaults accessed")

        let checkIn = PendingCheckIn(
            prayerID: prayerID,
            timestamp: Date(),
            activityID: activityID
        )

        var queue = getQueue()
        print("📋 Current queue size: \(queue.count)")

        queue.append(checkIn)
        print("📋 New queue size: \(queue.count)")

        if let encoded = try? JSONEncoder().encode(queue) {
            defaults.set(encoded, forKey: queueKey)
            defaults.synchronize()
            print("✅✅✅ Check-in successfully enqueued and synchronized")
        } else {
            print("❌ Failed to encode check-in")
        }
    }

    /// Get all pending check-ins
    static func getQueue() -> [PendingCheckIn] {
        guard let defaults = AppGroup.userDefaults else {
            return []
        }

        guard let data = defaults.data(forKey: queueKey),
              let queue = try? JSONDecoder().decode([PendingCheckIn].self, from: data) else {
            return []
        }

        return queue
    }

    /// Clear all pending check-ins
    static func clearQueue() {
        guard let defaults = AppGroup.userDefaults else {
            return
        }

        defaults.removeObject(forKey: queueKey)
        defaults.synchronize()
        print("✅ Cleared check-in queue")
    }
}
