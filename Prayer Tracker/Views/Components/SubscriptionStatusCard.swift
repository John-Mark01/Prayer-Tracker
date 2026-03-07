//
//  SubscriptionStatusCard.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 7.03.26.
//

import SwiftUI

struct SubscriptionStatusCard: View {
    let isProUser: Bool
    let isLoading: Bool
    let onManageSubscription: () -> Void
    let onRestorePurchases: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: isProUser ? "star.circle.fill" : "star.circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isProUser ? .yellow : .white.opacity(0.6))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Prayer Tracker Pro")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(isProUser ? "Active Subscription" : "Not Subscribed")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(isProUser ? .green : .white.opacity(0.6))
                }

                Spacer()
            }

            // Status indicator
            if isProUser {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.green)

                    Text("Thank you for supporting Prayer Tracker!")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.vertical, 8)
            }

            // Action buttons
            VStack(spacing: 12) {
                if isProUser {
                    Button(action: onManageSubscription) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                            Text("Manage Subscription")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .font(.system(size: 12))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                }

                Button(action: onRestorePurchases) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                        Spacer()
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.05))
                    )
                }
                .disabled(isLoading)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        SubscriptionStatusCard(
            isProUser: true,
            isLoading: false,
            onManageSubscription: {},
            onRestorePurchases: {}
        )

        SubscriptionStatusCard(
            isProUser: false,
            isLoading: false,
            onManageSubscription: {},
            onRestorePurchases: {}
        )

        SubscriptionStatusCard(
            isProUser: false,
            isLoading: true,
            onManageSubscription: {},
            onRestorePurchases: {}
        )
    }
    .padding()
    .background(Color(white: 0.05))
}
