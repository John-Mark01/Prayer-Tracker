//
//  MediumPrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit

struct MediumPrayerWidget: View {
    let entry: PrayerWidgetEntry

    private var calendar: Calendar {
        Calendar.current
    }

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: entry.entries)
    }

    // Get last 35 days (5 weeks) for monthly view
    private var calendarDays: [Date] {
        let today = Date()
        return (0..<35).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: today)
        }.reversed()
    }

    var body: some View {
        ZStack {
            // Background
            Color(white: 0.95)

            HStack(spacing: 12) {
                // Left side: Title and streak
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Prayer")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        HStack(spacing: 4) {
                            Text("\(entry.currentStreak)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.blue)

                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.blue)
                        }
                    }

                    Spacer()

                    // Check button
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 48, height: 48)

                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.leading, 16)
                .padding(.vertical, 12)

                // Right side: Calendar grid
                VStack(spacing: 4) {
                    // 5 rows x 7 columns
                    ForEach(0..<5, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(0..<7, id: \.self) { col in
                                let index = row * 7 + col
                                if index < calendarDays.count {
                                    let day = calendarDays[index]
                                    CalendarPixel(
                                        hasEntry: stats.hasEntry(for: day),
                                        count: stats.entryCount(for: day),
                                        isToday: calendar.isDateInToday(day)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.trailing, 16)
                .padding(.vertical, 12)
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
        RoundedRectangle(cornerRadius: 3)
            .fill(fillColor)
            .frame(width: 12, height: 12)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(isToday ? Color.blue : Color.clear, lineWidth: 1.5)
            )
    }
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 3, currentStreak: 18)
}
