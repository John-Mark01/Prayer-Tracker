//
//  AlarmsView.swift
//  Prayer Tracker
//
//  Created by John-Mark Iliev on 27.10.25.
//

import SwiftUI

struct AlarmsView: View {
    @Environment(\.appContainer) private var appContainer
    @State private var showingAddAlarm = false
    @State private var showingDebug = false

    var body: some View {
        if let viewModel = appContainer?.alarmsViewModel {
            contentView(viewModel: viewModel)
                .task { await viewModel.loadData() }
        }
    }

    @ViewBuilder
    private func contentView(viewModel: AlarmsViewModel) -> some View {
        List {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(Array(viewModel.groupedAlarms.enumerated()), id: \.offset) { _, group in
                    Section {
                        ForEach(group.alarms) { alarm in
                            AlarmRow(
                                alarm: alarm,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleAlarm(alarm)
                                    }
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.deleteAlarms(at: offsets, from: group.alarms)
                            }
                        }
                    } header: {
                        if let prayer = group.prayer {
                            HStack(spacing: 8) {
                                Image(systemName: prayer.iconName)
                                    .foregroundStyle(Color(hex: prayer.colorHex))
                                Text(prayer.title)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white)
                            .textCase(nil)
                        } else {
                            Text("Other Alarms")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .textCase(nil)
                        }
                    }
                }
            }
        }
        .overlay {
            if !viewModel.isLoading && viewModel.alarms.isEmpty {
                emptyStateView
            }
        }
        .background(Color.white.opacity(0.05).ignoresSafeArea())
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .navigationTitle("Prayer Alarms")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
#if DEBUG
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { showingDebug = true }) {
                    Image(systemName: "ladybug.fill")
                        .foregroundStyle(.orange)
                }
            }
#endif

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddAlarm = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAlarm, onDismiss: {
            Task {
                await viewModel.loadData()
            }
        }) {
            AddAlarmView()
        }
        .sheet(isPresented: $showingDebug) {
            LiveActivityDebugView()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))

            Text("No Prayer Alarms")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("Create an alarm to get reminded when it's time to pray")
                .font(.body)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    let container = AppContainer.build()
    return NavigationStack {
        AlarmsView()
            .environment(\.appContainer, container)
    }
}
