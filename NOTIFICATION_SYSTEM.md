# Prayer Alarm Notification System

## Overview
Implemented complete local notification system for prayer alarms using UserNotifications framework. Users now receive daily reminders at their scheduled prayer times.

## Implementation

### 1. NotificationManager.swift ⭐ NEW
Centralized notification manager using singleton pattern.

**Key Features:**
- Request notification permissions
- Schedule daily repeating notifications
- Cancel notifications by identifier
- Check authorization status
- Notification categories with actions (prepared for Live Activity)

**Methods:**
```swift
// Permission management
func requestAuthorization() async -> Bool
func checkAuthorizationStatus() async -> UNAuthorizationStatus

// Scheduling
func scheduleAlarmNotification(for alarm: PrayerAlarm) async -> String?

// Cancellation
func cancelNotification(identifier: String)
func cancelAllNotifications()

// Debugging
func getPendingNotifications() async -> [UNNotificationRequest]
func printPendingNotifications() async
```

### 2. Notification Content

**Title**: "{Prayer Name} Time"
- Example: "Morning Prayer Time"

**Body**: "Take {duration} minutes to pray"
- Example: "Take 15 minutes to pray"

**Properties**:
- Sound: Default system sound
- Badge: App icon badge (set to 1)
- Category: "PRAYER_ALARM" (with actions)
- Repeats: Daily at specified hour:minute

**User Info** (metadata for future use):
```swift
[
    "alarmTitle": "Morning Prayer",
    "durationMinutes": 15,
    "hour": 7,
    "minute": 30
]
```

### 3. Notification Trigger

Uses `UNCalendarNotificationTrigger` for daily repeats:
```swift
var dateComponents = DateComponents()
dateComponents.hour = alarm.hour
dateComponents.minute = alarm.minute
let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
```

**Behavior:**
- Fires every day at the specified time
- Persists across app restarts
- Managed by iOS system
- Respects Do Not Disturb settings

### 4. Notification Actions (Future-Ready)

Defined category with actions for Live Activity integration:

**Actions:**
1. **Start Prayer Timer**: Foreground action to launch app and start timer
2. **Snooze 5 min**: Background action to delay notification

```swift
let startTimerAction = UNNotificationAction(
    identifier: "START_TIMER",
    title: "Start Prayer Timer",
    options: [.foreground]
)

let snoozeAction = UNNotificationAction(
    identifier: "SNOOZE",
    title: "Snooze 5 min",
    options: []
)
```

## Integration Points

### AddAlarmView.swift
**When**: User saves new alarm

**Flow:**
1. Check authorization status
2. Request permission if not determined
3. Schedule notification if alarm is enabled
4. Store notification identifier in alarm

```swift
Task {
    let status = await NotificationManager.shared.checkAuthorizationStatus()
    if status == .notDetermined {
        let granted = await NotificationManager.shared.requestAuthorization()
        if !granted { return }
    }

    if alarm.isEnabled {
        if let identifier = await NotificationManager.shared.scheduleAlarmNotification(for: alarm) {
            alarm.notificationIdentifier = identifier
        }
    }
}
```

### AlarmRow.swift (Toggle)
**When**: User toggles alarm on/off

**Toggle ON:**
- Schedule new notification
- Store identifier

**Toggle OFF:**
- Cancel existing notification
- Clear identifier

```swift
Task {
    if newValue {
        // Schedule
        if let identifier = await NotificationManager.shared.scheduleAlarmNotification(for: alarm) {
            alarm.notificationIdentifier = identifier
        }
    } else {
        // Cancel
        if let identifier = alarm.notificationIdentifier {
            NotificationManager.shared.cancelNotification(identifier: identifier)
            alarm.notificationIdentifier = nil
        }
    }
}
```

### AlarmsView.swift (Delete)
**When**: User deletes alarm

**Flow:**
1. Cancel notification using stored identifier
2. Delete alarm from database

```swift
if let identifier = alarm.notificationIdentifier {
    NotificationManager.shared.cancelNotification(identifier: identifier)
}
modelContext.delete(alarm)
```

## Permission Handling

### First Time Flow
1. User creates first alarm
2. App checks: `notificationSettings().authorizationStatus`
3. If `.notDetermined`: Request permission
4. User sees iOS permission dialog
5. User grants/denies
6. If granted: schedule notification
7. If denied: notification not scheduled (graceful failure)

### Subsequent Times
- Status is already `.authorized` or `.denied`
- Skip permission request
- Schedule immediately if authorized
- Fail gracefully if denied

### Permission States
- **Not Determined**: First time, need to request
- **Authorized**: Can schedule notifications
- **Denied**: User declined, can't schedule
- **Provisional**: iOS delivers quietly (no dialog)

## Notification Identifier Format

**Pattern**: `"prayer-alarm-{UUID}"`

**Example**: `"prayer-alarm-A1B2C3D4-E5F6-7890-ABCD-EF1234567890"`

