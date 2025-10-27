# Prayer Tracker Widgets - Setup Guide

## Overview

Three beautiful widget sizes inspired by modern habit tracking apps:

- **Small**: Streak counter + today's count
- **Medium**: 35-day calendar grid (5 weeks) + check-in button
- **Large**: 20-week pixel calendar + check-in button

All widgets use pixel-grid visualizations with color intensity based on prayer frequency.

## Files Created

```
PrayerWidgets/
├── PrayerWidgetsBundle.swift    # Widget bundle entry point
├── PrayerWidget.swift            # Main widget configuration + timeline provider
├── SmallPrayerWidget.swift       # Small widget view
├── MediumPrayerWidget.swift      # Medium widget view
├── LargePrayerWidget.swift       # Large widget view
├── CheckInIntent.swift           # App Intent for check-in button
└── Info.plist                    # Widget extension info
```

## Setting Up in Xcode

### Step 1: Create Widget Extension Target

1. **Open** `Prayer Tracker.xcodeproj` in Xcode
2. **File** → **New** → **Target**
3. Select **Widget Extension**
4. Configure:
   - Product Name: `PrayerWidgets`
   - Bundle Identifier: `johnmark.Prayer-Tracker.PrayerWidgets`
   - Include Configuration Intent: **No** (we're using App Intents)
5. Click **Finish**
6. When prompted "Activate 'PrayerWidgets' scheme?", click **Activate**

### Step 2: Delete Template Files

Xcode creates template files we don't need. Delete:
- `PrayerWidgets.swift` (the default template)
- Keep `Assets.xcassets` (we'll use it later)

### Step 3: Add Our Widget Files

1. In Project Navigator, **right-click** on `PrayerWidgets` folder
2. **Add Files to "Prayer Tracker"...**
3. Navigate to `/Users/johnkata/Prayer Tracker/PrayerWidgets/`
4. **Select all `.swift` files**:
   - PrayerWidgetsBundle.swift
   - PrayerWidget.swift
   - SmallPrayerWidget.swift
   - MediumPrayerWidget.swift
   - LargePrayerWidget.swift
   - CheckInIntent.swift
5. Ensure **Target Membership** includes `PrayerWidgets` (checkbox checked)
6. Click **Add**

### Step 4: Share Model Files

The widgets need access to the data models:

1. Select **PrayerEntry.swift** in Project Navigator
2. In **File Inspector** (right panel), under **Target Membership**:
   - ✅ Check `Prayer Tracker`
   - ✅ Check `PrayerWidgets`
3. Repeat for:
   - **PrayerAlarm.swift**
   - **PrayerStatistics.swift**
   - **AppGroup.swift**

### Step 5: Configure App Groups

**CRITICAL**: Widgets need App Groups to share data with the main app.

#### For Main App Target:
1. Select **Prayer Tracker** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Enable `group.johnmark.PrayerTracker`

#### For Widget Extension Target:
1. Select **PrayerWidgets** target
2. **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Enable `group.johnmark.PrayerTracker` (same group)

### Step 6: Configure Build Settings

1. Select **PrayerWidgets** target
2. **Build Settings** tab
3. Search for "Swift Optimization Level"
4. Set **Debug**: `-Onone`
5. Set **Release**: `-O`

### Step 7: Update Info.plist

The `Info.plist` is already created. Verify it's in the PrayerWidgets folder.

If you need to replace it:
1. Delete the existing `Info.plist` in PrayerWidgets
2. Copy `/Users/johnkata/Prayer Tracker/PrayerWidgets/Info.plist` into the target

## Building and Running

### Build the Widget

```bash
xcodebuild -project "Prayer Tracker.xcodeproj" -scheme "PrayerWidgets" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### Run on Simulator

1. Select the **PrayerWidgets** scheme in Xcode
2. Press **Cmd+R** to run
3. Xcode will:
   - Install the main app
   - Install the widget extension
   - Add the widget to the home screen
4. You can then:
   - Edit the home screen
   - Tap the **+** button
   - Search for "Prayer Tracker"
   - Add Small, Medium, or Large widget

### Testing the Widgets

1. **Add a widget** to the home screen
2. **Open the main app** and check in a few prayers
3. **Wait ~15 seconds** for widget to update
4. **Verify**:
   - Streak count appears
   - Today's count shows
   - Calendar pixels appear for today
5. **Test check-in button** (Large widget):
   - Tap the "Check In" button
   - Widget should update
   - Open main app to verify entry was added

## Widget Features

### Small Widget
- **Size**: ~155x155 pts
- **Content**:
  - Large streak number with flame icon
  - Today's prayer count
  - Gradient background (purple to dark purple)
- **Updates**: Every 15 minutes
- **Interactive**: No (tap opens app)

### Medium Widget
- **Size**: ~329x155 pts
- **Content**:
  - "Prayer" title with streak
  - 35-day calendar grid (5 weeks × 7 days)
  - Blue check-in button
  - Color intensity based on prayer count
- **Updates**: Every 15 minutes
- **Interactive**: Check button (opens app)

### Large Widget
- **Size**: ~329x345 pts
- **Content**:
  - "LAST 20 WEEKS" header
  - Streak counter (top right)
  - 140-day pixel calendar (20 weeks × 7 days)
  - Weekday labels (M T W T F S S)
  - Horizontal scrolling (if needed)
  - "Check In" button at bottom
- **Updates**: Every 15 minutes
- **Interactive**: Check In button (adds entry directly)

## Color Coding

### Pixel Intensity
- **No entry**: Light gray (opacity 0.05-0.15)
- **1-2 prayers**: Light purple/blue (opacity ~0.5)
- **3-4 prayers**: Medium purple/blue (opacity ~0.7)
- **5+ prayers**: Deep purple/blue (opacity 1.0)

### Today Indicator
- **Border**: Purple/blue stroke around today's pixel

## Troubleshooting

### Widget Not Appearing

1. **Check target membership**:
   - All widget files should have PrayerWidgets checked
   - Model files should have both targets checked

2. **Verify App Groups**:
   - Both main app and widget extension must share the same group ID
   - Check Developer Portal if group doesn't appear

3. **Clean build folder**:
   ```bash
   xcodebuild clean -project "Prayer Tracker.xcodeproj" -scheme "PrayerWidgets"
   ```

### Widget Not Updating

1. **Timeline provider issue**:
   - Check console for errors: `xcrun simctl spawn [ID] log stream`
   - Look for "Failed to fetch entries in widget"

2. **App Groups not working**:
   - Widget will show 0 streak and empty calendar
   - Check that App Groups capability is enabled
   - Verify both targets use same group identifier

3. **Force refresh**:
   - Remove widget from home screen
   - Force quit Springboard: `killall SpringBoard`
   - Re-add widget

### Check-In Button Not Working

1. **App Intent not registered**:
   - Clean and rebuild
   - Restart simulator

2. **Permission issues**:
   - Widget extension needs App Groups to write data
   - Check console for "Failed to save prayer entry from widget"

### Widget Shows Placeholder

- Normal behavior when widget first loads
- Should resolve after first timeline update (~15 minutes)
- To force update: Open main app and check in

## Performance Notes

- **Timeline updates**: Every 15 minutes (configurable in `PrayerWidget.swift`)
- **Data fetch**: Queries SwiftData on each timeline refresh
- **Large widget**: 140 days of data (20 weeks)
- **Memory usage**: Minimal (~10-15 MB per widget)

## Future Enhancements

Potential additions:
- [ ] Widget configuration (choose which stat to show)
- [ ] Dark/Light mode adaptation
- [ ] More color schemes
- [ ] Weekly goal progress
- [ ] Time-of-day based greetings
- [ ] Lock Screen widgets (iOS 16+)
