//
//  AppGroup.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import Foundation

enum AppGroup {
    static let identifier = "group.com.johnmark.prayertracker"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }

    static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}
