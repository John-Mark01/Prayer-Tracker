//
//  IconPickerView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)

    private let iconCategories: [(title: String, icons: [String])] = [
        ("Prayer & Religion", [
            "hands.sparkles.fill",
            "hands.clap.fill",
            "book.fill",
            "cross.fill",
            "star.fill",
            "heart.fill"
        ]),
        ("Nature", [
            "leaf.fill",
            "tree.fill",
            "sun.max.fill",
            "moon.stars.fill",
            "cloud.sun.fill",
            "sunrise.fill",
            "sunset.fill",
            "sparkles"
        ]),
        ("Activities", [
            "figure.mind.and.body",
            "figure.walk",
            "figure.run",
            "dumbbell.fill",
            "bed.double.fill",
            "cup.and.saucer.fill",
            "fork.knife",
            "book.pages.fill"
        ]),
        ("Symbols", [
            "flame.fill",
            "bolt.fill",
            "drop.fill",
            "staroflife.fill",
            "infinity",
            "peacesign",
            "crown.fill",
            "shield.fill"
        ]),
        ("Objects", [
            "bell.fill",
            "lightbulb.fill",
            "music.note",
            "headphones",
            "pencil",
            "paintbrush.fill",
            "camera.fill",
            "house.fill"
        ]),
        ("Time", [
            "clock.fill",
            "alarm.fill",
            "timer",
            "hourglass",
            "calendar",
            "sunrise.circle.fill",
            "moon.circle.fill"
        ])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(iconCategories, id: \.title) { category in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(category.title)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 20)

                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(category.icons, id: \.self) { icon in
                                        IconButton(
                                            iconName: icon,
                                            isSelected: selectedIcon == icon,
                                            action: {
                                                selectedIcon = icon
                                                dismiss()
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct IconButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green.opacity(0.3) : Color.white.opacity(0.08))
                    .frame(width: 50, height: 50)

                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.green, lineWidth: 2)
                        .frame(width: 50, height: 50)
                }

                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .green : .white)
            }
        }
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("hands.sparkles.fill"))
}
