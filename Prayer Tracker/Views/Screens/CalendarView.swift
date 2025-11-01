//
//  CalendarView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [PrayerEntry]
    @State private var selectedMonth = Date()

    private var calendar: Calendar {
        Calendar.current
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offsetDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        days += range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }

        return days
    }

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: allEntries, calendar: calendar)
    }

    private func hasEntry(for date: Date) -> Bool {
        stats.hasEntry(for: date)
    }

    private func entryCount(for date: Date) -> Int {
        stats.entryCount(for: date)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Month Navigator
                        HStack {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            Text(monthYearString)
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            Spacer()

                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // Weekday Headers
                        HStack(spacing: 0) {
                            ForEach(weekdaySymbols, id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)

                        // Calendar Grid
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                                if let date = date {
                                    CalendarDayCell(
                                        date: date,
                                        hasEntry: hasEntry(for: date),
                                        count: entryCount(for: date),
                                        isToday: calendar.isDateInToday(date)
                                    )
                                } else {
                                    Color.clear
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Prayer Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols
    }

    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) else { return }
        withAnimation(.easeOut) {
            selectedMonth = newMonth
        }
    }

    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) else { return }
        withAnimation(.easeIn) {
            selectedMonth = newMonth
        }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let hasEntry: Bool
    let count: Int
    let isToday: Bool

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var backgroundColor: Color {
        if hasEntry {
            // Intensity based on count
            let intensity = min(Double(count) / 5.0, 1.0)
            return Color.purple.opacity(0.3 + (intensity * 0.7))
        }
        return Color.white.opacity(0.05)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)

            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.purple, lineWidth: 2)
            }

            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                if hasEntry {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
