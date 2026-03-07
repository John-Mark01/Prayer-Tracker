//
//  Prayer_TrackerApp.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI
import SwiftData
import RevenueCat
import RevenueCatUI

@main
struct Prayer_TrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @State private var notificationDelegate = NotificationDelegate()
    @State private var activePrayerState = ActivePrayerState()
    @State private var localPersistanceContainer = PrayerDataManager.shared.container
    @State private var subscriptionManager = SubscriptionManager()
    

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        notificationDelegate.activePrayerState = _activePrayerState.wrappedValue
        
        //RevenueCat
        Purchases.configure(withAPIKey: "test_vxPwddDJsnnyVecrDVDLDrpxQRN")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    TabBarScreen()
                } else {
                    OnboardingView(
                        hasCompletedOnboarding: $hasCompletedOnboarding
                    )
                }
            }
            .tint(.appTint)
            .environment(activePrayerState)
            .environment(subscriptionManager)
            .onOpenURL { handleURL($0) }
            .animation(.easeInOut, value: hasCompletedOnboarding)
            .task {
//                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                for await customerInfo in Purchases.shared.customerInfoStream {
                    subscriptionManager.update(customerInfo: customerInfo)
                }
            }
            .sheet(isPresented: Binding(
                get: { subscriptionManager.showPaywall },
                set: { subscriptionManager.showPaywall = $0 })
            
            ) {
                PaywallView()
                    .onPurchaseCompleted { customerInfo in
                        subscriptionManager.update(customerInfo: customerInfo)
                        subscriptionManager.showPaywall = false
                        hasCompletedOnboarding = true
                    }
                    .onRestoreCompleted { customerInfo in
                        subscriptionManager.update(customerInfo: customerInfo)
                        subscriptionManager.showPaywall = false
                        hasCompletedOnboarding = true
                    }
            }
        }
        .modelContainer(localPersistanceContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Process pending operations when app becomes active
                Task {
                    guard !Task.isCancelled else { return }
                    await processPendingOperations()
                }
            }
        }
    }

// MARK: - URL Handling

    private func handleURL(_ url: URL) {
        print("🔗 Received URL: \(url.absoluteString)")

        if url.scheme == "prayertracker" {
            if url.host == "process-checkins" || url.path.contains("process-checkins") {
                print("✅ Processing operations from URL scheme")
                Task {
                    await processPendingOperations()
                }
            }
        }
    }

// MARK: - Operation Processing

    @MainActor
    func processPendingOperations() async {
        print("🔄 Processing all pending operations from Live Activities")

        // Process Live Activity operations
        await processStartPrayerOperations()
        await processCheckInOperations()
    }

// MARK: - Start Prayer Operations

    @MainActor
    private func processStartPrayerOperations() async {
        let queue = OperationQueue.getQueue(PendingStartPrayer.self, key: .startPrayers)

        guard !queue.isEmpty else {
            print("ℹ️ No pending start prayer operations")
            return
        }

        print("📝 Processing \(queue.count) start prayer operation(s)")

        for operation in queue {
            print("🎬 Starting prayer countdown for activity: \(operation.activityID)")

            // Start the Live Activity countdown
            await LiveActivityManager.shared.startPrayerCountdown(activityID: operation.activityID)

            // Start the in-app countdown if modal is showing
            if activePrayerState.activityID == operation.activityID && activePrayerState.isReady {
                print("▶️ Starting in-app countdown...")
                activePrayerState.beginCountdown()
                print("✅ In-app timer also started")
            } else {
                print("ℹ️ In-app timer not in ready state or different activity")
            }
        }

        OperationQueue.clearQueue(key: .startPrayers)
        print("✅ Processed all start prayer operations")
    }

// MARK: - Check-In Operations (from Live Activities)

    @MainActor
    private func processCheckInOperations() async {
        let queue = OperationQueue.getQueue(PendingCheckIn.self, key: .checkIns)

        guard !queue.isEmpty else {
            print("ℹ️ No pending check-in operations")
            return
        }

        print("📝 Processing \(queue.count) check-in operation(s)")

        let context = localPersistanceContainer.mainContext
        var checkedInActivityIDs: [String] = []

        for operation in queue {
            // Find the prayer
            var prayer: Prayer? = nil
            if let uuid = UUID(uuidString: operation.prayerID) {
                let descriptor = FetchDescriptor<Prayer>(
                    predicate: #Predicate { $0.id == uuid }
                )
                prayer = try? context.fetch(descriptor).first
            }

            // Create the prayer entry
            let entry = PrayerEntry(timestamp: operation.timestamp, prayer: prayer)
            context.insert(entry)

            if let prayer = prayer {
                print("✅ Created check-in for: \(prayer.title)")
            } else {
                print("✅ Created generic check-in")
            }

            // Track activity IDs that were checked in
            checkedInActivityIDs.append(operation.activityID)

            // End the Live Activity
            await LiveActivityManager.shared.endActivity(activityID: operation.activityID)
        }

        // Save all entries
        do {
            try context.save()
            print("✅ Saved all check-ins to database")
        } catch {
            print("❌ Failed to save check-ins: \(error)")
        }

        OperationQueue.clearQueue(key: .checkIns)

        // If the current in-app prayer session was checked in from Live Activity, dismiss it
        if let currentActivityID = activePrayerState.activityID,
           checkedInActivityIDs.contains(currentActivityID) {
            print("🚪 Check-in was for current in-app session - dismissing modal")
            activePrayerState.reset()
        }
    }

}
