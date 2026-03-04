//
//  CheckInQueue.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//

import Foundation

@MainActor
class CheckInQueue {
    private static let queueKey = "pendingCheckIns"

    /// Add a check-in to the pending queue
    nonisolated static func enqueue(prayerID: String, activityID: String) {
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
    nonisolated static func getQueue() -> [PendingCheckIn] {
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
    nonisolated static func clearQueue() {
        guard let defaults = AppGroup.userDefaults else {
            return
        }

        defaults.removeObject(forKey: queueKey)
        defaults.synchronize()
        print("✅ Cleared check-in queue")
    }
}
