//
//  WidgetPixelGridView.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 01.11.25.
//

import SwiftUI
import SwiftData

struct WidgetPixelGridView: View {
    let entries: [PrayerEntry]
    let color: Color
    let dayCount: Int
    let pixelSize: CGFloat
    let vSpacing: CGFloat
    let hSpacing: CGFloat

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height - 18  // Account for month labels

            let columns = max(1, Int((availableWidth + hSpacing) / (pixelSize + hSpacing)))
            let rows = max(1, Int((availableHeight + vSpacing) / (pixelSize + vSpacing)))

            let daysData = getDaysData(totalDays: min(dayCount, rows * columns))
            let monthLabels = getMonthLabels(daysData: daysData, columns: columns, rows: rows)

            VStack(alignment: .leading, spacing: 4) {
                // Month labels at the top
                HStack(spacing: 0) {
                    ForEach(Array(monthLabels.enumerated()), id: \.offset) { _, month in
                        let width = CGFloat(month.endCol - month.startCol ) * (pixelSize + hSpacing) - hSpacing

                        Text(month.label)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(width: width, alignment: .leading)

                        if month.endCol < columns - 1 {
                            Spacer()
                                .frame(width: hSpacing)
                        }
                    }
                }
//                .frame(height: 14)

                // Grid of days (vertical flow: top-to-bottom, then left-to-right)
                Grid(horizontalSpacing: hSpacing, verticalSpacing: vSpacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        GridRow {
                            ForEach(0..<columns, id: \.self) { col in
                                let index = col * rows + row  // Column-major order for vertical flow
                                if index < daysData.count {
                                    let day = daysData[index]
                                    WidgetPixelCell(
                                        count: day.count,
                                        color: color,
                                        size: pixelSize,
                                        isToday: calendar.isDate(day.date, inSameDayAs: Date())
                                    )
                                } else {
                                    Color.clear
                                        .frame(width: pixelSize, height: pixelSize)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Get continuous array of days starting from first day of first month
    private func getDaysData(totalDays: Int) -> [(date: Date, count: Int)] {
        let today = calendar.startOfDay(for: Date())
        var days: [(Date, Int)] = []

        // Get the first day of the current month
        let currentMonthComponents = calendar.dateComponents([.year, .month], from: today)
        guard let firstDayOfCurrentMonth = calendar.date(from: currentMonthComponents) else {
            return []
        }

        // Go back 1 month to start from previous month's day 1
        guard let firstDayOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfCurrentMonth) else {
            return []
        }

        // Start from day 1 of previous month and go forward
        var currentDate = firstDayOfPreviousMonth

        // Fill the entire grid with consecutive days
        while days.count < totalDays {
            let count = entries.filter { entry in
                let entryStart = calendar.startOfDay(for: entry.timestamp)
                return calendar.isDate(entryStart, inSameDayAs: currentDate)
            }.count

            days.append((currentDate, count))

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return days
    }

    // Calculate month labels and their column positions (for vertical flow)
    private func getMonthLabels(daysData: [(date: Date, count: Int)], columns: Int, rows: Int) -> [(label: String, startCol: Int, endCol: Int)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"

        var labels: [(String, Int, Int)] = []
        var currentMonth: String?
        var startCol = 0

        // Since we fill vertically, check the first day in each column
        for col in 0..<columns {
            let index = col * rows  // First item in this column
            guard index < daysData.count else { break }

            let day = daysData[index]
            let monthLabel = dateFormatter.string(from: day.date)

            if currentMonth != monthLabel {
                // Save previous month's range
                if let prevMonth = currentMonth {
                    labels.append((prevMonth, startCol, col - 1))
                }
                currentMonth = monthLabel
                startCol = col
            }
        }

        // Add the last month
        if let month = currentMonth {
            labels.append((month, startCol, columns - 1))
        }

        return labels
    }
}

struct WidgetPixelCell: View {
    let count: Int
    let color: Color
    let size: CGFloat
    let isToday: Bool

    private var fillColor: Color {
        if count == 0 {
            return color.opacity(0.15)
        }

        // Color intensity based on count
        let intensity = min(Double(count) / 5.0, 1.0)
        return color.opacity(0.3 + (intensity * 0.7))
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(fillColor)
            .frame(width: size, height: size)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(isToday ? color : Color.clear, lineWidth: 1.5)
            )
    }
}

#Preview("Widget Pixel Grid") {
//    // Generate sample prayer entries for last 60 days
    let sampleEntries = Array(0..<60).flatMap { day in
        Array(0..<Int.random(in: 1...5)).map { _ in
            PrayerEntry(timestamp: Date().addingTimeInterval(86400 * Double(day)))
        }
    }

    VStack(spacing: 20) {
        Text("Medium Widget Size (329x155)")
            .font(.caption)
            .foregroundStyle(.white)

        WidgetPixelGridView(
            entries: sampleEntries,
            color: .red,
            dayCount: 9999,
            pixelSize: 20,
            vSpacing: 3,
            hSpacing: 3
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray)
        )
        .frame(height: 155)

        Text("Different pixel size")
            .font(.caption)
            .foregroundStyle(.white)

        WidgetPixelGridView(
            entries: [],
            color: .blue,
            dayCount: 150,
            pixelSize: 15,
            vSpacing: 2,
            hSpacing: 2
        )
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
        .frame(height: 200)
    }
    .padding()
    .background(Color(white: 0.05))
}
