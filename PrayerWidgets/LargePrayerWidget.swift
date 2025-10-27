//
//  LargePrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct LargePrayerWidget: View {
    let entry: PrayerWidgetEntry

    private var calendar: Calendar {
        Calendar.current
    }

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: entry.entries)
    }

    // Get last 20 weeks (140 days) organized by week
    private var weekData: [[Date]] {
        let today = Date()
        var weeks: [[Date]] = []

        for weekOffset in 0..<20 {
            var week: [Date] = []
            for dayOffset in 0..<7 {
                let totalDaysAgo = weekOffset * 7 + dayOffset
                if let date = calendar.date(byAdding: .day, value: -totalDaysAgo, to: today) {
                    week.append(date)
                }
            }
            weeks.append(week.reversed())
        }

        return weeks.reversed()
    }

    private var weekdayLabels: [String] {
        ["M", "T", "W", "T", "F", "S", "S"]
    }

    var body: some View {
        ZStack {
            // Dark background
            Color(white: 0.08)

            VStack(spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.purple)

                            Text("Prayer")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Text("LAST 20 WEEKS")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(1)
                    }

                    Spacer()

                    // Streak counter
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(entry.currentStreak)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            Image(systemName: "flame.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.orange)
                        }

                        Text("WEEKS")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                // Calendar grid
                HStack(spacing: 0) {
                    // Weekday labels
                    VStack(spacing: 2) {
                        ForEach(weekdayLabels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                                .frame(width: 16, height: 10)
                        }
                    }
                    .padding(.trailing, 4)

                    // Week columns
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 2) {
                            ForEach(Array(weekData.enumerated()), id: \.offset) { weekIndex, week in
                                VStack(spacing: 2) {
                                    ForEach(week, id: \.self) { date in
                                        WeekPixel(
                                            hasEntry: stats.hasEntry(for: date),
                                            count: stats.entryCount(for: date),
                                            isToday: calendar.isDateInToday(date)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                // Check-in button
                Button(intent: CheckInIntent()) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))

                        Text("Check In")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
}

struct WeekPixel: View {
    let hasEntry: Bool
    let count: Int
    let isToday: Bool

    private var fillColor: Color {
        if !hasEntry {
            return Color.white.opacity(0.05)
        }

        // Color intensity based on count
        let intensity = min(Double(count) / 5.0, 1.0)
        return Color.purple.opacity(0.3 + (intensity * 0.7))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(fillColor)
            .frame(width: 10, height: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(isToday ? Color.purple : Color.clear, lineWidth: 1)
            )
    }
}

#Preview(as: .systemLarge) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 5, currentStreak: 118)
}
