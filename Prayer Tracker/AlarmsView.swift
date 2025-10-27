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
    @State private var showingAddAlarm = false

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
                        ForEach(alarms) { alarm in
                            AlarmRow(alarm: alarm, modelContext: modelContext)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteAlarms)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Prayer Alarms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
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
        }
    }

    private func deleteAlarms(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let alarm = alarms[index]
                // TODO: Cancel notification
                modelContext.delete(alarm)
            }
        }
    }
}

struct AlarmRow: View {
    let alarm: PrayerAlarm
    let modelContext: ModelContext

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(alarm.title)
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
                    // TODO: Schedule or cancel notification
                }
            ))
            .tint(.purple)
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

    @State private var title = ""
    @State private var selectedTime = Date()
    @State private var durationMinutes = 5

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                Form {
                    Section {
                        TextField("Prayer Name", text: $title)
                            .font(.body)
                    } header: {
                        Text("Title")
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
                }
                .scrollContentBackground(.hidden)
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

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAlarm()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveAlarm() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)

        let alarm = PrayerAlarm(
            title: title,
            hour: components.hour ?? 0,
            minute: components.minute ?? 0,
            durationMinutes: durationMinutes,
            isEnabled: true
        )

        modelContext.insert(alarm)
        // TODO: Schedule notification

        dismiss()
    }
}

#Preview {
    AlarmsView()
        .modelContainer(for: PrayerAlarm.self, inMemory: true)
}
