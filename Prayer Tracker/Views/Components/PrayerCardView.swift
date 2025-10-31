//
//  PrayerCardView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI

struct PrayerCardView: View {
    let prayer: Prayer
    let entries: [PrayerEntry]
    let todayCount: Int
    let onCheckIn: () -> Void
    let onTap: () -> Void

    private var color: Color {
        Color(hex: prayer.colorHex) ?? .purple
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 20) {
                
                // Icon Circle
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: prayer.iconName)
                        .font(.system(size: 28))
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(prayer.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Subtitle
                    if !prayer.subtitle.isEmpty {
                        Text(prayer.subtitle)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                // Check-in Button
                Button(action: {
                    onCheckIn()
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(todayCount > 0 ? 1.0 : 0.2))
                            .frame(width: 40, height: 40)
                        
                        if todayCount > 0 {
                            Text("\(todayCount)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(color)
                        }
                    }
                }
                .frame(alignment: .trailing)

            }
            
            // Pixel Grid
            PixelGridView(
                entries: entries,
                color: color,
                dayCount: 70,
                pixelSize: 20,
                vSpacing: 3.5,
                hSpacing: 5
            )
        }
        .padding(16)
        .frame(minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// Helper extension to convert hex string to Color
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrayerCardView(
            prayer: Prayer(
                title: "Morning Prayer",
                subtitle: "Start the day with gratitude and thanksgiving with regular practice",
                iconName: "sunrise.fill",
                colorHex: "#9333EA"
            ),
            entries: Array(0..<30).flatMap { day in
                Array(0..<Int.random(in: 0...5)).map { _ in
                    PrayerEntry(timestamp: Date().addingTimeInterval(-86400 * Double(day)))
                }
            },
            todayCount: 3,
            onCheckIn: {},
            onTap: {}
        )

        PrayerCardView(
            prayer: Prayer(
                title: "Evening Reflection",
                subtitle: "Review the day",
                iconName: "moon.stars.fill",
                colorHex: "#3B82F6"
            ),
            entries: [],
            todayCount: 0,
            onCheckIn: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color(white: 0.05))
}
