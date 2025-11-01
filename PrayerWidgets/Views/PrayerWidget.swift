//
//  PrayerWidget.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let prayer: WidgetPrayerEntity?
    let entries: [PrayerEntry]
    let todayCount: Int
    let currentStreak: Int
}

struct PrayerWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        PrayerWidgetEntry(date: Date(), prayer: nil, entries: [], todayCount: 0, currentStreak: 0)
    }

    func snapshot(for configuration: WidgetPrayerConfigurationIntent, in context: Context) async -> PrayerWidgetEntry {
        return createEntry(for: configuration)
    }

    func timeline(for configuration: WidgetPrayerConfigurationIntent, in context: Context) async -> Timeline<PrayerWidgetEntry> {
        let entry = createEntry(for: configuration)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        return timeline
    }

    private func createEntry(for configuration: WidgetPrayerConfigurationIntent) -> PrayerWidgetEntry {
        guard let selectedPrayer = configuration.prayer else {
            // If no prayer is selected, return empty entry
            return PrayerWidgetEntry(
                date: Date(),
                prayer: nil,
                entries: [],
                todayCount: 0,
                currentStreak: 0
            )
        }

        let entries = fetchPrayerEntries(for: selectedPrayer.id)
        let stats = PrayerStatistics(entries: entries)

        return PrayerWidgetEntry(
            date: Date(),
            prayer: selectedPrayer,
            entries: entries,
            todayCount: stats.todayCount(),
            currentStreak: stats.currentStreak()
        )
    }

    private func fetchPrayerEntries(for prayerId: UUID) -> [PrayerEntry] {
        let schema = Schema([Prayer.self, PrayerEntry.self, PrayerAlarm.self])

        do {
            let container: ModelContainer

            if let appGroupURL = AppGroup.containerURL {
                let storeURL = appGroupURL.appendingPathComponent("PrayerTracker.sqlite")
                let config = ModelConfiguration(url: storeURL)
                container = try ModelContainer(for: schema, configurations: [config])
            } else {
                container = try ModelContainer(for: schema)
            }

            let context = ModelContext(container)

            // Fetch entries for this prayer
            let entriesDescriptor = FetchDescriptor<PrayerEntry>(
                predicate: #Predicate<PrayerEntry> { entry in
                    entry.prayer?.id == prayerId
                },
                sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)]
            )

            return try context.fetch(entriesDescriptor)
        } catch {
            print("Failed to fetch entries in widget: \(error)")
            return []
        }
    }
}

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: WidgetPrayerConfigurationIntent.self, provider: PrayerWidgetProvider()) { entry in
            
            let color = if let colorHex = entry.prayer?.colorHex {
                Color(hex: colorHex)
            } else {
                Color(hex: "#FAFAFA")
            }

            PrayerWidgetView(entry: entry)
                .containerRelativeFrame(.vertical)
                .containerRelativeFrame(.horizontal)
                .containerBackground(Color.widgetBackground, for: .widget)
            
        }
        .configurationDisplayName("Prayer Tracker")
        .description("Track your daily prayers and streaks")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PrayerWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrayerWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallPrayerWidget(entry: entry)
        case .systemMedium:
            MediumPrayerWidget(entry: entry)
        case .systemLarge:
            LargePrayerWidget(entry: entry)
        default:
            SmallPrayerWidget(entry: entry)
        }
    }
}

#Preview(as: .systemSmall) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(
        date: Date(),
        prayer: WidgetPrayerEntity(
            id: UUID(),
            title: "Read",
            subtitle: "Daily scripture reading",
            iconName: "book.fill",
            colorHex: "#9333EA"
        ),
        entries: [],
        todayCount: 3,
        currentStreak: 7
    )
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(
        date: Date(),
        prayer: WidgetPrayerEntity(
            id: UUID(),
            title: "Read",
            subtitle: "Daily scripture reading",
            iconName: "book.fill",
            colorHex: "#9333EA"
        ),
        entries: [],
        todayCount: 3,
        currentStreak: 7
    )
}
