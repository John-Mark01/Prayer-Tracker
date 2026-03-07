# Widget Target Membership Fix

## Problem
The PrayerWidgetsExtension target currently includes many files that should only be in the main app target, causing build failures.

## Solution - Fix Target Membership in Xcode

### Files that should be in MAIN APP ONLY:
Remove these from PrayerWidgetsExtension target:
- TodayView.swift
- ContentView.swift
- CalendarView.swift
- StatisticsView.swift
- AlarmsView.swift
- AddPrayerSheet.swift
- IconPickerView.swift
- PrayerCardView.swift
- PrayerDetailView.swift
- StatCard.swift
- Item.swift (can be deleted entirely)

### Files that should be in BOTH targets:
These need to be shared between main app and widget:
- Prayer.swift
- PrayerEntry.swift
- PrayerStatistics.swift
- AppGroup.swift
- PixelGridView.swift (if widgets use it)

### Files that should be in WIDGET TARGET ONLY:
Keep these in PrayerWidgetsExtension:
- PrayerWidgetsBundle.swift
- PrayerWidget.swift
- SmallPrayerWidget.swift
- MediumPrayerWidget.swift
- LargePrayerWidget.swift
- CheckInIntent.swift
- PrayerWidgetsControl.swift

## How to Fix in Xcode

1. Open Prayer Tracker.xcodeproj in Xcode
2. Select each file in the Navigator
3. Open File Inspector (right panel)
4. Under "Target Membership":
   - Uncheck PrayerWidgetsExtension for main app UI files
   - Keep checked for shared model/data files
5. Build again

## After Fix
Once target membership is corrected, the project should build successfully with the new multi-prayer tracking functionality.
