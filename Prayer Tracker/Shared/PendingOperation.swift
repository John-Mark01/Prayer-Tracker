//
//  PendingOperation.swift
//  Prayer Tracker
//
//  Protocol for operations from widgets/intents that need app processing
//

import Foundation

/// Type of pending operation (Live Activity operations only)
enum OperationType: String, Codable {
    case checkIn        // Live Activity check-in
    case startPrayer    // Live Activity start prayer
}

/// Protocol that all pending operations must conform to
/// Enables consistent queue-based communication between widgets/intents and the main app
protocol PendingOperation: Codable {
    /// When this operation was created
    var timestamp: Date { get }

    /// The type of operation
    var operationType: OperationType { get }
}
