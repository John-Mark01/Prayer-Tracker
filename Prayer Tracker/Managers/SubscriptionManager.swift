//
//  SubscriptionManager.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 7.03.26.
//

import SwiftUI
import RevenueCat

@Observable
final class SubscriptionManager {

    var showPaywall: Bool = false

    private(set) var isProUser: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var purchasedTips: Set<String> = []

    // Called from customerInfoStream in App
    func update(customerInfo: CustomerInfo) {
        isProUser = customerInfo
            .entitlements
            .active[SubscriptionEntitlements.pro.rawValue]?
            .isActive == true

        // Update purchased tips
        purchasedTips = Set(customerInfo.nonSubscriptions.map { $0.productIdentifier })

        isProUser ? log("✅ User is subscribed!") : log("❌ User is not subscribed")
        if !purchasedTips.isEmpty {
            log("☕️ User has purchased \(purchasedTips.count) tip(s)")
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            update(customerInfo: customerInfo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchaseTip(_ product: StoreProduct) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(product: product)
            update(customerInfo: result.customerInfo)
            log("✅ Tip purchase successful: \(product.productIdentifier)")
            return true
        } catch {
            errorMessage = error.localizedDescription
            log("❌ Tip purchase failed: \(error.localizedDescription)")
            return false
        }
    }

    func hasPurchasedTip(_ productId: String) -> Bool {
        return purchasedTips.contains(productId)
    }

    private func log(_ message: String) {
        print("💰 Subscription Manager - \(message, default: "/NULL/")")
    }
}

enum SubscriptionEntitlements: String {
    case pro = "Prayer Tracker Pro"
}

enum TipJarProducts: String, CaseIterable {
    case smallCoffee = "tip_small_coffee"
    case mediumCoffee = "tip_medium_coffee"
    case largeCoffee = "tip_large_coffee"

    var displayName: String {
        switch self {
        case .smallCoffee: return "Small Coffee"
        case .mediumCoffee: return "Medium Coffee"
        case .largeCoffee: return "Large Coffee"
        }
    }

    var icon: String {
        return "cup.and.saucer.fill"
    }

    var description: String {
        switch self {
        case .smallCoffee: return "Buy me a small coffee"
        case .mediumCoffee: return "Buy me a medium coffee"
        case .largeCoffee: return "Buy me a large coffee"
        }
    }
}
