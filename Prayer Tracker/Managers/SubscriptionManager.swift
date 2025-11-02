//
//  SubscriptionManager.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 2.11.25.
//

import Foundation
import RevenueCat
import RevenueCatUI

@MainActor
@Observable class SubscriptionManager {
    static let shared = SubscriptionManager()

    // MARK: - Properties

    /// Current customer info from RevenueCat
    private(set) var customerInfo: CustomerInfo?

    /// Whether the user has an active premium subscription
    var isPremium: Bool {
        customerInfo?.entitlements.active["premium"]?.isActive == true
    }

    /// Loading state for subscription operations
    private(set) var isLoading = false

    // MARK: - Configuration

    private init() {
        // Private initializer for singleton
    }

    /// Configure RevenueCat SDK
    /// Should be called once during app launch
    /// - Parameter apiKey: Your RevenueCat API key from the dashboard
    func configure(apiKey: String) {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)

        print("✅ RevenueCat configured")

        // Fetch initial customer info
        Task {
            await refreshCustomerInfo()
        }
    }

    // MARK: - Customer Info

    /// Refresh customer info from RevenueCat
    /// Call this whenever you need the latest subscription status
    func refreshCustomerInfo() async {
        do {
            customerInfo = try await Purchases.shared.customerInfo()
            print("✅ Customer info refreshed - isPremium: \(isPremium)")
        } catch {
            print("❌ Error fetching customer info: \(error)")
        }
    }

    // MARK: - Paywall

    /// Present RevenueCat paywall
    /// Returns true if user subscribed, false if dismissed
    @discardableResult
    func presentPaywall() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        // Check if user is already premium
        await refreshCustomerInfo()
        if isPremium {
            print("ℹ️ User is already premium")
            return true
        }

        // Paywall will be presented via SwiftUI view
        // Return false for now - this will be handled by PaywallView
        return false
    }

    // MARK: - Purchases

    /// Purchase a specific package
    func purchase(package: Package) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            customerInfo = result.customerInfo

            if result.userCancelled {
                print("ℹ️ User cancelled purchase")
                return false
            }

            print("✅ Purchase successful - isPremium: \(isPremium)")
            return isPremium
        } catch {
            print("❌ Error making purchase: \(error)")
            return false
        }
    }

    /// Restore previous purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            customerInfo = try await Purchases.shared.restorePurchases()
            print("✅ Purchases restored - isPremium: \(isPremium)")
            return isPremium
        } catch {
            print("❌ Error restoring purchases: \(error)")
            return false
        }
    }

    // MARK: - Offerings

    /// Fetch current offerings from RevenueCat
    func fetchOfferings() async -> Offerings? {
        do {
            let offerings = try await Purchases.shared.offerings()
            print("✅ Offerings fetched: \(offerings.all.count) offering(s)")
            return offerings
        } catch {
            print("❌ Error fetching offerings: \(error)")
            return nil
        }
    }
}
