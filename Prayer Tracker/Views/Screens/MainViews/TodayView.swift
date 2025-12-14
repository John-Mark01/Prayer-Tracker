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
    @Query(sort: \Prayer.sortOrder) private var prayers: [Prayer]
    @Query private var allEntries: [PrayerEntry]

    @State private var showingAddSheet = false
    @State private var selectedPrayer: Prayer?

    private let calendar = Calendar.current

    private func todayEntries(for prayer: Prayer) -> [PrayerEntry] {
        let today = calendar.startOfDay(for: Date())
        return prayer.entries.filter { entry in
            calendar.isDate(entry.timestamp, inSameDayAs: today)
        }
    }

    private func todayCount(for prayer: Prayer) -> Int {
        todayEntries(for: prayer).count
    }

    private func checkIn(for prayer: Prayer) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            let entry = PrayerEntry(timestamp: Date(), prayer: prayer)
            modelContext.insert(entry)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                if prayers.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "hands.sparkles")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.3))

                        Text("No prayers yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Tap + to add your first prayer")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                } else {
                    // Prayer List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(prayers) { prayer in
                                PrayerCardView(
                                    prayer: prayer,
                                    entries: prayer.entries,
                                    todayCount: todayCount(for: prayer),
                                    onCheckIn: { checkIn(for: prayer) },
                                    onTap: { selectedPrayer = prayer }
                                )
                                //TODO: Left here to track colors when needed to copy their HEX Value
//                                .onAppear {
//                                    print("\nPrayer: \(prayer.title) has color: \(prayer.colorHex)")
//                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddPrayerSheet()
            }
            .sheet(item: $selectedPrayer) { prayer in
                NavigationStack {
                    PrayerDetailView(prayer: prayer)
                }
            }
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: Prayer.self, inMemory: true)
}
