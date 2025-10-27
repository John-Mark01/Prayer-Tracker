//
//  PrayerWidgetsLiveActivity.swift
//  PrayerWidgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PrayerWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PrayerWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PrayerWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PrayerWidgetsAttributes {
    fileprivate static var preview: PrayerWidgetsAttributes {
        PrayerWidgetsAttributes(name: "World")
    }
}

extension PrayerWidgetsAttributes.ContentState {
    fileprivate static var smiley: PrayerWidgetsAttributes.ContentState {
        PrayerWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PrayerWidgetsAttributes.ContentState {
         PrayerWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PrayerWidgetsAttributes.preview) {
   PrayerWidgetsLiveActivity()
} contentStates: {
    PrayerWidgetsAttributes.ContentState.smiley
    PrayerWidgetsAttributes.ContentState.starEyes
}
