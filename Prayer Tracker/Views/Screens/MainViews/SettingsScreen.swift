//
//  SettingsScreen.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 7.03.26.
//

import SwiftUI
import StoreKit

struct SettingsScreen: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Subscription Status Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subscription")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .padding(.horizontal, 4)

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

                // App Information Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "Version",
                            value: appVersion,
                            color: .blue
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 52)

                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Support",
                            color: .green,
                            action: openSupport
                        )

                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 52)

                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate Prayer Tracker",
                            color: .yellow,
                            action: requestReview
                        )
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                    )
                }

                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .background(Color(white: 0.05).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
    }

    // MARK: - Computed Properties

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Actions

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
        // TODO: Replace with your support email
        if let url = URL(string: "mailto:support@prayertracker.com?subject=Prayer%20Tracker%20Support") {
            UIApplication.shared.open(url)
        }
    }

    private func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String?
    let color: Color
    var action: (() -> Void)?

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                } else if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil && value != nil)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .environment(SubscriptionManager())
    }
}
