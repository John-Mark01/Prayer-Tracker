//
//  TodayView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI

struct TodayView: View {
    @Environment(\.appContainer) private var appContainer
    @State private var viewModel: TodayViewModel?
    @State private var showingAddSheet = false
    @State private var selectedPrayer: Prayer?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil, let container = appContainer {
                viewModel = container.makeTodayViewModel()
                await viewModel?.loadPrayers()
            }
        }
    }

    @ViewBuilder
    private func contentView(viewModel: TodayViewModel) -> some View {
        ScrollView {
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 100)
            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundStyle(.red.opacity(0.6))

                    Text("Error")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(error)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 100)
            } else {
                prayersList(viewModel: viewModel)
            }
        }
        .overlay {
            if !viewModel.isLoading && viewModel.prayers.isEmpty {
                emptyStateView
            }
        }
        .background(Color(white: 0.05).ignoresSafeArea())
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showingAddSheet, onDismiss: {
            Task {
                await viewModel.loadPrayers()
            }
        }) {
            AddPrayerSheet()
        }
        .sheet(item: $selectedPrayer) { prayer in
            NavigationStack {
                PrayerDetailView(prayer: prayer)
            }
        }
    }

    @ViewBuilder
    private func prayersList(viewModel: TodayViewModel) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.prayers) { prayer in
                PrayerCardView(
                    prayer: prayer,
                    entries: prayer.entries,
                    todayCount: viewModel.todayCount(for: prayer),
                    onCheckIn: {
                        Task {
                            await viewModel.checkIn(for: prayer)
                        }
                    },
                    onTap: { selectedPrayer = prayer }
                )
            }
        }
        .padding(20)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "hands.sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))

            Text("No prayers yet")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Tap + to add your first prayer")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    let container = AppContainer.build()
    return NavigationStack {
        TodayView()
            .environment(\.appContainer, container)
    }
}
