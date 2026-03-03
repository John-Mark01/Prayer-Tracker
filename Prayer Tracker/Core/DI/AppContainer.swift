//
//  AppContainer.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 3.3.26.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class AppContainer {
    // MARK: - Core
    let modelContainer: ModelContainer
    let localPersistanceContainer: LocalPersistanceContainer

    // MARK: - Repositories
    let prayerRepository: PrayerRepositoryProtocol
    let alarmRepository: AlarmRepositoryProtocol
    let entryRepository: EntryRepositoryProtocol

    // MARK: - Services
    let prayerService: PrayerServiceProtocol
    let alarmService: AlarmServiceProtocol
    let notificationService: NotificationServiceProtocol
    let liveActivityService: LiveActivityServiceProtocol
    let calendarService: CalendarServiceProtocol

    // MARK: - Shared State
    let activePrayerState: ActivePrayerState
    let notificationDelegate: NotificationDelegate

    // MARK: - Initialization

    private init(
        modelContainer: ModelContainer,
        localPersistanceContainer: LocalPersistanceContainer,
        prayerRepository: PrayerRepositoryProtocol,
        alarmRepository: AlarmRepositoryProtocol,
        entryRepository: EntryRepositoryProtocol,
        prayerService: PrayerServiceProtocol,
        alarmService: AlarmServiceProtocol,
        notificationService: NotificationServiceProtocol,
        liveActivityService: LiveActivityServiceProtocol,
        calendarService: CalendarServiceProtocol,
        activePrayerState: ActivePrayerState,
        notificationDelegate: NotificationDelegate
    ) {
        self.modelContainer = modelContainer
        self.localPersistanceContainer = localPersistanceContainer
        self.prayerRepository = prayerRepository
        self.alarmRepository = alarmRepository
        self.entryRepository = entryRepository
        self.prayerService = prayerService
        self.alarmService = alarmService
        self.notificationService = notificationService
        self.liveActivityService = liveActivityService
        self.calendarService = calendarService
        self.activePrayerState = activePrayerState
        self.notificationDelegate = notificationDelegate
    }

    // MARK: - Factory Method

    static func build() -> AppContainer {
        // Create persistence layer
        let persistanceContainer = LocalPersistanceContainer()
        let modelContainer = persistanceContainer.sharedModelContainer

        // Create repositories (actor-isolated)
        let prayerRepo = PrayerRepository(modelContainer: modelContainer)
        let alarmRepo = AlarmRepository(modelContainer: modelContainer)
        let entryRepo = EntryRepository(modelContainer: modelContainer)

        // Create infrastructure services (adapters around existing managers)
        let notificationService = NotificationService()
        let liveActivityService = LiveActivityService()
        let calendarService = CalendarService()

        // Create business logic services (depend on repositories and infrastructure)
        let prayerService = PrayerService(
            prayerRepository: prayerRepo,
            entryRepository: entryRepo
        )

        let alarmService = AlarmService(
            alarmRepository: alarmRepo,
            notificationService: notificationService,
            liveActivityService: liveActivityService,
            calendarService: calendarService
        )

        // Create shared state
        let activePrayerState = ActivePrayerState()
        let notificationDelegate = NotificationDelegate()

        // Wire up notification delegate dependencies
        notificationDelegate.activePrayerState = activePrayerState

        return AppContainer(
            modelContainer: modelContainer,
            localPersistanceContainer: persistanceContainer,
            prayerRepository: prayerRepo,
            alarmRepository: alarmRepo,
            entryRepository: entryRepo,
            prayerService: prayerService,
            alarmService: alarmService,
            notificationService: notificationService,
            liveActivityService: liveActivityService,
            calendarService: calendarService,
            activePrayerState: activePrayerState,
            notificationDelegate: notificationDelegate
        )
    }

// MARK: - ViewModels
    
    lazy var todayViewModel: TodayViewModel = {
        TodayViewModel(prayerService: prayerService)
    }()

    lazy var alarmsViewModel: AlarmsViewModel = {
        AlarmsViewModel(
            alarmService: alarmService,
            prayerService: prayerService
        )
    }()
    
    lazy var addPrayerViewModel: AddPrayerViewModel = {
        AddPrayerViewModel(prayerService: prayerService)
    }()
}

// MARK: - Environment Key

private struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer? = nil
}

extension EnvironmentValues {
    var appContainer: AppContainer? {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}
