//
//  AlarmRow.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 31.10.25.
//

import SwiftUI

struct AlarmRow: View {
    let alarm: PrayerAlarm
    let onToggle: () -> Void

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

                Text("Prayer duration: \(alarm.durationMinutes) min")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white.opacity(0.8))

                if alarm.hasReminder {
                    Text("Reminder: \(alarm.reminderMinutesBefore) minutes before")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in
                    onToggle()
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
    let container = AppContainer.build()
    return VStack {
        AlarmRow(
            alarm: .init(
                title: "Here is a long titled alarm for testing",
                hour: 10,
                minute: 30
            ),
            onToggle: {}
        )
    }
    .environment(\.appContainer, container)
}
