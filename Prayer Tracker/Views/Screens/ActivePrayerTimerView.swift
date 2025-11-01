//
//  ActivePrayerTimerView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 1.11.25.
//

import SwiftUI
import SwiftData
import ConfettiSwiftUI

/// Full-screen modal showing active prayer timer with circular progress
struct ActivePrayerTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var prayerState: ActivePrayerState

    /// Callback when check-in is completed
    var onCheckIn: () -> Void

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    prayerState.color.opacity(0.1),
                    Color(UIColor.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                // Header: Prayer info
                VStack(spacing: 8) {
                    Image(systemName: prayerState.iconName)
                        .font(.system(size: 50))
                        .foregroundStyle(prayerState.color)

                    Text(prayerState.prayerTitle)
                        .font(.title.bold())

                    if !prayerState.prayerSubtitle.isEmpty {
                        Text(prayerState.prayerSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 40)

                Spacer()

                // Circular progress with timer
                ZStack {
                    CircularProgressView(
                        progress: prayerState.currentProgress,
                        lineWidth: 20,
                        color: prayerState.color,
                        size: 300
                    )

                    VStack(spacing: 8) {
                        if prayerState.isCompleted {
                            // Completion state
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(prayerState.color)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            // Active timer
                            Text(prayerState.formattedTime)
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .monospacedDigit()

                            Text("remaining")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: prayerState.isCompleted)

                Spacer()

                // Bottom section
                VStack(spacing: 16) {
                    if prayerState.isCompleted {
                        // Completion message and check-in button
                        Text("Prayer Complete!")
                            .font(.title2.bold())
                            .foregroundStyle(prayerState.color)

                        Button(action: handleCheckIn) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Check In")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(prayerState.color)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Active timer message
                        Text("Praying for \(prayerState.totalSeconds / 60) minutes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .interactiveDismissDisabled(!prayerState.isCompleted)
        .confettiCannon(trigger: $prayerState.isCompleted)
        .sensoryFeedback(.pathComplete, trigger: prayerState.isCompleted)
    }

    // MARK: - Actions

    private func handleCheckIn() {
        print("📝 Handling check-in from ActivePrayerTimerView")

        // Use the same queue-based approach as Live Activity
        guard let prayerID = prayerState.prayerID,
              let activityID = prayerState.activityID else {
            print("⚠️ Missing prayer ID or activity ID")
            return
        }

        // Queue the check-in
        CheckInQueue.enqueue(prayerID: prayerID, activityID: activityID)
        print("✅ Check-in queued successfully")

        // Process the check-in immediately (we're already in the app)
        Task { @MainActor in
            await processCheckIn(prayerID: prayerID, activityID: activityID)
        }

        // Call the completion callback
        onCheckIn()

        // Reset state and dismiss
        prayerState.reset()
        dismiss()
    }

    /// Process the check-in (same logic as Prayer_TrackerApp.processPendingCheckIns)
    @MainActor
    private func processCheckIn(prayerID: String, activityID: String) async {
        print("🔄 Processing check-in for prayer: \(prayerID)")

        // Find the prayer
        var prayer: Prayer? = nil
        if let uuid = UUID(uuidString: prayerID) {
            let descriptor = FetchDescriptor<Prayer>(
                predicate: #Predicate { $0.id == uuid }
            )
            prayer = try? modelContext.fetch(descriptor).first
        }

        // Create the prayer entry
        let entry = PrayerEntry(timestamp: Date(), prayer: prayer)
        modelContext.insert(entry)

        if let prayer = prayer {
            print("✅ Created check-in for: \(prayer.title)")
        } else {
            print("✅ Created generic check-in")
        }

        // Save the entry
        do {
            try modelContext.save()
            print("✅ Saved check-in to database")
        } catch {
            print("❌ Failed to save check-in: \(error)")
        }

        // End the Live Activity
        await LiveActivityManager.shared.endActivity(activityID: activityID)

        // Clear the queue
        CheckInQueue.clearQueue()
    }
}

#Preview {
    let state = ActivePrayerState()
    state.isActive = true
    state.prayerTitle = "Morning Prayer"
    state.prayerSubtitle = "Start your day"
    state.iconName = "sunrise.fill"
    state.colorHex = "#FF6B35"
    state.totalSeconds = 1200 // 20 minutes
    state.remainingSeconds = 720 // 12 minutes left
    state.currentProgress = 0.4

    return ActivePrayerTimerView(prayerState: state) {
        print("Check-in completed")
    }
}
