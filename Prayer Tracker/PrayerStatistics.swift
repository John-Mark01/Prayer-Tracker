//
//  PrayerStatistics.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import Foundation

/// Business logic for calculating prayer statistics
struct PrayerStatistics {
    let entries: [PrayerEntry]
    let calendar: Calendar

    init(entries: [PrayerEntry], calendar: Calendar = .current) {
        self.entries = entries
        self.calendar = calendar
    }

    // MARK: - Today's Prayers

    func todayEntries() -> [PrayerEntry] {
        let today = calendar.startOfDay(for: Date())
        return entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }

    func todayCount() -> Int {
        todayEntries().count
    }

    // MARK: - Streak Calculation

    func currentStreak() -> Int {
        var streak = 0
        var checkDate = Date()

        while true {
            let dayStart = calendar.startOfDay(for: checkDate)
            let hasEntry = entries.contains { entry in
                calendar.isDate(entry.timestamp, inSameDayAs: dayStart)
            }

            if hasEntry {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    func longestStreak() -> Int {
        guard !entries.isEmpty else { return 0 }

        let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }
        let uniqueDays = Set(sortedEntries.map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDays = uniqueDays.sorted()

        var maxStreak = 0
        var currentStreakCount = 0
        var lastDate: Date?

        for day in sortedDays {
            if let last = lastDate, calendar.dateComponents([.day], from: last, to: day).day == 1 {
                currentStreakCount += 1
            } else {
                currentStreakCount = 1
            }
            maxStreak = max(maxStreak, currentStreakCount)
            lastDate = day
        }

        return maxStreak
    }

    // MARK: - Period Counts

    func thisWeekCount() -> Int {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return entries.filter { $0.timestamp >= weekStart }.count
    }

    func thisMonthCount() -> Int {
        guard let monthStart = calendar.dateInterval(of: .month, for: Date())?.start else { return 0 }
        return entries.filter { $0.timestamp >= monthStart }.count
    }

    // MARK: - Averages

    func weeklyAverage() -> Double {
        guard let firstEntry = entries.min(by: { $0.timestamp < $1.timestamp })?.timestamp else { return 0 }

        let weeks = max(1, calendar.dateComponents([.weekOfYear], from: firstEntry, to: Date()).weekOfYear ?? 1)
        return Double(entries.count) / Double(weeks)
    }

    // MARK: - Date-specific queries

    func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }
    }

    func entryCount(for date: Date) -> Int {
        entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: date)
        }.count
    }
}
