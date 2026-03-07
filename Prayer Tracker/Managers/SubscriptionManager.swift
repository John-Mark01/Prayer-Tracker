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

    // Called from customerInfoStream in App
    func update(customerInfo: CustomerInfo) {
        isProUser = customerInfo
            .entitlements
            .active[SubscriptionEntitlements.pro.rawValue]?
            .isActive == true
        
        isProUser ? log("✅ User is subscribed!") : log("❌ User is not subscribed")
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isProUser = customerInfo
                .entitlements
                .active[SubscriptionEntitlements.pro.rawValue]?
                .isActive == true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func log(_ message: String) {
        print("💰 Subscription Manager - \(message, default: "/NULL/")")
    }
}

enum SubscriptionEntitlements: String {
    case pro = "Prayer Tracker Pro"
}
