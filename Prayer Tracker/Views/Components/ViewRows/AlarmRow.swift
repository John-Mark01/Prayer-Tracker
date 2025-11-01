//
//  AlarmRow.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 31.10.25.
//

import SwiftUI
import SwiftData
internal import EventKit

struct AlarmRow: View {
    let alarm: PrayerAlarm
    let modelContext: ModelContext

    private var prayerColor: Color {
        if let prayer = alarm.prayer {
            return Color(hex: prayer.colorHex)
        }
        return .purple
    }

    var body: some View {
        HStack(spacing: 16) {
            // Prayer icon
            if let prayer = alarm.prayer {
                ZStack {
                    Circle()
                        .fill(prayerColor.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: prayer.iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(prayerColor)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(alarm.displayTitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))

                Text("Prayer duration: \(alarm.durationMinutes) min")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    alarm.isEnabled = newValue

                    // Schedule or cancel notifications, calendar event, and Live Activity
                    Task {
                        if newValue {
                            // Toggled ON - schedule notifications and calendar

                            // 1. Schedule warning notification (only if reminder is enabled)
                            if alarm.hasReminder {
                                if let identifier = await NotificationManager.shared.scheduleWarningNotification(for: alarm) {
                                    alarm.warningNotificationIdentifier = identifier
                                }
                            }

                            // 2. Schedule alarm notification (always scheduled)
                            if let identifier = await NotificationManager.shared.scheduleAlarmNotification(for: alarm) {
                                alarm.notificationIdentifier = identifier
                            }

                            // 3. Create calendar event if user opted in
                            if alarm.addToCalendar && alarm.calendarIdentifier == nil {
                                let calStatus = CalendarManager.shared.checkAuthorizationStatus()

                                // Request permission if needed
                                if calStatus == .notDetermined {
                                    let granted = await CalendarManager.shared.requestCalendarAccess()
                                    if !granted {
                                        print("⚠️ Calendar permission denied on toggle")
                                        return
                                    }
                                }

                                // Create event if authorized
                                if calStatus == .fullAccess || calStatus == .notDetermined {
                                    if let calendarId = await CalendarManager.shared.createCalendarEvent(for: alarm) {
                                        alarm.calendarIdentifier = calendarId
                                    }
                                }
                            }

                            // Note: Live Activity will be started when warning notification fires
                        } else {
                            // Toggled OFF - cancel everything

                            // 1. End Live Activity if exists
                            if let activityId = alarm.liveActivityId {
                                await LiveActivityManager.shared.endActivity(activityID: activityId)
                                alarm.liveActivityId = nil
                            }

                            // 2. Cancel alarm notification
                            if let identifier = alarm.notificationIdentifier {
                                NotificationManager.shared.cancelNotification(identifier: identifier)
                                alarm.notificationIdentifier = nil
                            }

                            // 3. Cancel warning notification
                            if let identifier = alarm.warningNotificationIdentifier {
                                NotificationManager.shared.cancelNotification(identifier: identifier)
                                alarm.warningNotificationIdentifier = nil
                            }

                            // 4. Delete calendar event if exists
                            if let calendarId = alarm.calendarIdentifier {
                                if CalendarManager.shared.deleteCalendarEvent(identifier: calendarId) {
                                    alarm.calendarIdentifier = nil
                                }
                            }
                        }
                    }
                }
            ))
            .tint(prayerColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(alarm.isEnabled ? 0.1 : 0.05))
        )
        .opacity(alarm.isEnabled ? 1.0 : 0.6)
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext
    VStack {
        AlarmRow(
            alarm: .init(
                title: "Here is a long titled alarm for testing",
                hour: 10,
                minute: 90
            ),
            modelContext: modelContext
        )
    }
    .modelContainer(for: PrayerAlarm.self, inMemory: true)
}

