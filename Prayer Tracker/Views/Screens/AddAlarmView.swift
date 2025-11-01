//
//  AddAlarmView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 31.10.25.
//

import SwiftUI
import SwiftData
internal import EventKit

struct AddAlarmView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Prayer.sortOrder) private var prayers: [Prayer]

    @State private var selectedPrayer: Prayer?
    @State private var selectedTime = Date()
    @State private var durationMinutes = 1
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
                                            .foregroundStyle(Color(hex: prayer.colorHex) ?? .green)
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
                                Text("1 minute").tag(1)
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