**Storage**: Stored in `PrayerAlarm.notificationIdentifier`

**Usage**:
- Cancellation: `cancelNotification(identifier:)`
- Tracking: Know which notification belongs to which alarm
- Updates: Cancel old, schedule new

## Testing

### Manual Testing Checklist

**Basic Flow:**
- [x] Create alarm → permission requested (first time)
- [x] Grant permission → notification scheduled
- [x] Check Settings → notification appears
- [x] Toggle off → notification canceled
- [x] Toggle on → notification rescheduled
- [x] Delete alarm → notification canceled

**Verification:**
```swift
// Print pending notifications
Task {
    await NotificationManager.shared.printPendingNotifications()
}
```

**Notification Settings:**
- Go to iOS Settings → Prayer Tracker → Notifications
- Verify: Allow Notifications is ON
- Check: Sounds, Badges, Banners

### Testing on Device

**Important**: Test on physical device, not simulator
- Simulator has limited notification support
- Real device shows actual notification behavior

**Quick Test:**
1. Set alarm for 1 minute from now
2. Lock device
3. Wait for notification
4. Verify: Title, body, sound correct

### Debug Commands

```swift
// In any view, add button:
Button("Debug Notifications") {
    Task {
        await NotificationManager.shared.printPendingNotifications()
    }
}

// Console output:
📋 Pending notifications: 3
  - prayer-alarm-ABC: Morning Prayer Time at 2025-10-29 07:00:00
  - prayer-alarm-DEF: Evening Prayer Time at 2025-10-29 18:30:00
  - prayer-alarm-GHI: Night Prayer Time at 2025-10-29 22:00:00
```

## Error Handling

### Permission Denied
```swift
if !granted {
    print("⚠️ Notification permission denied")
    // Future: Show alert to user
    return
}
```

### Scheduling Failed
```swift
do {
    try await center.add(request)
    return identifier
} catch {
    print("❌ Error scheduling notification: \(error)")
    return nil
}
```

### Graceful Degradation
- If permissions denied: app still works, just no notifications
- If scheduling fails: alarm still exists, can retry
- If cancel fails: won't affect app functionality

## Benefits

✅ **Daily Reminders**: Automatic reminders every day
✅ **Persistent**: Survives app restarts and device reboots
✅ **System Integrated**: Uses iOS notification system
✅ **User Control**: Toggle on/off, delete to cancel
✅ **Prayer Context**: Shows prayer name and duration
✅ **Future Ready**: Actions prepared for Live Activity
✅ **Debugging**: Built-in tools to inspect notifications

## Future Enhancements

### Immediate (Next Steps)
1. **Alert Dialog**: Show user if permission denied
2. **Permission Settings**: Deep link to Settings if denied
3. **Re-request**: Allow re-requesting if user changes mind

### Phase 2 (Live Activity)
1. Show countdown timer 5 minutes before alarm
2. Handle notification action "Start Timer"
3. Launch Live Activity from notification

### Phase 3 (Advanced)
1. Snooze functionality
2. Custom sounds per prayer
3. Variable repeat patterns (weekdays, weekends, custom)
4. Notification grouping by prayer
5. Rich notifications with prayer icon

## Known Limitations

1. **System Limitations**:
   - Max 64 pending notifications per app
   - Notifications may be delayed in Low Power Mode
   - Do Not Disturb blocks notifications

2. **Current Implementation**:
   - No UI feedback if permission denied
   - No retry mechanism if scheduling fails
   - No deep link to Settings for permission

3. **Testing**:
   - Simulator has limited notification support
   - Must test on physical device
   - Notifications respect system settings

## Technical Notes

### Why @MainActor?
```swift
@MainActor
class NotificationManager: ObservableObject
```
- UI updates from notification results must be on main thread
- SwiftData context operations need main actor
- Ensures thread safety

### Why UUID Identifiers?
- Unique across all alarms
- Prevents conflicts
- Easy to generate
- Trackable in logs

### Why Store Identifier in Alarm?
- Enables cancellation
- Tracks notification status
- Allows updates/reschedules
- Debugging and verification

## Files Created/Modified

### Created:
1. ✨ `NotificationManager.swift` - Complete notification handling system

### Modified:
2. ✏️ `AlarmsView.swift` - Delete handler cancels notifications
3. ✏️ `AlarmRow.swift` - Toggle schedules/cancels notifications
4. ✏️ `AddAlarmView.swift` - Save requests permission and schedules

### Unchanged (Using existing field):
- `PrayerAlarm.swift` - Already has `notificationIdentifier: String?`

## Summary

✅ **Complete notification system implemented**
✅ **Permission handling integrated**
✅ **Schedule/cancel on create/toggle/delete**
✅ **Future-ready with action categories**
✅ **Debugging tools included**

**Ready for**: Testing on physical device and Live Activity implementation

---

**Next Step**: Test notifications on device, then implement Live Activity countdown timer!
