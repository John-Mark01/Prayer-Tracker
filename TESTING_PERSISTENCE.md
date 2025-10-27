# Testing Data Persistence

## The Fix

**Problem**: Prayer check-ins were not being saved between app launches.

**Root Cause**: The ModelContainer configuration had a fallback that didn't properly specify persistent storage when App Groups wasn't enabled in Xcode.

**Solution**: Updated `Prayer_TrackerApp.swift` to use SwiftData's default persistent storage location when App Groups isn't configured.

## How to Test Persistence

### Manual Testing Steps

1. **Launch the app** in the simulator or on device
2. **Add some prayer check-ins**:
   - Tap the "Check In" button on the Today tab
   - Do this 3-4 times
   - Note the prayer count and streak number
3. **Force quit the app**:
   - On simulator: Stop the app in Xcode or use `Cmd+Shift+H` twice and swipe up
   - On device: Swipe up from bottom and force close
4. **Relaunch the app**
5. **Verify data persisted**:
   - Prayer count should be the same
   - Streak should be maintained
   - Calendar view should show today's check-ins

### Using Console Logs

You can verify which storage mode is being used:

```bash
# View app logs
xcrun simctl spawn [SIMULATOR_ID] log stream --predicate 'processImagePath contains "Prayer"' --level debug
```

Look for:
- ✅ No warning = App Groups is configured (data in shared container)
- ⚠️ Warning message = Using default storage (data in app's Documents directory)

Both modes are persistent! The warning just indicates that data won't be shared with widgets/Live Activities until App Groups is enabled.

## Storage Locations

### Default Storage (Current)
- **Path**: `~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Library/Application Support/default.store`
- **Shared**: No (widgets won't have access)
- **Persistent**: ✅ Yes

### App Group Storage (When Enabled)
- **Path**: `~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Shared/AppGroup/[GROUP_ID]/PrayerTracker.sqlite`
- **Shared**: ✅ Yes (widgets and Live Activities can access)
- **Persistent**: ✅ Yes

## Enabling App Groups (For Widget Support)

When you're ready to add widgets:

1. Open `Prayer Tracker.xcodeproj` in Xcode
2. Select the "Prayer Tracker" target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **App Groups**
6. Enable `group.johnmark.PrayerTracker`
7. Rebuild the app

After enabling, the app will automatically use the shared container.

## Troubleshooting

### Data still not persisting?

1. **Check for crashes**:
   ```bash
   xcrun simctl diagnose
   ```

2. **Verify ModelContainer creation**:
   - Look for "Could not create ModelContainer" fatal errors
   - Check console for SwiftData warnings

3. **Clear app data and test fresh**:
   ```bash
   xcrun simctl uninstall [DEVICE_ID] johnmark.Prayer-Tracker
   ```

4. **Check file permissions**:
   - Simulator: Verify ~/Library/Developer/CoreSimulator access
   - Device: Ensure app has storage permissions

### Migrating from broken storage

If you had data with the old broken configuration:

1. The old data is lost (it was in-memory only due to the bug)
2. Fresh install with new code will work correctly
3. All new data will persist properly

## Verification Checklist

- [ ] App installs successfully
- [ ] Can create prayer check-ins
- [ ] Counter increments correctly
- [ ] Force quit app (completely terminate)
- [ ] Relaunch app
- [ ] Data is still there (count, streak, calendar)
- [ ] Can add more check-ins after restart
- [ ] Calendar shows all historical entries
- [ ] Stats page shows correct streaks
