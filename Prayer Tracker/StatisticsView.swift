//
//  StatisticsView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var allEntries: [PrayerEntry]

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: allEntries)
    }

    private var totalPrayers: Int {
        allEntries.count
    }

    private var currentStreak: Int {
        stats.currentStreak()
    }

    private var longestStreak: Int {
        stats.longestStreak()
    }

    private var thisWeekCount: Int {
        stats.thisWeekCount()
    }

    private var thisMonthCount: Int {
        stats.thisMonthCount()
    }

    private var weeklyAverage: Double {
        stats.weeklyAverage()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Streak Cards
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Current Streak",
                                value: "\(currentStreak)",
                                subtitle: "days",
                                icon: "flame.fill",
                                color: .orange
                            )

                            StatCard(
                                title: "Longest Streak",
                                value: "\(longestStreak)",
                                subtitle: "days",
                                icon: "trophy.fill",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)

                        // Count Cards
                        VStack(spacing: 16) {
                            StatCard(
                                title: "Total Prayers",
                                value: "\(totalPrayers)",
                                subtitle: "all time",
                                icon: "hands.sparkles.fill",
                                color: .purple,
                                isWide: true
                            )

                            HStack(spacing: 16) {
                                StatCard(
                                    title: "This Week",
                                    value: "\(thisWeekCount)",
                                    subtitle: "prayers",
                                    icon: "calendar",
                                    color: .blue
                                )

                                StatCard(
                                    title: "This Month",
                                    value: "\(thisMonthCount)",
                                    subtitle: "prayers",
                                    icon: "calendar.badge.clock",
                                    color: .green
                                )
                            }

                            StatCard(
                                title: "Weekly Average",
                                value: String(format: "%.1f", weeklyAverage),
                                subtitle: "prayers per week",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .pink,
                                isWide: true
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    var isWide: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: isWide ? 48 : 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
