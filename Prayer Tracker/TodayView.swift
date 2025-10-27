//
//  TodayView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [PrayerEntry]

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: allEntries)
    }

    private var todayCount: Int {
        stats.todayCount()
    }

    private var currentStreak: Int {
        stats.currentStreak()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    // Streak Counter
                    VStack(spacing: 8) {
                        Text("\(currentStreak)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("DAY STREAK")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .tracking(2)
                    }

                    // Today's Count
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "hands.sparkles.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.purple)

                            Text("\(todayCount)")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Text("prayers today")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    // Check-in Button
                    Button(action: checkIn) {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28))

                            Text("Check In")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .purple.opacity(0.5), radius: 20, y: 10)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Prayer Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }

    private func checkIn() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let entry = PrayerEntry(timestamp: Date())
            modelContext.insert(entry)

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
