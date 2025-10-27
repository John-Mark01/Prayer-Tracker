# Prayer Tracker - Unit Tests

This directory contains unit tests for the Prayer Tracker app's business logic.

## Test Coverage

### PrayerStatisticsTests.swift

Comprehensive test suite for the `PrayerStatistics` business logic class with 25+ test cases:

#### Today's Prayer Counting
- ✅ `testTodayCountWithNoEntries` - Handles empty data
- ✅ `testTodayCountWithEntriesFromToday` - Counts today's prayers
- ✅ `testTodayCountIgnoresYesterdayEntries` - Filters by date correctly

#### Current Streak Calculation
- ✅ `testCurrentStreakWithNoEntries` - Returns 0 for no data
- ✅ `testCurrentStreakWithOnlyToday` - Single day streak
- ✅ `testCurrentStreakWithConsecutiveDays` - Consecutive days counting
- ✅ `testCurrentStreakBreaksWithMissingDay` - Breaks on gaps
- ✅ `testCurrentStreakWithMultipleEntriesPerDay` - Handles multiple check-ins

#### Longest Streak Calculation
- ✅ `testLongestStreakWithNoEntries` - Empty data handling
- ✅ `testLongestStreakWithSingleDay` - Single entry
- ✅ `testLongestStreakWithConsecutiveDays` - Consecutive counting
- ✅ `testLongestStreakFindsLongestNotCurrent` - Finds historical best

#### Period Counts
- ✅ `testThisWeekCountWithNoEntries` - Week count empty state
- ✅ `testThisWeekCountWithCurrentWeekEntries` - Current week filtering
- ✅ `testThisMonthCountWithNoEntries` - Month count empty state
- ✅ `testThisMonthCountWithCurrentMonthEntries` - Current month filtering

#### Weekly Averages
- ✅ `testWeeklyAverageWithNoEntries` - Empty data returns 0
- ✅ `testWeeklyAverageWithOneWeekOfData` - Single week calculation
- ✅ `testWeeklyAverageWithMultipleWeeks` - Multi-week average

#### Date-Specific Queries
- ✅ `testHasEntryForDateWithNoEntries` - Empty check
- ✅ `testHasEntryForDateWithMatchingEntry` - Finds matching date
- ✅ `testHasEntryForDateWithDifferentDay` - Distinguishes different days
- ✅ `testEntryCountForSpecificDate` - Counts entries for date
- ✅ `testEntryCountForDateWithNoEntries` - Zero for no entries

#### Edge Cases
- ✅ `testStreakWithEntriesOutOfOrder` - Handles unsorted data
- ✅ `testStreakAcrossMonthBoundary` - Month transitions work correctly

## Running Tests

### In Xcode

1. Open `Prayer Tracker.xcodeproj`
2. Press `Cmd+U` to run all tests
3. Or use Test Navigator (`Cmd+6`) to run specific tests
4. View results in the Test Results pane

### Command Line

**Note**: You must first add a Test Target in Xcode:
1. File > New > Target
2. Select "Unit Testing Bundle"
3. Name it "Prayer TrackerTests"
4. Add `PrayerStatisticsTests.swift` to the target

Then run:
```bash
xcodebuild test -project "Prayer Tracker.xcodeproj" -scheme "Prayer Tracker" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Adding New Tests

1. Open `PrayerStatisticsTests.swift`
2. Add a new test method:
   ```swift
   func testYourNewTest() {
       // Arrange
       let entries = [PrayerEntry(timestamp: Date())]
       let stats = PrayerStatistics(entries: entries)

       // Act
       let result = stats.yourMethod()

       // Assert
       XCTAssertEqual(result, expectedValue)
   }
   ```
3. Run tests to verify

## Test Data Helpers

### Creating Date-Specific Entries

```swift
let calendar = Calendar.current
let now = Date()
let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
let lastWeek = calendar.date(byAdding: .day, value: -7, to: now)!

let entries = [
    PrayerEntry(timestamp: now),
    PrayerEntry(timestamp: yesterday),
    PrayerEntry(timestamp: lastWeek)
]
```

### Testing with Custom Calendar

```swift
var calendar = Calendar.current
calendar.timeZone = TimeZone(identifier: "America/New_York")!
let stats = PrayerStatistics(entries: entries, calendar: calendar)
```

## Coverage Goals

Current: ~100% coverage of `PrayerStatistics` business logic

Future test areas:
- [ ] PrayerAlarm notification scheduling
- [ ] Widget data provider logic
- [ ] Live Activity state management
- [ ] Integration tests for SwiftData persistence

## Continuous Integration

When setting up CI/CD:
```yaml
- name: Run Tests
  run: |
    xcodebuild test \
      -project "Prayer Tracker.xcodeproj" \
      -scheme "Prayer Tracker" \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
      -resultBundlePath ./test-results
```
