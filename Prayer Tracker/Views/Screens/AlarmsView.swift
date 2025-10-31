//
//  AlarmsView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

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
                #if DEBUG
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingDebug = true }) {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.orange)
                    }
                }
                #endif

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddAlarm = true }) {
                        Image(systemName: "plus")
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

#Preview {
    AlarmsView()
        .modelContainer(for: PrayerAlarm.self, inMemory: true)
}
