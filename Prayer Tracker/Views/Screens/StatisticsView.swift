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
                Color.appBackground
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
                                isWide: false
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

#Preview {
    StatisticsView()
        .modelContainer(for: PrayerEntry.self, inMemory: true)
}
