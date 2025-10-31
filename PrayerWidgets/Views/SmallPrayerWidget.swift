//
//  SmallPrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit

struct SmallPrayerWidget: View {
    let entry: PrayerWidgetEntry
    @State private var animationAmount: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.2, green: 0.1, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                Spacer()

                // Streak counter
                VStack(spacing: 4) {
                    Text("\(entry.currentStreak)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                            .symbolEffect(.bounce, value: entry.currentStreak)

                        Text("DAY STREAK")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .tracking(1)
                    }
                }

                Spacer()

                // Today's count
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.9))
                            .symbolEffect(.pulse, value: entry.todayCount)

                        Text("\(entry.todayCount)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }

                    Text("today")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 5, currentStreak: 12)
}
