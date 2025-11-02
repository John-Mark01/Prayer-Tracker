//
//  WidgetPrayerConfiguration.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 01.11.25.
//

import AppIntents
import SwiftData
import Foundation

// AppEntity representing a prayer for widget configuration
struct WidgetPrayerEntity: AppEntity {
    var id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var colorHex: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Prayer"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: subtitle.isEmpty ? nil : "\(subtitle)"
        )
    }

    static var defaultQuery = WidgetPrayerEntityQuery()
}

// Query to fetch available prayers
struct WidgetPrayerEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [WidgetPrayerEntity] {
        let prayers = fetchPrayers()
        return prayers.filter { identifiers.contains($0.id) }
            .map { WidgetPrayerEntity(id: $0.id, title: $0.title, subtitle: $0.subtitle, iconName: $0.iconName, colorHex: $0.colorHex) }
    }

    func suggestedEntities() async throws -> [WidgetPrayerEntity] {
        let prayers = fetchPrayers()
        return prayers.map { WidgetPrayerEntity(id: $0.id, title: $0.title, subtitle: $0.subtitle, iconName: $0.iconName, colorHex: $0.colorHex) }
    }

    private func fetchPrayers() -> [Prayer] {
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
            let descriptor = FetchDescriptor<Prayer>(sortBy: [SortDescriptor(\Prayer.sortOrder)])

            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch prayers for widget configuration: \(error)")
            return []
        }
    }
}

// Configuration intent for widget
struct WidgetPrayerConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Prayer"
    static var description = IntentDescription("Choose which prayer to track in the widget")

    @Parameter(title: "Prayer")
    var prayer: WidgetPrayerEntity?
}
