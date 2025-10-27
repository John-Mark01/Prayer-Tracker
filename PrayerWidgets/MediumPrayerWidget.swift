//
//  MediumPrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct MediumPrayerWidget: View {
    let entry: PrayerWidgetEntry
    @State private var buttonPressed = false

    private var calendar: Calendar {
        Calendar.current
    }

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: entry.entries)
    }

    // Get current month name
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }

    // Get all days in current month
    private var currentMonthDays: [Date] {
        let today = Date()
        let components = calendar.dateComponents([.year, .month], from: today)
        guard let firstDayOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return []
        }

        // Get all days in the month
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)
        }
    }

    // Group days into weeks (rows of 7)
    private var weekRows: [[Date]] {
        var weeks: [[Date]] = []
        var currentWeek: [Date] = []

        for date in currentMonthDays {
            currentWeek.append(date)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }

        // Add remaining days as last week
        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }

        return weeks
    }

    var body: some View {
        ZStack {
            // Background
            Color(white: 0.95)

            VStack(spacing: 12) {
                // Top section
                HStack(spacing: 12) {
                    // Check button
                    Button(intent: CheckInIntent()) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 44, height: 44)
                                .scaleEffect(buttonPressed ? 0.9 : 1.0)

                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .symbolEffect(.bounce, value: buttonPressed)
                        }
                    }
                    .buttonStyle(.plain)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonPressed)

                    // Title and month
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prayer")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(currentMonthName)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Streak counter
                    VStack(alignment: .center, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(entry.currentStreak)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                                .contentTransition(.numericText())
                            
                            Text("🔥")
                                .font(.system(size: 16))
                        }

                        Text("days")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                }
                .padding(.horizontal, 16)

                // Calendar section
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(weekRows.enumerated()), id: \.offset) { weekIndex, week in
                        HStack(spacing: 6) {
                            ForEach(week, id: \.self) { date in
                                CalendarPixel(
                                    hasEntry: stats.hasEntry(for: date),
                                    count: stats.entryCount(for: date),
                                    isToday: calendar.isDateInToday(date)
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct CalendarPixel: View {
    let hasEntry: Bool
    let count: Int
    let isToday: Bool

    private var fillColor: Color {
        if !hasEntry {
            return Color.gray.opacity(0.15)
        }

        // Color intensity based on count
        let intensity = min(Double(count) / 5.0, 1.0)
        return Color.blue.opacity(0.3 + (intensity * 0.7))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .frame(width: 15, height: 15)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(isToday ? Color.blue : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isToday ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isToday)
    }
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 3, currentStreak: 18)
}
