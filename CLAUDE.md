# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Prayer Tracker is a SwiftUI-based iOS habit tracking app specifically designed for prayer. The app allows users to check in multiple times per day, track their prayer history with a visual calendar, view statistics and streaks, and set prayer alarms with Live Activity countdown timers.

**Bundle Identifier**: `johnmark.Prayer-Tracker`
**Development Team**: S6ZFW3NA3K
**Target iOS**: 26.0+
**Xcode Version**: 26.0.1

## Building and Running

Build for simulator:
```bash
xcodebuild -project "Prayer Tracker.xcodeproj" -scheme "Prayer Tracker" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Clean build:
```bash
xcodebuild clean -project "Prayer Tracker.xcodeproj" -scheme "Prayer Tracker"
```

Run tests:
```bash
# Note: Test target needs to be added in Xcode first
xcodebuild test -project "Prayer Tracker.xcodeproj" -scheme "Prayer Tracker" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Architecture

### Business Logic Layer

**PrayerStatistics** (PrayerStatistics.swift): Testable business logic for calculations
- All prayer-related calculations are centralized in this struct
- Takes an array of `PrayerEntry` and provides computed statistics
- Methods include: `todayCount()`, `currentStreak()`, `longestStreak()`, `thisWeekCount()`, `thisMonthCount()`, `weeklyAverage()`
- Comprehensive unit test coverage in `PrayerStatisticsTests.swift`

### Data Layer (SwiftData)

The app uses SwiftData for persistence with two main models:

**PrayerEntry** (PrayerEntry.swift:11-18)
- Tracks individual prayer check-ins
- Properties: `timestamp: Date`, `title: String?`
- Allows multiple entries per day for frequency tracking

**PrayerAlarm** (PrayerAlarm.swift:11-31)
- Stores scheduled prayer reminders
- Properties: `title`, `hour`, `minute`, `durationMinutes`, `isEnabled`, `notificationIdentifier`
- Computed property `timeString` for display formatting

### App Groups Configuration

**App Group ID**: `group.johnmark.PrayerTracker` (AppGroup.swift:12)

The app is configured to use App Groups for data sharing between:
- Main app
- Widgets (when implemented)
- Live Activities (when implemented)

**Storage Behavior** (Prayer_TrackerApp.swift:19-35):
- **With App Groups enabled**: Data stored in shared container at `PrayerTracker.sqlite`
- **Without App Groups** (default): Data stored in app's Documents directory using SwiftData defaults

Both modes provide persistent storage. The app will automatically use App Groups when available.

**IMPORTANT - Enabling App Groups** (required for widgets):
1. Select the Prayer Tracker target in Xcode
2. Go to Signing & Capabilities
3. Add App Groups capability
4. Enable `group.johnmark.PrayerTracker`

**Note**: A print statement warns when App Groups isn't configured (line 29), but the app works fine with default persistent storage.

### View Architecture

**ContentView.swift**: TabView-based navigation with 4 tabs
- Today
- Calendar
- Stats
- Alarms

**TodayView.swift**: Home screen with check-in functionality
- Displays current streak counter
- Shows today's prayer count
- Large check-in button with haptic feedback
- Purple/blue gradient design
- Uses `@Query` to fetch all entries and filter for today

**CalendarView.swift**: Monthly calendar with pixel-grid visualization
- Month navigation (prev/next buttons)
- 7-column grid layout for days
- Color intensity based on prayer frequency (1-5+ prayers)
- Today indicator with purple border
- Each cell shows day number and prayer count

**StatisticsView.swift**: Comprehensive stats dashboard
- Current Streak: Consecutive days with prayers
- Longest Streak: All-time best streak
- Total Prayers: Lifetime count
- This Week/Month: Recent activity
- Weekly Average: Calculated from first entry date

**AlarmsView.swift**: Prayer alarm management
- List of scheduled alarms with time, title, duration
- Toggle switches to enable/disable
- Add new alarm sheet with time picker and duration selector
- Placeholder TODOs for notification scheduling

### Shared Components

**StatCard** (StatisticsView.swift:107-141): Reusable stat card component with icon, value, subtitle, and title

**CalendarDayCell** (CalendarView.swift:121-163): Calendar grid cell with:
- Day number display
- Prayer count badge
- Color intensity based on frequency
- Today border indicator

