//
//  LiveActivityDebugView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 29.10.25.
//

import SwiftUI
import ActivityKit

struct LiveActivityDebugView: View {
    @State private var testActivityID: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Status Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Live Activity Status")
                                .font(.headline)
                                .foregroundStyle(.white)

                            StatusRow(
                                label: "Live Activities Enabled",
                                value: ActivityAuthorizationInfo().areActivitiesEnabled ? "✅ Yes" : "❌ No",
                                isGood: ActivityAuthorizationInfo().areActivitiesEnabled
                            )

                            StatusRow(
                                label: "Active Live Activities",
                                value: "\(Activity<PrayerActivityAttributes>.activities.count)",
                                isGood: true
                            )

                            if let activityID = testActivityID {
                                StatusRow(
                                    label: "Test Activity ID",
                                    value: String(activityID.prefix(8)),
                                    isGood: true
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Test Buttons
                        VStack(spacing: 12) {
                            Button {
                                startTestActivity()
                            } label: {
                                Label("Start Test Live Activity", systemImage: "play.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundStyle(.white)
                                    .cornerRadius(12)
                            }

                            if testActivityID != nil {
                                Button {
                                    updateTestActivity()
                                } label: {
                                    Label("Update to Active Phase", systemImage: "arrow.clockwise")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }

                                Button {
                                    completeTestActivity()
                                } label: {
                                    Label("Complete Test Activity", systemImage: "checkmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.purple)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }

                                Button {
                                    endTestActivity()
                                } label: {
                                    Label("End Test Activity", systemImage: "xmark.circle.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundStyle(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }

                        // Instructions
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("1. Tap 'Start Test Live Activity' to create a test activity")
                            Text("2. Check your Lock Screen and Dynamic Island")
                            Text("3. Use the update buttons to test phase transitions")
                            Text("4. Check-in button should appear when completed")
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Live Activity Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }

    private func startTestActivity() {
        print("🧪 Starting test Live Activity...")

        // Generate a test UUID for the prayer
        let testPrayerID = UUID().uuidString
        print("🧪 Test Prayer ID: \(testPrayerID)")

        let attributes = PrayerActivityAttributes(
            prayerID: testPrayerID,
            prayerTitle: "Test Prayer",
            prayerSubtitle: "This is a test",
            iconName: "hands.sparkles.fill",
            colorHex: "#9333EA",
            alarmTime: Date().addingTimeInterval(60), // 5 min from now
            durationMinutes: 1
        )

        let contentState = PrayerActivityAttributes.ContentState(
            phase: .warning,
            startTime: nil,
            remainingSeconds: 60,
            totalSeconds: 60,
            currentProgress: 0.0,
            lastUpdateTime: Date()
        )

        do {
            let activity = try Activity<PrayerActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil),
                pushType: nil
            )

            testActivityID = activity.id
            print("✅ Test activity started: \(activity.id)")
        } catch {
            print("❌ Failed to start test activity: \(error)")
        }
    }

    private func updateTestActivity() {
        guard let activityID = testActivityID else { return }

        Task {
            await LiveActivityManager.shared.transitionToActive(activityID: activityID)
        }
    }

    private func completeTestActivity() {
        guard let activity = Activity<PrayerActivityAttributes>.activities.first(where: { $0.id == testActivityID }) else {
            return
        }

        Task {
            let newState = PrayerActivityAttributes.ContentState(
                phase: .completed,
                startTime: Date(),
                remainingSeconds: 0,
                totalSeconds: activity.attributes.durationMinutes * 60,
                currentProgress: 1.0,
                lastUpdateTime: Date()
            )

            await activity.update(
                ActivityContent(state: newState, staleDate: nil)
            )
            print("✅ Test activity completed")
        }
    }

    private func endTestActivity() {
        guard let activityID = testActivityID else { return }

        Task {
            await LiveActivityManager.shared.endActivity(activityID: activityID)
            testActivityID = nil
        }
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    let isGood: Bool

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(isGood ? .green : .red)
        }
    }
}
