//
//  PrayerDataManager.swift
//  Prayer Tracker
//
//  Shared data access layer for main app and widget extension
//

import Foundation
import SwiftData

/// Centralized manager for accessing Prayer Tracker's SwiftData container
/// Used by both the main app and widget extension to ensure consistent data access
final class PrayerDataManager {
    static let shared = PrayerDataManager()

    /// The shared ModelContainer used across the app and widgets
    let container: ModelContainer

    /// The schema defining all SwiftData models
    static let schema = Schema([
        Prayer.self,
        PrayerEntry.self,
        PrayerAlarm.self,
    ])

    private init() {
        do {
            // Check if App Group is configured
            if let appGroupURL = AppGroup.containerURL {
                // Use App Group container for shared access with widgets and Live Activities
                let storeURL = appGroupURL.appendingPathComponent("PrayerTracker.sqlite")
                let modelConfiguration = ModelConfiguration(url: storeURL)
                self.container = try ModelContainer(
                    for: Self.schema,
                    configurations: [modelConfiguration]
                )
                print("✅ PrayerDataManager: Using App Group storage at \(storeURL.path)")
            } else {
                // Use default persistent storage
                // This will store data in the app's documents directory
                print("⚠️ PrayerDataManager: App Groups not configured - using default storage (data won't be shared with widgets)")
                self.container = try ModelContainer(for: Self.schema)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    /// Create a new ModelContext for performing data operations
    /// - Returns: A new ModelContext tied to the shared container
    func newContext() -> ModelContext {
        return ModelContext(container)
    }
}