### Design System

**Colors**:
- Background: Dark (Color(white: 0.05))
- Primary accent: Purple
- Secondary: Blue, green, orange, yellow for different stats
- Text: White with varying opacity (0.5-1.0)

**Typography**:
- System rounded font design throughout
- Bold weights for numbers and headings
- Size hierarchy: 72pt (streak), 48pt (stats), 36pt (alarms), 22pt (buttons)

**Layout**:
- Dark background throughout
- Cards with `Color.white.opacity(0.08-0.1)` backgrounds
- 16-20px corner radius on cards
- Consistent padding (16-32px)

## What's Implemented

✅ Core SwiftData models
✅ Business logic layer with `PrayerStatistics` helper
✅ Comprehensive unit tests (25+ test cases)
✅ App Groups configuration (code-side)
✅ Complete main app UI (4 tabs)
✅ Prayer check-in functionality
✅ Calendar visualization
✅ Statistics calculation (streaks, totals, averages)
✅ Alarm creation and management UI
✅ Refactored views to use shared business logic
✅ Widget Extension with 3 sizes (Small, Medium, Large)
✅ Interactive check-in via App Intents
✅ Pixel-grid calendar visualizations

## What Needs Implementation

### 1. Widget Extension Setup (In Xcode)

Widget code is complete! Just needs Xcode target setup:

