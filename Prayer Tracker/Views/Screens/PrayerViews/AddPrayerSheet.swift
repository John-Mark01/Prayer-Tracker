//
//  AddPrayerSheet.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 28.10.25.
//

import SwiftUI

struct AddPrayerSheet: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddPrayerViewModel?

    @FocusState private var titleIsFocused: Bool
    @FocusState private var subtitleIsFocused: Bool

    private let availableColors: [Color] = [
        .green, .purple, .blue, .orange, .red,
        .pink, .yellow, .cyan, .indigo, .mint
    ]

    var body: some View {
        if let viewModel = appContainer?.addPrayerViewModel {
            contentView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private func contentView(viewModel: AddPrayerViewModel) -> some View {
        NavigationStack {
            ZStack {
                Color(white: 0.05)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Icon Preview
                        ZStack {
                            Circle()
                                .fill(viewModel.selectedColor.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: viewModel.selectedIcon)
                                .font(.system(size: 40))
                                .foregroundStyle(viewModel.selectedColor)
                        }
                        .padding(.top, 20)

                        VStack(spacing: 20) {
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                TextField("e.g., Morning Prayer", text: Binding(
                                    get: { viewModel.title },
                                    set: { viewModel.title = $0 }
                                ))
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($titleIsFocused)
                                    .onTapGesture { titleIsFocused = true }
                            }

                            // Subtitle
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Subtitle (Optional)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                TextField("e.g., Start the day with gratitude", text: Binding(
                                    get: { viewModel.subtitle },
                                    set: { viewModel.subtitle = $0 }
                                ))
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .focused($subtitleIsFocused)
                                    .onTapGesture { subtitleIsFocused = true }
                            }

                            // Icon Selector
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Icon")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.7))

                                Button(action: { viewModel.showingIconPicker = true }) {
                                    HStack {
                                        Image(systemName: viewModel.selectedIcon)
                                            .font(.system(size: 20))
                                            .foregroundStyle(viewModel.selectedColor)

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
                                                isSelected: viewModel.selectedColor == color,
                                                action: { viewModel.selectedColor = color }
                                            )
                                        }

                                        ColorPicker("", selection: Binding(
                                            get: { viewModel.selectedColor },
                                            set: { viewModel.selectedColor = $0 }
                                        ), supportsOpacity: false)
                                            .scaleEffect(CGSize(width: 1.6, height: 1.6))
                                            .labelsHidden()
                                            .padding(.horizontal, 5)

                                    }
                                    .padding(.horizontal, 4)
                                }
                            }

                            // Error Message
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
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
                        Task {
                            let success = await viewModel.savePrayer()
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isValid)
                }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showingIconPicker },
                set: { viewModel.showingIconPicker = $0 }
            )) {
                IconPickerView(selectedIcon: Binding(
                    get: { viewModel.selectedIcon },
                    set: { viewModel.selectedIcon = $0 }
                ))
            }
        }
    }

    private func handleSubmit() {
        if titleIsFocused {
            subtitleIsFocused = true
        }
    }
}

#Preview {
    let container = AppContainer.build()
    return AddPrayerSheet()
        .environment(\.appContainer, container)
}
