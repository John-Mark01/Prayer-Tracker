//
//  CircularProgressView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 1.11.25.
//

import SwiftUI

/// A reusable circular progress ring with smooth animations
struct CircularProgressView: View {
    /// Progress from 0.0 to 1.0
    let progress: Double

    /// Width of the progress ring stroke
    let lineWidth: CGFloat

    /// Color of the progress ring
    let color: Color

    /// Size of the entire view
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background ring (gray)
            Circle()
                .stroke(
                    Color.gray.opacity(0.2),
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)

            // Progress ring
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.linear(duration: 1.0), value: progress)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        CircularProgressView(
            progress: 0.25,
            lineWidth: 20,
            color: .blue,
            size: 200
        )

        CircularProgressView(
            progress: 0.75,
            lineWidth: 15,
            color: .green,
            size: 150
        )

        CircularProgressView(
            progress: 1.0,
            lineWidth: 25,
            color: .purple,
            size: 250
        )
    }
    .padding()
}