**Files Ready** (in `PrayerWidgets/`):
- ✅ PrayerWidgetsBundle.swift (entry point)
- ✅ PrayerWidget.swift (timeline provider)
- ✅ SmallPrayerWidget.swift (streak + today's count)
- ✅ MediumPrayerWidget.swift (35-day calendar grid)
- ✅ LargePrayerWidget.swift (20-week pixel calendar)
- ✅ CheckInIntent.swift (interactive button)

**Setup Steps** (see `PrayerWidgets/WIDGET_SETUP.md` for details):
1. File > New > Target > Widget Extension
2. Name it "PrayerWidgets"
3. Delete template files, add our widget Swift files to target
4. Share model files (PrayerEntry, PrayerStatistics, AppGroup) with both targets
5. Enable App Groups on both main app and widget: `group.johnmark.PrayerTracker`
6. Build and run PrayerWidgets scheme

**Widget Features**:
- **Small**: Streak counter + today's count with gradient background
- **Medium**: 35-day calendar grid (5 weeks) + check button
- **Large**: 20-week pixel calendar with weekday labels + interactive check-in button

### 2. Live Activities (High Priority)

For prayer countdown timers:

**Implementation Steps**:
1. Create `ActivityAttributes` struct with prayer title and duration
2. Create Live Activity view with countdown timer
3. Start activity from notification action when alarm fires
4. Auto check-in when countdown completes
5. Deep Work-inspired UI: large timer, title, clean layout

### 3. Notification Scheduling (Critical for Alarms)

**Required**:
- Request notification permissions on first launch
- Schedule local notifications for each enabled PrayerAlarm
- Update/cancel notifications when alarms are toggled or deleted
- Notification actions to start Live Activity

**Files to update**:
- AlarmsView.swift: Lines marked with `// TODO: Schedule or cancel notification`
- Create NotificationManager helper class

### 4. Visual Polish

**Animations**:
- Check-in button: Scale + color pulse on tap
- Streak updates: Count-up animation
- Calendar cells: Fade-in when data loads
- Tab transitions

**Additional**:
- Empty states for calendar/stats when no data
- Loading states
- Error handling for ModelContainer failures

## Testing

### Unit Tests

Test files are located in `Prayer TrackerTests/`. The main test suite is `PrayerStatisticsTests.swift` with 25+ test cases covering:

**Streak Calculation Tests**:
- Empty data handling
- Single day streaks
- Consecutive day counting
- Streak breaks with missing days
- Multiple entries per day
- Finding longest vs current streak
- Out-of-order entries
- Month boundary handling

**Count Tests**:
- Today's prayer count
- This week count
- This month count
- Weekly averages
- Date-specific queries

**Edge Cases**:
- Empty data sets
- Single entries
- Cross-boundary calculations
- Unsorted data

### Running Tests

**In Xcode**:
1. Cmd+U to run all tests
2. Test navigator (Cmd+6) to run specific tests

**Command Line** (after creating test target in Xcode):
```bash
xcodebuild test -project "Prayer Tracker.xcodeproj" -scheme "Prayer Tracker" -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Adding New Tests

1. Open `Prayer TrackerTests/PrayerStatisticsTests.swift`
2. Add test method with `func test...()` naming
3. Use XCTest assertions: `XCTAssertEqual`, `XCTAssertTrue`, etc.
4. Create test data with specific dates using `Calendar.date(byAdding:)`

## Common Development Tasks

### Adding a new view:
1. Create Swift file in `Prayer Tracker/` directory
2. Import SwiftUI and SwiftData
3. Add `@Environment(\.modelContext)` for mutations
4. Add `@Query` for data fetching
5. Use dark background: `Color(white: 0.05).ignoresSafeArea()`
6. Match existing design system (rounded fonts, purple accent)

### Modifying data models:
1. Update model files (PrayerEntry.swift or PrayerAlarm.swift)
2. SwiftData will auto-migrate for simple changes
3. For breaking changes, increment modelVersion or handle migration

### Testing with sample data:
Use in-memory containers in previews:
```swift
#Preview {
    YourView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
```

## Project Structure

```
Prayer Tracker/
├── Prayer_TrackerApp.swift      # App entry, ModelContainer setup
├── ContentView.swift             # TabView navigation
├── AppGroup.swift                # App Group configuration
│
├── Business Logic/
│   └── PrayerStatistics.swift    # Testable statistics calculations
│
├── Models/
│   ├── PrayerEntry.swift         # Prayer check-in model
│   └── PrayerAlarm.swift         # Alarm schedule model
│
├── Views/
│   ├── TodayView.swift           # Home/check-in screen
│   ├── CalendarView.swift        # Monthly calendar grid
│   ├── StatisticsView.swift      # Stats dashboard
│   └── AlarmsView.swift          # Alarm management
│
└── Assets.xcassets/              # Asset catalog

PrayerWidgets/
├── PrayerWidgetsBundle.swift    # Widget bundle entry point
├── PrayerWidget.swift            # Timeline provider
├── SmallPrayerWidget.swift       # Small widget (streak + count)
├── MediumPrayerWidget.swift      # Medium widget (5-week calendar)
├── LargePrayerWidget.swift       # Large widget (20-week calendar)
├── CheckInIntent.swift           # App Intent for button
├── WIDGET_SETUP.md               # Setup instructions
└── Info.plist                    # Extension info

Prayer TrackerTests/
└── PrayerStatisticsTests.swift   # Unit tests for business logic
```

## Key Implementation Patterns

**Prayer check-in** (TodayView.swift:122-131):
```swift
let entry = PrayerEntry(timestamp: Date())
modelContext.insert(entry)
```

**Streak calculation** (TodayView.swift:24-43):
- Iterate backwards from today
- Check if each day has at least one entry
- Count consecutive days with entries

**Calendar filtering** (CalendarView.swift:17-23):
- Get all entries with `@Query`
- Filter by date using `Calendar.isDate(_:inSameDayAs:)`

**Alarm scheduling** (AlarmsView.swift:83-98):
- Extract hour/minute from DatePicker
- Create PrayerAlarm with components
- TODO: Schedule UNNotificationRequest

## Known Issues & Fixes

### Data Persistence Fix (2025-10-27)

**Issue**: Prayer check-ins were not persisting after app restart.

**Cause**: The ModelContainer fallback configuration when App Groups wasn't enabled was incorrectly specified, causing data to be stored in-memory only.

**Fix**: Updated `Prayer_TrackerApp.swift` lines 19-35 to use SwiftData's default persistent storage when App Groups is unavailable:
```swift
return try ModelContainer(for: schema)  // Uses default persistent location
```

**Testing**: See `TESTING_PERSISTENCE.md` for verification steps.

## Notes

- The app uses `ModelConfiguration(url:)` when App Group is available for shared storage
- All views use `.toolbarBackground(.ultraThinMaterial)` for consistency
- Haptic feedback on check-in via `UIImpactFeedbackGenerator`
- Old `Item.swift` model from template can be safely removed
- Data persists correctly with or without App Groups enabled
