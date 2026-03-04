//
//  CheckInQueue.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 14.12.25.
//  Refactored to generic OperationQueue on 4.03.26
//

import Foundation

/// Generic queue manager for pending operations from widgets/intents
/// Works with any type conforming to PendingOperation protocol
class OperationQueue {

    /// Queue keys for different operation types (Live Activity operations only)
    enum QueueKey: String {
        case checkIns = "pendingCheckIns"
        case startPrayers = "pendingStartPrayers"
    }

    /// Add an operation to the pending queue
    static func enqueue<T: PendingOperation>(_ operation: T, key: QueueKey) {
        print("📥 OperationQueue.enqueue() called for \(key.rawValue)")

        guard let defaults = AppGroup.userDefaults else {
            print("❌ Failed to access App Group UserDefaults")
            print("   Identifier: \(AppGroup.identifier)")
            return
        }

        print("✅ App Group UserDefaults accessed")

        var queue = getQueue(T.self, key: key)
        print("📋 Current queue size: \(queue.count)")

        queue.append(operation)
        print("📋 New queue size: \(queue.count)")

        if let encoded = try? JSONEncoder().encode(queue) {
            defaults.set(encoded, forKey: key.rawValue)
            defaults.synchronize()
            print("✅✅✅ Operation successfully enqueued and synchronized")
        } else {
            print("❌ Failed to encode operation")
        }
    }

    /// Get all pending operations of a specific type
    static func getQueue<T: PendingOperation>(_ type: T.Type, key: QueueKey) -> [T] {
        guard let defaults = AppGroup.userDefaults else {
            return []
        }

        guard let data = defaults.data(forKey: key.rawValue),
              let queue = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }

        return queue
    }

    /// Clear all pending operations for a specific queue
    static func clearQueue(key: QueueKey) {
        guard let defaults = AppGroup.userDefaults else {
            return
        }

        defaults.removeObject(forKey: key.rawValue)
        defaults.synchronize()
        print("✅ Cleared \(key.rawValue) queue")
    }
}

// MARK: - Legacy Support

/// Legacy wrapper for backwards compatibility
/// Use OperationQueue directly for new code
class CheckInQueue {
    /// Add a check-in to the pending queue (legacy method)
    static func enqueue(prayerID: String, activityID: String) {
        let operation = PendingCheckIn(prayerID: prayerID, activityID: activityID)
        OperationQueue.enqueue(operation, key: .checkIns)
    }

    /// Get all pending check-ins (legacy method)
    static func getQueue() -> [PendingCheckIn] {
        return OperationQueue.getQueue(PendingCheckIn.self, key: .checkIns)
    }

    /// Clear all pending check-ins (legacy method)
    static func clearQueue() {
        OperationQueue.clearQueue(key: .checkIns)
    }
}
