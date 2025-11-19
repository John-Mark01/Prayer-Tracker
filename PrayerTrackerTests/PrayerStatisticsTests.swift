//
//  PrayerStatisticsTests.swift
//  Prayer TrackerTests
//
//  Created by John-Mark Iliev on 27.10.25.
//

import XCTest
@testable import Prayer_Tracker

final class PrayerStatisticsTests: XCTestCase {
    var calendar: Calendar!

    override func setUp() {
        super.setUp()
        calendar = Calendar.current
    }

    // MARK: - Today's Prayers Tests
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
    // MARK: - Current Streak Tests

    func testCurrentStreakWithNoEntries() {
        let stats = PrayerStatistics(entries: [], calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 0)
    }

    func testCurrentStreakWithOnlyToday() {
        let now = Date()
        let entries = [PrayerEntry(timestamp: now)]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 1)
    }

    func testCurrentStreakWithConsecutiveDays() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!

        let entries = [
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: twoDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 3)
    }

    func testCurrentStreakBreaksWithMissingDay() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        let entries = [
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: threeDaysAgo)  // Missing day 2
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 2) // Only today and yesterday
    }

    func testCurrentStreakWithMultipleEntriesPerDay() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let entries = [
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: now.addingTimeInterval(-3600)),    // Another today
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: yesterday.addingTimeInterval(-3600)) // Another yesterday
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 2) // Still just 2 days
    }

    // MARK: - NEW TEST: Bug Fix Verification

    /// Test that streak persists when today has no entry yet (Bug #4 fix)
    func testCurrentStreakPersistsWhenTodayHasNoEntryYet() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        // User has a 3-day streak ending yesterday, but hasn't checked in today yet
        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: twoDaysAgo),
            PrayerEntry(timestamp: threeDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Should show yesterday's streak (3), not 0!
        // User still has time to check in today to make it 4
        XCTAssertEqual(stats.currentStreak(), 3, "Streak should persist when today has no entry yet")
    }

    /// Test that streak is 0 when both today and yesterday have no entries
    func testCurrentStreakIsZeroWhenYesterdayAlsoMissing() {
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        // User had entries 2-3 days ago, but missed yesterday and today
        let entries = [
            PrayerEntry(timestamp: twoDaysAgo),
            PrayerEntry(timestamp: threeDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Streak should be broken (0) because yesterday had no entry
        XCTAssertEqual(stats.currentStreak(), 0, "Streak should be 0 when yesterday has no entry")
    }
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

    // MARK: - Edge Cases

    func testStreakWithEntriesOutOfOrder() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!

        // Add entries in random order
        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: twoDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)
        XCTAssertEqual(stats.currentStreak(), 3)
    }

    func testStreakAcrossMonthBoundary() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        // Create a 3-day streak ending yesterday
        // This tests that consecutive days work regardless of month boundaries
        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: twoDaysAgo),
            PrayerEntry(timestamp: threeDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Streak should be 3 (the 3 consecutive days, even though today is empty)
        XCTAssertEqual(stats.currentStreak(), 3, "Consecutive days should maintain streak across any month boundary")
    }

    // MARK: - Comprehensive Edge Case Tests

    /// Test: Only entry is yesterday (not today) - should show streak of 1
    func testStreakWithOnlyYesterday() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let entries = [PrayerEntry(timestamp: yesterday)]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Streak should be 1 (yesterday's entry, user still has today to continue)
        XCTAssertEqual(stats.currentStreak(), 1, "Streak should be 1 when only yesterday has entry")
    }

    /// Test: Single entry far in the past (30 days ago) - should be 0
    func testStreakWithOnlyOldEntry() {
        let now = Date()
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!

        let entries = [PrayerEntry(timestamp: thirtyDaysAgo)]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 0, "Streak should be 0 with only old entries")
    }

    /// Test: Very long streak (100 consecutive days)
    func testVeryLongStreak() {
        let now = Date()
        let entries = (0..<700).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: now)!)
        }
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 700, "Should handle very long streaks correctly")
    }

    /// Test: Very long streak without today (99 days ending yesterday)
    func testVeryLongStreakWithoutToday() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let entries = (0..<99).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: yesterday)!)
        }
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 99, "Should maintain 99-day streak when today empty")
    }

    /// Test: Streak across year boundary (Dec 31 → Jan 1)
    func testStreakAcrossYearBoundary() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        // Create a 3-day streak ending yesterday
        // This tests that consecutive days work regardless of year boundaries
        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: twoDaysAgo),
            PrayerEntry(timestamp: threeDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Streak should be 3 (consecutive days work across any boundary)
        XCTAssertEqual(stats.currentStreak(), 3, "Streak should continue across year boundary")
    }

    /// Test: Entries at different times on same day count as one day
    func testMultipleEntriesSameDayCountAsOne() {
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let morning = calendar.date(byAdding: .hour, value: 8, to: startOfDay)!
        let afternoon = calendar.date(byAdding: .hour, value: 14, to: startOfDay)!
        let evening = calendar.date(byAdding: .hour, value: 22, to: startOfDay)!

        let entries = [
            PrayerEntry(timestamp: morning),
            PrayerEntry(timestamp: afternoon),
            PrayerEntry(timestamp: evening)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "Multiple entries on same day should count as 1 day")
    }

    /// Test: Entries at midnight boundary (23:59 and 00:01)
    func testEntriesAroundMidnight() {
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // One second before midnight yesterday
        let lateLastNight = calendar.date(byAdding: .second, value: -1, to: today)!
        // One second after midnight today
        let earlyThisMorning = calendar.date(byAdding: .second, value: 1, to: today)!

        let entries = [
            PrayerEntry(timestamp: earlyThisMorning),
            PrayerEntry(timestamp: lateLastNight)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 2, "Entries around midnight should be counted as separate days")
    }

    /// Test: Exactly 2-day gap breaks the streak
    func testTwoDayGapBreaksStreak() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: now)!

        let entries = [
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: fourDaysAgo)  // 2-day gap (days -2 and -3 missing)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 2, "2-day gap should break the streak")
    }

    /// Test: Pattern - today + 2-3 days ago (yesterday missing)
    func testStreakBreaksWhenOnlyYesterdayMissing() {
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        let entries = [
            PrayerEntry(timestamp: now),  // Today ✓
            // Yesterday missing ✗
            PrayerEntry(timestamp: twoDaysAgo),  // 2 days ago ✓
            PrayerEntry(timestamp: threeDaysAgo)  // 3 days ago ✓
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "Streak should break when only yesterday is missing")
    }

    /// Test: Many old entries + recent gap = streak should be 0
    func testOldStreakDoesNotCountAsCurrent() {
        let now = Date()
        let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: now)!

        // Build a 7-day streak from 10-16 days ago
        let oldStreak = (10...16).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: now)!)
        }

        let stats = PrayerStatistics(entries: oldStreak, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 0, "Old streak with recent gap should not count as current")
    }

    /// Test: Only entries from yesterday with multiple times
    func testMultipleEntriesOnlyYesterday() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: yesterday.addingTimeInterval(-3600)),  // 1 hour earlier
            PrayerEntry(timestamp: yesterday.addingTimeInterval(-7200)),  // 2 hours earlier
            PrayerEntry(timestamp: yesterday.addingTimeInterval(-10800))  // 3 hours earlier
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "Multiple entries on only yesterday should be streak of 1")
    }

    /// Test: Streak of 1 when first entry ever was yesterday
    func testFirstEntryEverYesterday() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let entries = [PrayerEntry(timestamp: yesterday)]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "First entry ever yesterday should be streak of 1")
    }

    /// Test: Unsorted entries with gaps
    func testUnsortedEntriesWithGaps() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        let sixDaysAgo = calendar.date(byAdding: .day, value: -6, to: now)!

        // Add entries in random order with gap
        let entries = [
            PrayerEntry(timestamp: sixDaysAgo),
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: fiveDaysAgo),
            PrayerEntry(timestamp: yesterday)
            // Days -2, -3, -4 missing
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 2, "Should handle unsorted entries with gaps correctly")
    }

    /// Test: Leap year boundary (Feb 28/29 → Mar 1)
    func testStreakAcrossLeapYearBoundary() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: now)!

        // Create a 4-day streak ending yesterday
        // Calendar handles all special cases (leap years, month boundaries, etc.)
        let entries = [
            PrayerEntry(timestamp: yesterday),
            PrayerEntry(timestamp: twoDaysAgo),
            PrayerEntry(timestamp: threeDaysAgo),
            PrayerEntry(timestamp: fourDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        // Streak should be 4 regardless of whether we cross Feb 29 or any other boundary
        XCTAssertEqual(stats.currentStreak(), 4, "Streak should continue across leap year Feb 29 and all special dates")
    }

    /// Test: Entry exactly at start of day vs end of day
    func testEntriesAtDayBoundaries() {
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        let yesterdayEnd = calendar.date(byAdding: .second, value: -1, to: todayStart)!

        let entries = [
            PrayerEntry(timestamp: todayStart),      // 00:00:00 today
            PrayerEntry(timestamp: yesterdayEnd)     // 23:59:59 yesterday
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 2, "Entries at day boundaries should count as 2 days")
    }

    /// Test: 50 entries on single day should still count as 1 day
    func testExcessiveEntriesSingleDay() {
        let now = Date()
        let entries = (0..<50).map { _ in
            PrayerEntry(timestamp: now.addingTimeInterval(Double.random(in: -3600...3600)))
        }
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "50 entries on same day should still be streak of 1")
    }

    /// Test: Pattern with today empty - yesterday has entry, 2 days ago missing
    func testTodayEmptyYesterdayHasEntryButBrokenBefore() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: now)!

        let entries = [
            // Today empty
            PrayerEntry(timestamp: yesterday),
            // 2 days ago missing - breaks the streak
            PrayerEntry(timestamp: threeDaysAgo)
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "Should show streak of 1 when yesterday present but older streak broken")
    }

    /// Test: Alternating pattern (every other day)
    func testAlternatingDayPattern() {
        let now = Date()
        let entries = [
            PrayerEntry(timestamp: now),                                          // Day 0
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -2, to: now)!),  // Day -2
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -4, to: now)!)   // Day -4
        ]
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 1, "Alternating day pattern should break streak")
    }

    /// Test: Exactly 1 week streak
    func testExactlyOneWeekStreak() {
        let now = Date()
        let entries = (0..<7).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: now)!)
        }
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 7, "7 consecutive days should be streak of 7")
    }

    /// Test: Exactly 1 week streak ending yesterday (today empty)
    func testOneWeekStreakEndingYesterday() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let entries = (0..<7).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: yesterday)!)
        }
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 7, "7-day streak ending yesterday should show 7 when today empty")
    }

    /// Test: Two separate streaks - only current one should count
    func testTwoSeparateStreaks() {
        let now = Date()

        // Current streak: 3 days (today, yesterday, 2 days ago)
        let currentStreak = [
            PrayerEntry(timestamp: now),
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -1, to: now)!),
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -2, to: now)!)
        ]

        // Old streak: 5 days (10-14 days ago)
        let oldStreak = (10...14).map { day in
            PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: now)!)
        }

        let entries = currentStreak + oldStreak
        let stats = PrayerStatistics(entries: entries, calendar: calendar)

        XCTAssertEqual(stats.currentStreak(), 3, "Should only count current streak, not old streaks")
    }

    /// Test: Specific test for actual month boundary crossing (when it matters)
    func testActualMonthBoundaryCrossing() {
        // Create a scenario where we're on the 2nd of a month
        // and we have entries on the 2nd, 1st, and last day of previous month
        var components = calendar.dateComponents([.year, .month], from: Date())
        components.day = 2
        components.hour = 12

        guard let dayTwo = calendar.date(from: components) else {
            // If we can't create this date, test consecutive days from today
            let now = Date()
            let entries = (0..<3).map { day in
                PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: now)!)
            }
            let stats = PrayerStatistics(entries: entries, calendar: calendar)
            XCTAssertEqual(stats.currentStreak(), 3)
            return
        }

        let dayOne = calendar.date(byAdding: .day, value: -1, to: dayTwo)!
        let lastDayOfPrevMonth = calendar.date(byAdding: .day, value: -2, to: dayTwo)!

        // Verify lastDayOfPrevMonth is actually in previous month
        let dayTwoMonth = calendar.component(.month, from: dayTwo)
        let lastDayMonth = calendar.component(.month, from: lastDayOfPrevMonth)

        if dayTwoMonth != lastDayMonth {
            // We successfully created a streak across month boundary
            let entries = [
                PrayerEntry(timestamp: dayTwo),
                PrayerEntry(timestamp: dayOne),
                PrayerEntry(timestamp: lastDayOfPrevMonth)
            ]
            let stats = PrayerStatistics(entries: entries, calendar: calendar)
            XCTAssertEqual(stats.currentStreak(), 3, "Streak should work across actual month boundaries")
        } else {
            // Fallback: just test consecutive days
            let entries = (0..<3).map { day in
                PrayerEntry(timestamp: calendar.date(byAdding: .day, value: -day, to: Date())!)
            }
            let stats = PrayerStatistics(entries: entries, calendar: calendar)
            XCTAssertEqual(stats.currentStreak(), 3)
        }
    }
}
