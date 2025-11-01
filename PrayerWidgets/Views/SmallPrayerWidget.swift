//
//  SmallPrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct SmallPrayerWidget: View {
    let entry: PrayerWidgetEntry

    private var calendar: Calendar {
        Calendar.current
    }

    private var color: Color {
        if let prayer = entry.prayer {
            return Color(hex: prayer.colorHex)
        }
        return .purple
    }

    // Get current week starting from Monday
    private var weekDays: [(date: Date, hasEntry: Bool, dayLetter: String, isToday: Bool)] {
        let today = calendar.startOfDay(for: Date())
        let weekdayLetters = ["M", "T", "W", "T", "F", "S", "S"]

        // Get the weekday of today (1 = Sunday, 2 = Monday, etc.)
        let todayWeekday = calendar.component(.weekday, from: today)

        // Calculate days since Monday (treating Monday as start of week)
        // If today is Sunday (1), days since Monday is 6
        // If today is Monday (2), days since Monday is 0
        let daysSinceMonday = todayWeekday == 1 ? 6 : (todayWeekday - 2)

        // Get Monday of this week
        guard let monday = calendar.date(byAdding: .day, value: -daysSinceMonday, to: today) else {
            return []
        }

        // Generate 7 days starting from Monday
        return (0..<7).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else {
                return (Date(), false, "M", false)
            }

            let dateStart = calendar.startOfDay(for: date)
            let hasEntry = entry.entries.contains { entry in
                let entryStart = calendar.startOfDay(for: entry.timestamp)
                return calendar.isDate(entryStart, inSameDayAs: dateStart)
            }

            let isToday = calendar.isDate(dateStart, inSameDayAs: today)

            return (dateStart, hasEntry, weekdayLetters[offset], isToday)
        }
    }

    // Get current streak in days
    private var dayStreak: Int {
        return entry.currentStreak
    }

    var body: some View {
        if let prayer = entry.prayer {
            VStack(alignment: .leading, spacing: 0) {
                    // Top section with streak and check button
                    HStack(alignment: .top) {
                        // Streak counter
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                Text("\(dayStreak)")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .contentTransition(.numericText())

                                Text("🔥")
                                    .font(.system(size: 18))
                            }

                            Text("DAYS")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                                .tracking(0.5)
                        }

                        Spacer()

                        // Check button
                        Button(intent: {
                            var intent = CheckInIntent()
                            intent.prayerId = entry.prayer?.id.uuidString
                            return intent
                        }()) {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 44, height: 44)

                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    Spacer()

                    // Prayer title
                    Text(prayer.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .padding(.horizontal, 16)

                    Spacer()

                    // Week circles and fraction
                    HStack(alignment: .bottom, spacing: 0) {
                        // Week day circles
                        HStack(spacing: 4) {
                            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                                VStack(spacing: 3) {
                                    ZStack {
                                        Circle()
                                            .fill(day.hasEntry ? color : Color.white.opacity(0.15))
                                            .frame(width: 14, height: 14)

                                        // Today indicator - ring around the circle
                                        if day.isToday {
                                            Circle()
                                                .strokeBorder(Color.white, lineWidth: 1.5)
                                                .frame(width: 17, height: 17)
                                        }
                                    }

                                    Text(day.dayLetter)
                                        .font(.system(size: 8, weight: .medium, design: .rounded))
                                        .foregroundStyle(day.isToday ? .white.opacity(0.9) : .white.opacity(0.4))
                                }
                            }
                        }

                        Spacer()

                        // Fraction (this week's count / 7)
                        Text("\(min(entry.todayCount, 7))/4")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
//                    .padding(.bottom, 16)
                }
        } else {
            // Empty state when no prayer is selected
            VStack(spacing: 8) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.3))

                Text("Select Prayer")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(
        date: Date(),
        prayer: WidgetPrayerEntity(
            id: UUID(),
            title: "Read",
            subtitle: "Daily scripture reading",
            iconName: "book.fill",
            colorHex: "#34D399"
        ),
        entries: [
            PrayerEntry(timestamp: Date()),
            PrayerEntry(timestamp: Date().addingTimeInterval(-86400)),
            PrayerEntry(timestamp: Date().addingTimeInterval(-86400 * 2)),
            PrayerEntry(timestamp: Date().addingTimeInterval(-86400 * 3))
        ],
        todayCount: 4,
        currentStreak: 17
    )
}
