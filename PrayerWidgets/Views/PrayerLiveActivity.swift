//
//  PrayerLiveActivity.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 29.10.25.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct PrayerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerActivityAttributes.self) { context in
            // Lock screen view
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.attributes.iconName)
                            .font(.title2)
                            .foregroundStyle(Color(hex: context.attributes.colorHex))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.prayerTitle)
                                .font(.headline)
                            Text(context.attributes.prayerSubtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.phase == .completed {
                        // Show check-in button when completed
                        Button(intent: CheckInPrayerIntent(
                            prayerID: context.attributes.prayerID,
                            activityID: context.activityID
                        )) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Show time info
                        VStack(alignment: .trailing, spacing: 2) {
                            if context.state.phase == .active {
                                // Display remaining time from state
                                Text(formatTime(context.state.remainingSeconds))
                                    .font(.title2.bold())
                                    .monospacedDigit()
                                    .multilineTextAlignment(.trailing)
                                Text("remaining")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(context.attributes.alarmTime, style: .time)
                                    .font(.title3)
                            }
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.phase == .warning {
                        Text("Prayer starts soon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if context.state.phase == .completed {
                        Text("Prayer completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                // Compact leading view - prayer icon
                Image(systemName: context.attributes.iconName)
                    .font(.system(size: 14))
            } compactTrailing: {
                Group {
                    // Compact trailing view - keep it minimal
                    if context.state.phase == .active {
                        // Show remaining time from state
                        Text(formatTime(context.state.remainingSeconds))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .monospacedDigit()
                    } else if context.state.phase == .warning {
                        // Warning phase - show just the time
                        Text(context.attributes.alarmTime, style: .time)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    } else {
                        // Completed phase
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.green)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: 40)
            } minimal: {
                // Minimal view - prayer icon
                Image(systemName: context.attributes.iconName)
                    .font(.system(size: 14))
            }
        }
    }
}

/// Lock screen Live Activity view
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PrayerActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Header: Title and subtitle
            HStack {
                Image(systemName: context.attributes.iconName)
                    .font(.title2)
                    .foregroundStyle(Color(hex: context.attributes.colorHex))

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.attributes.prayerTitle)
                        .font(.headline)
                    Text(context.attributes.prayerSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Right side info based on phase
                if context.state.phase == .completed {
                    Button(intent: CheckInPrayerIntent(
                        prayerID: context.attributes.prayerID,
                        activityID: context.activityID
                    )) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Check In")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(hex: context.attributes.colorHex))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else if context.state.phase == .active {
                    // Display time from state
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formatTime(context.state.remainingSeconds))
                            .font(.title3.bold())
                            .monospacedDigit()
                        Text("remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Starts at")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(context.attributes.alarmTime, style: .time)
                            .font(.subheadline.bold())
                    }
                }
            }

            // Progress bar (only during active phase)
            if context.state.phase == .active {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        // Progress - directly from state
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: context.attributes.colorHex))
                            .frame(
                                width: geometry.size.width * context.state.currentProgress,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                // Time remaining text
                HStack {
                    Text("Prayer time")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Display formatted time from state
                    Text(formatTime(context.state.remainingSeconds))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
            } else if context.state.phase == .warning {
                Text("Prayer will begin at \(context.attributes.alarmTime.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .activityBackgroundTint(Color(hex: context.attributes.colorHex).opacity(0.1))
        .activitySystemActionForegroundColor(Color(hex: context.attributes.colorHex))
    }
}

// MARK: - Helper Functions

/// Format seconds as MM:SS
private func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
