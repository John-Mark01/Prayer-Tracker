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
    let entries: [PrayerEntry]
    let todayCount: Int
    let currentStreak: Int
}

struct PrayerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        PrayerWidgetEntry(date: Date(), entries: [], todayCount: 0, currentStreak: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let entry = createEntry()

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    private func createEntry() -> PrayerWidgetEntry {
        let entries = fetchPrayerEntries()
        let stats = PrayerStatistics(entries: entries)

        return PrayerWidgetEntry(
            date: Date(),
            entries: entries,
            todayCount: stats.todayCount(),
            currentStreak: stats.currentStreak()
        )
    }

    private func fetchPrayerEntries() -> [PrayerEntry] {
        let schema = Schema([PrayerEntry.self, PrayerAlarm.self])

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
            let descriptor = FetchDescriptor<PrayerEntry>(sortBy: [SortDescriptor(\PrayerEntry.timestamp, order: .reverse)])

            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch entries in widget: \(error)")
            return []
        }
    }
}

struct PrayerWidget: Widget {
    let kind: String = "PrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { entry in
            PrayerWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Prayer Tracker")
        .description("Track your daily prayers and streaks")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 3, currentStreak: 7)
}

#Preview(as: .systemMedium) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 3, currentStreak: 7)
}

#Preview(as: .systemLarge) {
    PrayerWidget()
} timeline: {
    PrayerWidgetEntry(date: Date(), entries: [], todayCount: 3, currentStreak: 7)
}
