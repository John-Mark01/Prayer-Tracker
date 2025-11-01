//
//  PrayerDetailView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI
import SwiftData

struct PrayerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let prayer: Prayer

    @State private var selectedMonth = Date()
    @State private var showingDeleteAlert = false

    private let calendar = Calendar.current

    private var prayerEntries: [PrayerEntry] {
        prayer.entries
    }

    private var stats: PrayerStatistics {
        PrayerStatistics(entries: prayerEntries, calendar: calendar)
    }

    private var color: Color {
        Color(hex: prayer.colorHex)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offsetDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        days += range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }

        return days
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.veryShortWeekdaySymbols
    }

    var body: some View {
        ZStack {
            Color(white: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 80, height: 80)

                        Image(systemName: prayer.iconName)
                            .font(.system(size: 40))
                            .foregroundStyle(color)
                    }

                    Text(prayer.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !prayer.subtitle.isEmpty {
                        Text(prayer.subtitle)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(maxWidth: 220)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)

                // TabView for Stats and Calendar
                TabView {
                    // Statistics Page
                    ScrollView {
                        VStack(spacing: 16) {
                            // Most important stats - Top row
                            HStack(spacing: 16) {
                                
                                StatCard(
                                    title: "Today",
                                    value: "\(stats.todayCount())",
                                    subtitle: "prayers",
                                    icon: "calendar.day.timeline.left",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "All time",
                                    value: "\(prayerEntries.count)",
                                    subtitle: "prayers",
                                    icon: "calendar",
                                    color: color
                                )

                            }

                            // Streaks row
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Current Streak",
                                    value: "\(stats.currentStreak())",
                                    subtitle: "days",
                                    icon: "flame.fill",
                                    color: .orange
                                )

                                StatCard(
                                    title: "Longest Streak",
                                    value: "\(stats.longestStreak())",
                                    subtitle: "days",
                                    icon: "trophy.fill",
                                    color: .yellow
                                )
                            }

                            // Period stats row
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "This Week",
                                    value: "\(stats.thisWeekCount())",
                                    subtitle: "prayers",
                                    icon: "calendar.badge.clock",
                                    color: .green
                                )

                                StatCard(
                                    title: "This Month",
                                    value: "\(stats.thisMonthCount())",
                                    subtitle: "prayers",
                                    icon: "calendar.circle.fill",
                                    color: .indigo
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    // Calendar Page
                    ScrollView {
                        VStack(spacing: 16) {
                            // Month Navigator
                            HStack {
                                Button(action: previousMonth) {
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }

                                Spacer()

                                Text(monthYearString)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)

                                Spacer()

                                Button(action: nextMonth) {
                                    Image(systemName: "chevron.right")
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(.horizontal, 20)

                            // Weekday Headers
                            HStack(spacing: 0) {
                                ForEach(weekdaySymbols, id: \.self) { symbol in
                                    Text(symbol)
                                        .font(.caption.bold())
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)

                            // Calendar Grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                                    if let date = date {
                                        PrayerDayCell(
                                            date: date,
                                            count: stats.entryCount(for: date),
                                            color: color,
                                            isToday: calendar.isDateInToday(date)
                                        )
                                    } else {
                                        Color.clear
                                            .aspectRatio(1, contentMode: .fit)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu("", systemImage: "ellipsis.circle") {
                    
                    //Answered prayer
                    Button(action: { }) {
                        Label("Prayer is answered", systemImage: "hands.and.sparkles.fill")
                    }
                    
                    // Delete Button
                    Button(action: { showingDeleteAlert = true }) {
                        Label("Delete Prayer", systemImage: "trash.fill")
                    }
                }
            }
        }
        .alert("Delete Prayer", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deletePrayer()
            }
        } message: {
            Text("Are you sure you want to delete \n\"\(prayer.title)\"? \nThis will also delete all check-in history.")
        }
    }

    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) else { return }
        selectedMonth = newMonth
    }

    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) else { return }
        selectedMonth = newMonth
    }

    private func deletePrayer() {
        modelContext.delete(prayer)
        dismiss()
    }
}

struct PrayerDayCell: View {
    let date: Date
    let count: Int
    let color: Color
    let isToday: Bool

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func intensityOpacity(for count: Int) -> Double {
        if count == 0 { return 0.15 }
        else if count == 1 { return 0.35 }
        else if count == 2 { return 0.55 }
        else if count <= 4 { return 0.75 }
        else { return 1.0 }
    }

    private var backgroundColor: Color {
        if count > 0 {
            return color.opacity(intensityOpacity(for: count))
        }
        return Color.white.opacity(0.05)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)

            if isToday {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(color, lineWidth: 2)
            }

            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    NavigationStack {
        PrayerDetailView(
            prayer: Prayer(
                title: "Morning Prayer",
                subtitle: "Start the day with a prayer.",
                iconName: "sunrise.fill",
                colorHex: "#9333EA"
            )
        )
    }
    .modelContainer(for: Prayer.self, inMemory: true)
}
