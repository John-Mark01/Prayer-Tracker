//
//  WidgetsBundle.swift
//  Widgets
//
//  Created by John-Mark Iliev on 27.10.25.
//

import WidgetKit
import SwiftUI

@main
struct WidgetsBundle: WidgetBundle {
    var body: some Widget {
        Widgets()
        WidgetsControl()
        WidgetsLiveActivity()
    }
}
