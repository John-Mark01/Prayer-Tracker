////
////  PrayerStatisticsTests.swift
////  Prayer TrackerTests
////
////  Created by John-Mark Iliev on 27.10.25.
////
//
//import XCTest
//@testable import Prayer_Tracker
//
//final class PrayerStatisticsTests: XCTestCase {
//    var calendar: Calendar!
//
//    override func setUp() {
//        super.setUp()
//        calendar = Calendar.current
//    }
//
//    // MARK: - Today's Prayers Tests
//
//    func testTodayCountWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.todayCount(), 0)
//    }
//
//    func testTodayCountWithEntriesFromToday() {
//        let now = Date()
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: now.addingTimeInterval(-3600)), // 1 hour ago
//            PrayerEntry(timestamp: now.addingTimeInterval(-7200))  // 2 hours ago
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.todayCount(), 3)
//    }
//
//    func testTodayCountIgnoresYesterdayEntries() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: yesterday)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.todayCount(), 1)
//    }
//
//    // MARK: - Current Streak Tests
//
//    func testCurrentStreakWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 0)
//    }
//
//    func testCurrentStreakWithOnlyToday() {
//        let now = Date()
//        let entries = [PrayerEntry(timestamp: now)]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 1)
//    }
//
//    func testCurrentStreakWithConsecutiveDays() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: yesterday),
//            PrayerEntry(timestamp: twoDaysAgo)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 3)
//    }
//
//    func testCurrentStreakBreaksWithMissingDay() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: yesterday),
//            PrayerEntry(timestamp: threeDaysAgo)  // Missing day 2
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 2) // Only today and yesterday
//    }
//
//    func testCurrentStreakWithMultipleEntriesPerDay() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: now.addingTimeInterval(-3600)),    // Another today
//            PrayerEntry(timestamp: yesterday),
//            PrayerEntry(timestamp: yesterday.addingTimeInterval(-3600)) // Another yesterday
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 2) // Still just 2 days
//    }
//
//    // MARK: - Longest Streak Tests
//
//    func testLongestStreakWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.longestStreak(), 0)
//    }
//
//    func testLongestStreakWithSingleDay() {
//        let entries = [PrayerEntry(timestamp: Date())]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.longestStreak(), 1)
//    }
//
//    func testLongestStreakWithConsecutiveDays() {
//        let baseDate = Date()
//        let entries = (0..<7).map { day in
//            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: baseDate)!)
//        }
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.longestStreak(), 7)
//    }
//
//    func testLongestStreakFindsLongestNotCurrent() {
//        let now = Date()
//        // Current streak: 2 days
//        let today = now
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//
//        // Longer streak in the past: 4 days
//        let day10 = calendar.date(byAdding: .day, value: -10, to: now)!
//        let day11 = calendar.date(byAdding: .day, value: -11, to: now)!
//        let day12 = calendar.date(byAdding: .day, value: -12, to: now)!
//        let day13 = calendar.date(byAdding: .day, value: -13, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: today),
//            PrayerEntry(timestamp: yesterday),
//            PrayerEntry(timestamp: day10),
//            PrayerEntry(timestamp: day11),
//            PrayerEntry(timestamp: day12),
//            PrayerEntry(timestamp: day13)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.longestStreak(), 4)
//    }
//
//    // MARK: - Period Count Tests
//
//    func testThisWeekCountWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.thisWeekCount(), 0)
//    }
//
//    func testThisWeekCountWithCurrentWeekEntries() {
//        let now = Date()
//        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
//        let lastWeek = calendar.date(byAdding: .day, value: -8, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: twoDaysAgo),
//            PrayerEntry(timestamp: lastWeek)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertGreaterThanOrEqual(stats.thisWeekCount(), 2)
//    }
//
//    func testThisMonthCountWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.thisMonthCount(), 0)
//    }
//
//    func testThisMonthCountWithCurrentMonthEntries() {
//        let now = Date()
//        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now)!
//        let lastMonth = calendar.date(byAdding: .month, value: -1, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: tenDaysAgo),
//            PrayerEntry(timestamp: lastMonth)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertGreaterThanOrEqual(stats.thisMonthCount(), 2)
//    }
//
//    // MARK: - Weekly Average Tests
//
//    func testWeeklyAverageWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertEqual(stats.weeklyAverage(), 0.0, accuracy: 0.01)
//    }
//
//    func testWeeklyAverageWithOneWeekOfData() {
//        let now = Date()
//        let entries = (0..<7).map { _ in
//            PrayerEntry(timestamp: now)
//        }
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.weeklyAverage(), 7.0, accuracy: 0.1)
//    }
//
//    func testWeeklyAverageWithMultipleWeeks() {
//        let now = Date()
//        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now)!
//
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: twoWeeksAgo),
//            PrayerEntry(timestamp: twoWeeksAgo)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        // 4 entries over ~2 weeks = ~2 per week
//        XCTAssertLessThanOrEqual(stats.weeklyAverage(), 2.5)
//    }
//
//    // MARK: - Date-specific Query Tests
//
//    func testHasEntryForDateWithNoEntries() {
//        let stats = PrayerStatistics(entries: [], calendar: calendar)
//        XCTAssertFalse(stats.hasEntry(for: Date()))
//    }
//
//    func testHasEntryForDateWithMatchingEntry() {
//        let now = Date()
//        let entries = [PrayerEntry(timestamp: now)]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertTrue(stats.hasEntry(for: now))
//    }
//
//    func testHasEntryForDateWithDifferentDay() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let entries = [PrayerEntry(timestamp: yesterday)]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertFalse(stats.hasEntry(for: now))
//    }
//
//    func testEntryCountForSpecificDate() {
//        let now = Date()
//        let entries = [
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: now.addingTimeInterval(-3600)),
//            PrayerEntry(timestamp: now.addingTimeInterval(-7200))
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.entryCount(for: now), 3)
//    }
//
//    func testEntryCountForDateWithNoEntries() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let entries = [PrayerEntry(timestamp: yesterday)]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.entryCount(for: now), 0)
//    }
//
//    // MARK: - Edge Cases
//
//    func testStreakWithEntriesOutOfOrder() {
//        let now = Date()
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
//        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
//
//        // Add entries in random order
//        let entries = [
//            PrayerEntry(timestamp: yesterday),
//            PrayerEntry(timestamp: now),
//            PrayerEntry(timestamp: twoDaysAgo)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 3)
//    }
//
//    func testStreakAcrossMonthBoundary() {
//        let calendar = Calendar.current
//        let now = Date()
//
//        // Get first day of current month
//        let components = calendar.dateComponents([.year, .month], from: now)
//        guard let firstOfMonth = calendar.date(from: components) else {
//            XCTFail("Could not create first of month")
//            return
//        }
//
//        let lastDayOfPreviousMonth = calendar.date(byAdding: .day, value: -1, to: firstOfMonth)!
//        let secondDayOfPreviousMonth = calendar.date(byAdding: .day, value: -2, to: firstOfMonth)!
//
//        let entries = [
//            PrayerEntry(timestamp: firstOfMonth),
//            PrayerEntry(timestamp: lastDayOfPreviousMonth),
//            PrayerEntry(timestamp: secondDayOfPreviousMonth)
//        ]
//        let stats = PrayerStatistics(entries: entries, calendar: calendar)
//        XCTAssertEqual(stats.currentStreak(), 3)
//    }
//}
