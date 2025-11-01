//
//  AddPrayerSheet.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI
import SwiftData

struct AddPrayerSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allPrayers: [Prayer]
    
    @FocusState private var titleIsFocused: Bool
    @FocusState private var subtitleIsFocused: Bool

    @State private var title = ""
    @State private var subtitle = ""
    @State private var selectedIcon = "hands.sparkles.fill"
    @State private var selectedColor = Color.green
    @State private var showingIconPicker = false

    private let availableColors: [Color] = [
        .green, .purple, .blue, .orange, .red,
        .pink, .yellow, .cyan, .indigo, .mint
    ]

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Icon Preview
                        ZStack {
                            Circle()
                                .fill(selectedColor.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: selectedIcon)
                                .font(.system(size: 40))
                                .foregroundStyle(selectedColor)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 20) {
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                TextField("e.g., Morning Prayer", text: $title)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($titleIsFocused)
                                    .onTapGesture { titleIsFocused = true }
                            }

                            // Subtitle
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subtitle (Optional)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                TextField("e.g., Start the day with gratitude", text: $subtitle)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($subtitleIsFocused)
                                    .onTapGesture { subtitleIsFocused = true }
                            }

                            // Icon Selector
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Icon")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                Button(action: { showingIconPicker = true }) {
                                    HStack {
                                        Image(systemName: selectedIcon)
                                            .font(.system(size: 20))
                                            .foregroundStyle(selectedColor)

                                        Text("Choose Icon")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white.opacity(0.5))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.08))
                                    )
                                }
                            }

                            // Color Selector
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Color")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        
                                        ForEach(availableColors, id: \.description) { color in
                                            ColorButton(
                                                color: color,
                                                isSelected: selectedColor == color,
                                                action: { selectedColor = color }
                                            )
                                        }
                                        
                                        ColorPicker("",selection: $selectedColor)
                                            .scaleEffect(CGSize(width: 1.6, height: 1.6))
                                            .labelsHidden()
                                            .padding(.horizontal, 5)
                                        
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
            }
            .onSubmit { handleSubmit() }
            .navigationTitle("New Prayer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePrayer()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
        }
    }

    private func savePrayer() {
        let maxSortOrder = allPrayers.map(\.sortOrder).max() ?? -1
        let prayer = Prayer(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            subtitle: subtitle.trimmingCharacters(in: .whitespacesAndNewlines),
            iconName: selectedIcon,
            colorHex: selectedColor.toHex() ?? "#9333EA",
            sortOrder: maxSortOrder + 1
        )
        modelContext.insert(prayer)
        dismiss()
    }
    
    private func handleSubmit() {
        Task {
            await MainActor.run {
                if titleIsFocused {
                    subtitleIsFocused = true
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.08))
            )
    }
}

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .strokeBorder(.white, lineWidth: 3)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }
}

#Preview {
    AddPrayerSheet()
        .modelContainer(for: Prayer.self, inMemory: true)
}
