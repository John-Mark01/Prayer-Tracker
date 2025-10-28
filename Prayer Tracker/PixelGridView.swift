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

    private let calendar = Calendar.current

    private var pixelData: [(date: Date, count: Int)] {
        var data: [(Date, Int)] = []
        let today = calendar.startOfDay(for: Date())

        for i in (0..<dayCount).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let count = entries.filter { entry in
                calendar.isDate(entry.timestamp, inSameDayAs: date)
            }.count
            data.append((date, count))
        }

        return data
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: pixelSize), spacing: hSpacing)],
            spacing: vSpacing
        ) {
            ForEach(Array(pixelData.enumerated()), id: \.offset) { index, data in
                PixelCell(
                    count: data.count,
                    color: color,
                    size: pixelSize,
                    isToday: calendar.isDateInToday(data.date)
                )
            }
        }
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
            vSpacing: 8,
            hSpacing: 16
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
            vSpacing: 8,
            hSpacing: 16
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
            vSpacing: 8,
            hSpacing: 16
        )
        .frame(width: 350)
    }
    .padding()
    .background(Color(white: 0.05))
}
