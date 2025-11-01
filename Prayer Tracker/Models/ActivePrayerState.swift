//
//  ActivePrayerState.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 1.11.25.
//

import Foundation
import SwiftUI

/// Observable state for the active in-app prayer timer
@MainActor
@Observable class ActivePrayerState {
    // MARK: - Properties

    /// Whether a prayer session is currently active
    var isActive: Bool = false

    /// Whether prayer is in ready state (waiting to start)
    var isReady: Bool = false

    /// Prayer information
    var prayerID: String?
    var prayerTitle: String = ""
    var prayerSubtitle: String = ""
    var iconName: String = "hands.sparkles.fill"
    var colorHex: String = "#9333EA"

    /// Timer information
    var startTime: Date?
    var totalSeconds: Int = 0
    var remainingSeconds: Int = 0
    var currentProgress: Double = 0.0

    /// Completion state
    var isCompleted: Bool = false

    /// Associated Live Activity ID
    var activityID: String?

    /// Timer reference
    private var timer: Timer?

    // MARK: - Methods

    /// Start a new prayer session in ready state (from notification data)
    func startPrayer(from userInfo: [AnyHashable: Any]) {
        print("🎬 ActivePrayerState: Starting prayer session in ready state")

        // Extract data from notification
        guard let title = userInfo["alarmTitle"] as? String,
              let durationMinutes = userInfo["durationMinutes"] as? Int else {
            print("⚠️ Missing required data in userInfo")
            return
        }

        // Set prayer information
        prayerID = userInfo["prayerID"] as? String
        prayerTitle = title
        prayerSubtitle = userInfo["prayerSubtitle"] as? String ?? ""
        iconName = userInfo["iconName"] as? String ?? "hands.sparkles.fill"
        colorHex = userInfo["colorHex"] as? String ?? "#9333EA"

        // Set timer information (but don't start counting yet)
        startTime = nil  // No start time yet!
        totalSeconds = durationMinutes * 60
        remainingSeconds = totalSeconds
        currentProgress = 0.0
        isCompleted = false
        isReady = true
        isActive = true

        print("✅ Prayer session ready: \(prayerTitle) for \(durationMinutes) minutes")
        print("⏸️ Waiting for user to tap 'Start Prayer' button")

        // DON'T start the timer yet - wait for beginCountdown()
    }

    /// Begin the countdown timer (called when user taps "Start Prayer")
    func beginCountdown() {
        guard isReady else {
            print("⚠️ Can't begin countdown - not in ready state")
            return
        }

        print("▶️ Beginning prayer countdown")

        // Set the start time NOW
        startTime = Date()
        isReady = false

        // Start the update timer
        startTimer()

        print("✅ Prayer countdown started!")
    }

    /// Set the associated Live Activity ID
    func setActivityID(_ id: String) {
        activityID = id
        print("🆔 Activity ID set: \(id)")
    }

    /// Start the timer that updates progress every second
    private func startTimer() {
        // Cancel any existing timer
        timer?.invalidate()

        // Create new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateProgress()
            }
        }

        // Add to common run loop
        RunLoop.current.add(timer!, forMode: .common)

        print("⏱️ Progress update timer started")
    }

    /// Update progress based on elapsed time
    func updateProgress() {
        guard let startTime = startTime, isActive, !isCompleted else {
            return
        }

        let elapsed = Int(Date().timeIntervalSince(startTime))
        remainingSeconds = max(0, totalSeconds - elapsed)
        currentProgress = min(1.0, Double(elapsed) / Double(totalSeconds))

        // Check if completed
        if remainingSeconds <= 0 {
            complete()
        }
    }

    /// Mark prayer as completed
    func complete() {
        guard !isCompleted else { return }

        isCompleted = true
        remainingSeconds = 0
        currentProgress = 1.0

        // Stop the timer
        timer?.invalidate()
        timer = nil

        print("✅ Prayer session completed!")
    }

    /// Reset state after check-in
    func reset() {
        print("🔄 Resetting ActivePrayerState")

        // Stop timer
        timer?.invalidate()
        timer = nil

        // Reset all properties
        isActive = false
        isReady = false
        prayerID = nil
        prayerTitle = ""
        prayerSubtitle = ""
        iconName = "hands.sparkles.fill"
        colorHex = "#9333EA"
        startTime = nil
        totalSeconds = 0
        remainingSeconds = 0
        currentProgress = 0.0
        isCompleted = false
        activityID = nil
    }

    // MARK: - Computed Properties

    /// Formatted time string (MM:SS)
    var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// Prayer color as SwiftUI Color
    var color: Color {
        Color(hex: colorHex)
    }
}
