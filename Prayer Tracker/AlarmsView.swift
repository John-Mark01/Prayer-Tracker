//
//  AlarmsView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData
internal import EventKit

struct AlarmsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\PrayerAlarm.hour), SortDescriptor(\PrayerAlarm.minute)]) private var alarms: [PrayerAlarm]
    @Query(sort: \Prayer.sortOrder) private var prayers: [Prayer]
    @State private var showingAddAlarm = false
    @State private var showingDebug = false

    // Group alarms by prayer
    private var groupedAlarms: [(prayer: Prayer?, alarms: [PrayerAlarm])] {
        let grouped = Dictionary(grouping: alarms) { $0.prayer }

        // Sort: prayers with alarms first (by prayer sort order), then orphaned alarms
        var result: [(Prayer?, [PrayerAlarm])] = []

        // Add prayers with alarms
        for prayer in prayers {
            if let prayerAlarms = grouped[prayer], !prayerAlarms.isEmpty {
                result.append((prayer, prayerAlarms))
            }
        }

        // Add orphaned alarms (no prayer associated)
        if let orphanedAlarms = grouped[nil], !orphanedAlarms.isEmpty {
            result.append((nil, orphanedAlarms))
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                if alarms.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("No Prayer Alarms")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Create an alarm to get reminded when it's time to pray")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(Array(groupedAlarms.enumerated()), id: \.offset) { _, group in
                            Section {
                                ForEach(group.alarms) { alarm in
                                    AlarmRow(alarm: alarm, modelContext: modelContext)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                }
                                .onDelete { offsets in
                                    deleteAlarms(from: group.alarms, offsets: offsets)
                                }
                            } header: {
                                if let prayer = group.prayer {
                                    HStack(spacing: 8) {
                                        Image(systemName: prayer.iconName)
                                            .foregroundStyle(Color(hex: prayer.colorHex) ?? .purple)
                                        Text(prayer.title)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundStyle(.white)
                                    .textCase(nil)
                                } else {
                                    Text("Other Alarms")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.6))
                                        .textCase(nil)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Prayer Alarms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingDebug = true }) {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.orange)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddAlarm = true }) {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AddAlarmView()
            }
            .sheet(isPresented: $showingDebug) {
                LiveActivityDebugView()
            }
        }
    }

    private func deleteAlarms(from alarmsList: [PrayerAlarm], offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let alarm = alarmsList[index]

                // Cancel alarm notification if exists
                if let identifier = alarm.notificationIdentifier {
                    NotificationManager.shared.cancelNotification(identifier: identifier)
                }

                // Cancel warning notification if exists
                if let identifier = alarm.warningNotificationIdentifier {
                    NotificationManager.shared.cancelNotification(identifier: identifier)
                }

                // Delete calendar event if exists
                if let calendarId = alarm.calendarIdentifier {
                    CalendarManager.shared.deleteCalendarEvent(identifier: calendarId)
                }

                // End Live Activity if exists
                if let activityId = alarm.liveActivityId {
                    Task {
                        await LiveActivityManager.shared.endActivity(activityID: activityId)
                    }
                }

                modelContext.delete(alarm)
            }
        }
    }
}

struct AlarmRow: View {
    let alarm: PrayerAlarm
    let modelContext: ModelContext

    private var prayerColor: Color {
        if let prayer = alarm.prayer {
            return Color(hex: prayer.colorHex) ?? .purple
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

                Text("\(alarm.durationMinutes) min")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { newValue in
                    alarm.isEnabled = newValue

                    // Schedule or cancel notifications, calendar event, and Live Activity
                    Task {
                        if newValue {
                            // Toggled ON - schedule notifications and calendar

                            // 1. Schedule warning notification (5 min before)
                            if let identifier = await NotificationManager.shared.scheduleWarningNotification(for: alarm) {
                                alarm.warningNotificationIdentifier = identifier
                            }

                            // 2. Schedule alarm notification
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

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Prayer.sortOrder) private var prayers: [Prayer]

    @State private var selectedPrayer: Prayer?
    @State private var selectedTime = Date()
    @State private var durationMinutes = 5
    @State private var addToCalendar = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                if prayers.isEmpty {
                    // Empty state when no prayers exist
                    VStack(spacing: 16) {
                        Image(systemName: "hands.sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("No Prayers Yet")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Create a prayer first before adding alarms")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    Form {
                        Section {
                            Picker("Prayer", selection: $selectedPrayer) {
                                Text("Select Prayer").tag(nil as Prayer?)
                                ForEach(prayers) { prayer in
                                    HStack {
                                        Image(systemName: prayer.iconName)
                                            .foregroundStyle(Color(hex: prayer.colorHex) ?? .purple)
                                        Text(prayer.title)
                                    }
                                    .tag(prayer as Prayer?)
                                }
                            }
                        } header: {
                            Text("Which Prayer")
                        }

                        Section {
                            DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                        } header: {
                            Text("When")
                        }

                        Section {
                            Picker("Duration", selection: $durationMinutes) {
                                Text("5 minutes").tag(5)
                                Text("10 minutes").tag(10)
                                Text("15 minutes").tag(15)
                                Text("20 minutes").tag(20)
                                Text("30 minutes").tag(30)
                            }
                            .pickerStyle(.wheel)
                        } header: {
                            Text("Duration")
                        }

                        Section {
                            Toggle("Add to Calendar", isOn: $addToCalendar)
                                .tint(.purple)
                        } header: {
                            Text("Calendar Integration")
                        } footer: {
                            Text("Create a recurring event in your Calendar app for this prayer time")
                                .font(.caption)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("New Prayer Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if !prayers.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveAlarm()
                        }
                        .disabled(selectedPrayer == nil)
                    }
                }
            }
        }
    }

    private func saveAlarm() {
        guard let prayer = selectedPrayer else { return }

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)

        let alarm = PrayerAlarm(
            title: prayer.title,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            durationMinutes: durationMinutes,
            isEnabled: true,
            prayer: prayer,
            addToCalendar: addToCalendar
        )

        modelContext.insert(alarm)

        // Request permissions and schedule notifications/calendar
        Task {
            // 1. Handle notifications (always)
            let notifStatus = await NotificationManager.shared.checkAuthorizationStatus()
            if notifStatus == .notDetermined {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    print("⚠️ Notification permission denied")
                }
            }

            // Schedule notifications if enabled
            if alarm.isEnabled {
                // Schedule warning notification (5 min before)
                if let identifier = await NotificationManager.shared.scheduleWarningNotification(for: alarm) {
                    alarm.warningNotificationIdentifier = identifier
                }

                // Schedule alarm notification
                if let identifier = await NotificationManager.shared.scheduleAlarmNotification(for: alarm) {
                    alarm.notificationIdentifier = identifier
                }

                // Note: Live Activity will be started when warning notification fires
            }

            // 2. Handle calendar integration (only if user opted in)
            if alarm.addToCalendar {
                let calStatus = CalendarManager.shared.checkAuthorizationStatus()

                // Request calendar permission if needed
                if calStatus == .notDetermined {
                    let granted = await CalendarManager.shared.requestCalendarAccess()
                    if !granted {
                        print("⚠️ Calendar permission denied")
                        return
                    }
                }

                // Create calendar event
                if let calendarId = await CalendarManager.shared.createCalendarEvent(for: alarm) {
                    alarm.calendarIdentifier = calendarId
                }
            }
        }

        dismiss()
    }
}

#Preview {
    AlarmsView()
        .modelContainer(for: PrayerAlarm.self, inMemory: true)
}
