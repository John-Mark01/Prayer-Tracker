//
//  TipJarView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 7.03.26.
//

import SwiftUI
import RevenueCat

struct TipJarView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss

    @State private var offerings: Offerings?
    @State private var isLoadingProducts = true
    @State private var showThankYou = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .brown],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Support Development")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Your support helps keep Prayer Tracker free and ad-free for everyone!")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)

                // Tip Options
                if isLoadingProducts {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(TipJarProducts.allCases, id: \.self) { tip in
                            TipOptionCard(
                                tip: tip,
                                product: getProduct(for: tip),
                                isPurchased: subscriptionManager.hasPurchasedTip(tip.rawValue),
                                onPurchase: {
                                    Task {
                                        await purchaseTip(tip)
                                    }
                                }
                            )
                        }
                    }
                }

                // Thank you message
                if !subscriptionManager.purchasedTips.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.pink)

                        Text("Thank you for your support!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("You've supported the development \(subscriptionManager.purchasedTips.count) time(s)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 20)
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(Color(white: 0.05).ignoresSafeArea())
        .navigationTitle("Tip Jar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
        .task {
            await loadProducts()
        }
        .alert("Thank You! ❤️", isPresented: $showThankYou) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your support means the world! Thank you for helping keep Prayer Tracker free for everyone.")
        }
    }

    // MARK: - Functions

    private func loadProducts() async {
        do {
            offerings = try await Purchases.shared.offerings()
            isLoadingProducts = false
        } catch {
            print("❌ Failed to load offerings: \(error)")
            isLoadingProducts = false
        }
    }

    private func getProduct(for tip: TipJarProducts) -> StoreProduct? {
        // Try to get from current offering or available packages
        return offerings?.current?.availablePackages.first(where: {
            $0.storeProduct.productIdentifier == tip.rawValue
        })?.storeProduct
    }

    private func purchaseTip(_ tip: TipJarProducts) async {
        guard let product = getProduct(for: tip) else {
            print("❌ Product not found for tip: \(tip.rawValue)")
            return
        }

        let success = await subscriptionManager.purchaseTip(product)
        if success {
            showThankYou = true
        }
    }
}

// MARK: - Tip Option Card

struct TipOptionCard: View {
    let tip: TipJarProducts
    let product: StoreProduct?
    let isPurchased: Bool
    let onPurchase: () -> Void

    var body: some View {
        Button(action: {
            if !isPurchased {
                onPurchase()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: tip.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.orange.opacity(0.15))
                    )

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(tip.displayName)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(tip.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Price or Purchased
                if isPurchased {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.green)
                } else if let product = product {
                    Text(product.localizedPriceString)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.orange)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isPurchased ? 0.05 : 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isPurchased ? Color.green.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isPurchased || product == nil)
    }
}

#Preview {
    NavigationStack {
        TipJarView()
            .environment(SubscriptionManager())
    }
}
