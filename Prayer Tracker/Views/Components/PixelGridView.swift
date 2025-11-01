//
//  PixelGridView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI

struct PixelGridView: View {
    let entries: [PrayerEntry]
    let color: Color
    let dayCount: Int
    let pixelSize: CGFloat
    let vSpacing: CGFloat
    let hSpacing: CGFloat
    let disableScroll: Bool = true

    private let calendar = Calendar.current

    // Group days by month, with current month in the middle
    private var monthsData: [(monthLabel: String, days: [(date: Date, count: Int)])] {
        let today = calendar.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        // Calculate how many months we need to show ~70 days
        // Aim for current month in the middle (2nd position)
        var months: [(String, [(Date, Int)])] = []

        // Start from 2 months ago to current month + partial next month
        for monthOffset in -1...1 {
            guard let monthStart = calendar.date(byAdding: .month, value: monthOffset, to: today),
                  let monthStartDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart)),
                  let range = calendar.range(of: .day, in: .month, for: monthStart) else {
                continue
            }

            var monthDays: [(Date, Int)] = []
            let monthLabel = dateFormatter.string(from: monthStart)

            for day in 1...range.count {
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthStartDay) else { continue }

                let count = entries.filter { entry in
                    calendar.isDate(entry.timestamp, inSameDayAs: date)
                }.count

                monthDays.append((date, count))
            }

            months.append((monthLabel, monthDays))
        }

        return months
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: hSpacing) {
                ForEach(Array(monthsData.enumerated()), id: \.offset) { monthIndex, month in
                    VStack(alignment: .leading, spacing: 4) {
                        // Month label
                        Text(month.monthLabel)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(height: 14)

                        // Grid for this month's days - show 4 weeks (28 days)
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(pixelSize), spacing: hSpacing), count: 7),
                            spacing: vSpacing
                        ) {
                            ForEach(Array(month.days.prefix(28).enumerated()), id: \.offset) { dayIndex, day in
                                PixelCell(
                                    count: day.count,
                                    color: color,
                                    size: pixelSize,
                                    isToday: calendar.isDateInToday(day.date)
                                )
                            }
                        }
                    }
                }
            }
        }
        .frame(height: (pixelSize * 4) + (vSpacing * 3) + 20)
        .scrollDisabled(disableScroll)
    }
}

struct PixelCell: View {
    let count: Int
    let color: Color
    let size: CGFloat
    let isToday: Bool

    private var fillColor: Color {
        if count == 0 {
            return color.opacity(0.15)
        }

        // Color intensity based on count (same as CalendarPixel)
        let intensity = min(Double(count) / 5.0, 1.0)
        return color.opacity(0.3 + (intensity * 0.7))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(fillColor)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(isToday ? color : Color.clear, lineWidth: 2.5)
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        // No entries
        PixelGridView(
            entries: [],
            color: .purple,
            dayCount: 70,
            pixelSize: 20,
            vSpacing: 3.5,
            hSpacing: 5
        )
        .frame(width: 350)

        // Some entries
        PixelGridView(
            entries: [
                PrayerEntry(timestamp: Date()),
                PrayerEntry(timestamp: Date().addingTimeInterval(-86400)),
                PrayerEntry(timestamp: Date().addingTimeInterval(-86400)),
                PrayerEntry(timestamp: Date().addingTimeInterval(-86400 * 2)),
            ],
            color: .blue,
            dayCount: 70,
            pixelSize: 20,
            vSpacing: 3.5,
            hSpacing: 5
        )
        .frame(width: 350)

        // Many entries
        PixelGridView(
            entries: Array(0..<50).flatMap { day in
                Array(0..<Int.random(in: 0...8)).map { _ in
                    PrayerEntry(timestamp: Date().addingTimeInterval(-86400 * Double(day)))
                }
            },
            color: .green,
            dayCount: 70,
            pixelSize: 20,
            vSpacing: 3.5,
            hSpacing: 5
        )
        .frame(width: 350)
    }
    .padding()
    .background(Color(white: 0.05))
}
