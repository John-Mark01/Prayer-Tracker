//
//  SettingsScreen.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 7.03.26.
//

import SwiftUI
import StoreKit
import UserNotifications

struct SettingsScreen: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.scenePhase) private var scenePhase

    // Notification Settings
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("prayerRemindersEnabled") private var prayerRemindersEnabled = true
    @AppStorage("warningNotificationsEnabled") private var warningNotificationsEnabled = true


    @State private var showingTipJar = false
    @State private var notificationAuthStatus: UNAuthorizationStatus = .notDetermined
    
    @State private var checkNotificationTask: Task<Void,Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Subscription Status Section
                subscriptionSection

                // Notifications & Reminders Section
                notificationsSection

                // Support Developer Section
                supportDeveloperSection

                // Data & Privacy Section
                dataPrivacySection

                // About Section
                aboutSection

                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .background(Color(white: 0.05).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .sheet(isPresented: $showingTipJar) {
            NavigationStack {
                TipJarView()
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                checkNotificationTask = Task {
                    guard !Task.isCancelled else { return }
                    await checkNotificationStatus()
                }
            }
        }
        .task {
            checkNotificationTask = Task {
                guard !Task.isCancelled else { return }
                await checkNotificationStatus()
            }
        }
        .onDisappear(perform: cancelTasks)
    }

    
    private func cancelTasks() {
        self.checkNotificationTask?.cancel()
        self.checkNotificationTask = nil
    }
    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Subscription")

            SubscriptionStatusCard(
                isProUser: subscriptionManager.isProUser,
                isLoading: subscriptionManager.isLoading,
                onManageSubscription: openManageSubscriptions,
                onRestorePurchases: {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                }
            )
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Notifications & Reminders")

            VStack(spacing: 0) {
                InfoSettingsRow(
                    icon: notificationAuthStatus == .authorized ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
                    title: "Notification Status",
                    value: notificationStatusText,
                    color: notificationAuthStatus == .authorized ? .green : .orange
                )

                if notificationAuthStatus != .authorized {
                    Divider()
                        .background(Color.white.opacity(0.1))
                        .padding(.leading, 52)

                    NavigationSettingsRow(
                        icon: "gear",
                        title: "Open System Settings",
                        subtitle: "Enable notifications for Prayer Tracker",
                        color: .blue,
                        action: openSystemSettings
                    )
                }

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                ToggleSettingsRow(
                    icon: "bell.fill",
                    title: "Prayer Reminders",
                    color: .blue,
                    isOn: $prayerRemindersEnabled,
                    isDisabled: notificationAuthStatus != .authorized
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                ToggleSettingsRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "Warning Notifications",
                    color: .orange,
                    isOn: $warningNotificationsEnabled,
                    isDisabled: notificationAuthStatus != .authorized
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    // MARK: - Support Developer Section

    private var supportDeveloperSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Support Developer")

            VStack(spacing: 0) {
                NavigationSettingsRow(
                    icon: "cup.and.saucer.fill",
                    title: "Tip Jar",
                    subtitle: subscriptionManager.purchasedTips.isEmpty ? "Buy me a coffee" : "Thanks for \(subscriptionManager.purchasedTips.count) tip(s)!",
                    color: .orange,
                    action: { showingTipJar = true }
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "star.fill",
                    title: "Rate Prayer Tracker",
                    subtitle: "Leave a review on the App Store",
                    color: .yellow,
                    action: requestReview
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "square.and.arrow.up.fill",
                    title: "Share Prayer Tracker",
                    subtitle: "Tell your friends about this app",
                    color: .green,
                    action: shareApp
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "ladybug.fill",
                    title: "Report a Bug",
                    subtitle: nil,
                    color: .red,
                    action: reportBug
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "lightbulb.fill",
                    title: "Request a Feature",
                    subtitle: nil,
                    color: .cyan,
                    action: requestFeature
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    // MARK: - Data & Privacy Section

    private var dataPrivacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Data & Privacy")

            VStack(spacing: 0) {
                NavigationSettingsRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: nil,
                    color: .blue,
                    action: openPrivacyPolicy
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    subtitle: nil,
                    color: .purple,
                    action: openTermsOfService
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("About")

            VStack(spacing: 0) {
                InfoSettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    value: appVersion,
                    color: .blue
                )

                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 52)

                NavigationSettingsRow(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    subtitle: nil,
                    color: .green,
                    action: openSupport
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.6))
            .textCase(.uppercase)
            .padding(.horizontal, 4)
    }

    // MARK: - Computed Properties

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var notificationStatusText: String {
        switch notificationAuthStatus {
        case .authorized: return "Enabled"
        case .denied: return "Disabled"
        case .notDetermined: return "Not Set"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }

    // MARK: - Actions

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationAuthStatus = settings.authorizationStatus
        
        
        if notificationAuthStatus == .denied {
            prayerRemindersEnabled = false
            warningNotificationsEnabled = false
        }
    }

    private func openSystemSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func openManageSubscriptions() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                do {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                } catch {
                    print("❌ Failed to show manage subscriptions: \(error)")
                }
            }
        }
    }

    private func openSupport() {
        if let url = URL(string: "mailto:support@prayertracker.com?subject=Prayer%20Tracker%20Support") {
            UIApplication.shared.open(url)
        }
    }

    private func reportBug() {
        if let url = URL(string: "mailto:support@prayertracker.com?subject=Bug%20Report%20-%20Prayer%20Tracker") {
            UIApplication.shared.open(url)
        }
    }

    private func requestFeature() {
        if let url = URL(string: "mailto:support@prayertracker.com?subject=Feature%20Request%20-%20Prayer%20Tracker") {
            UIApplication.shared.open(url)
        }
    }

    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }

    private func shareApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        let appURL = URL(string: "https://apps.apple.com/app/prayer-tracker/idXXXXXXXXXX")! // TODO: Replace with actual App Store URL
        let shareText = "Check out Prayer Tracker - A beautiful way to track your prayer life!"

        let activityVC = UIActivityViewController(
            activityItems: [shareText, appURL],
            applicationActivities: nil
        )

        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
        }

        window.rootViewController?.present(activityVC, animated: true)
    }

    private func openPrivacyPolicy() {
        // TODO: Replace with your actual privacy policy URL
        if let url = URL(string: "https://prayertracker.com/privacy") {
            UIApplication.shared.open(url)
        }
    }

    private func openTermsOfService() {
        // TODO: Replace with your actual terms of service URL
        if let url = URL(string: "https://prayertracker.com/terms") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .environment(SubscriptionManager())
    }
}
