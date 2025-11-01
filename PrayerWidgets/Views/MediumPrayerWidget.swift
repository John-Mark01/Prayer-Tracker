//
//  MediumPrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import WidgetKit
import AppIntents

struct MediumPrayerWidget: View {
    let entry: PrayerWidgetEntry

    private var color: Color {
        if let prayer = entry.prayer {
            return Color(hex: prayer.colorHex)
        }
        return .purple
    }

    var body: some View {
        if let prayer = entry.prayer {
            VStack(alignment: .center, spacing: 16) {
                HStack(alignment: .top, spacing: 8) {
                    
                    // Icon Circle
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: prayer.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(prayer.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Check-in Button
                    VStack(alignment:.center, spacing: 6) {
                        Button(intent: {
                            let intent = CheckInIntent()
                            intent.prayerId = prayer.id.uuidString
                            return intent
                        }()) {
                            ZStack {
                                Circle()
                                    .fill(color.opacity(entry.todayCount > 0 ? 1.0 : 0.2))
                                    .frame(width: 35, height: 35)
                                
                                if entry.todayCount > 0 {
                                    Text("\(entry.todayCount)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(color)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text("Check-In")
                            .font(.system(size: 10, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .frame(alignment: .trailing)
                }
                
                // Pixel Grid
                WidgetPixelGridView(
                    entries: entry.entries,
                    color: Color.init(hex: prayer.colorHex),
                    dayCount: 80,
                    pixelSize: 13,
                    vSpacing: 3.5,
                    hSpacing: 5
                )
                .padding(.vertical, -6)
            }
            .padding(16)
            
        } else {
            // Empty state when no prayer is selected
            VStack(spacing: 8) {
                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.3))
                
                Text("Select Prayer")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    let sampleEntries = Array(0..<60).flatMap { day in
        Array(0..<Int.random(in: 1...5)).map { _ in
            PrayerEntry(timestamp: Date().addingTimeInterval(86400 * Double(day)))
        }
    }
    let todayEntries = Array(0..<3).compactMap { _ in
        PrayerEntry(timestamp: Date())
    }
    
    let entries = sampleEntries + todayEntries
    
    PrayerWidgetEntry(
        date: Date(),
        prayer: WidgetPrayerEntity(
            id: UUID(),
            title: "Morning Prayer",
            subtitle: "Start the day with gratitude",
            iconName: "sunrise.fill",
            colorHex: "#9333EA"
        ),
        entries: entries,
        todayCount: 0,
        currentStreak: 18
    )
}
