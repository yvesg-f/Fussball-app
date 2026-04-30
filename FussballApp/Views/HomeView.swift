import SwiftUI

enum AppRoute: Hashable {
    case lineup(lineupIndex: Int)
}

struct HomeView: View {
    @ObservedObject var appStore: AppStore
    @State private var path: [AppRoute] = []
    @State private var showSetup = false
    @State private var showAddLineup = false
    @State private var deleteLineupIndex: Int? = nil

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                headerView

                if let team = appStore.team {
                    teamContent(team: team)
                } else {
                    emptyState
                }

                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .lineup(let index):
                    if let team = appStore.team {
                        ContentView(team: team, lineupIndex: index, appStore: appStore)
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                TeamSetupView(appStore: appStore)
            }
            .sheet(isPresented: $showAddLineup) {
                AddLineupSheet(appStore: appStore)
            }
            .alert("Aufstellung löschen?", isPresented: Binding(
                get: { deleteLineupIndex != nil },
                set: { if !$0 { deleteLineupIndex = nil } }
            )) {
                Button("Löschen", role: .destructive) {
                    if let i = deleteLineupIndex { appStore.deleteLineup(at: i) }
                    deleteLineupIndex = nil
                }
                Button("Abbrechen", role: .cancel) { deleteLineupIndex = nil }
            } message: {
                if let i = deleteLineupIndex, let t = appStore.team, i < t.lineups.count {
                    Text("\"\(t.lineups[i].name)\" wird gelöscht.")
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "soccerball")
                .font(.system(size: 32))
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(appStore.team?.name ?? "Aufstellung")
                    .font(.title2.bold())
                if let team = appStore.team {
                    Text("\(team.playerNames.count) Spieler · \(team.lineups.count) Aufstellungen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { showSetup = true } label: {
                Image(systemName: appStore.team == nil ? "person.badge.plus" : "person.crop.circle.badge.checkmark")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
                    .padding(8)
                    .background(Color.green.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.top, 28)
        .padding(.bottom, 16)
    }

    // MARK: - Team content

    @ViewBuilder
    private func teamContent(team: Team) -> some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(team.lineups.indices, id: \.self) { i in
                    LineupCard(
                        lineup: team.lineups[i],
                        canDelete: team.lineups.count > 1,
                        onOpen:   { path.append(.lineup(lineupIndex: i)) },
                        onDelete: { deleteLineupIndex = i }
                    )
                }

                // New lineup button
                Button { showAddLineup = true } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .strokeBorder(.quaternary, lineWidth: 1.5)
                                .frame(width: 40, height: 40)
                            Image(systemName: "plus")
                                .foregroundStyle(.tertiary)
                        }
                        Text("Neue Aufstellung")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("Noch keine Spieler")
                .font(.headline)
            Text("Tippe auf das Icon oben rechts um dein Team zu erstellen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
        .padding(.horizontal, 32)
    }
}

// MARK: - Lineup card

private struct LineupCard: View {
    let lineup: SavedLineup
    let canDelete: Bool
    let onOpen: () -> Void
    let onDelete: () -> Void

    private var placedCount: Int { lineup.lineup.values.count }

    var body: some View {
        HStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(lineup.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(lineup.formationRaw) · \(placedCount)/11 eingesetzt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { onOpen() }

            if canDelete {
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground),
                    in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Add lineup sheet

private struct AddLineupSheet: View {
    let appStore: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    private var suggestedName: String {
        let count = appStore.team?.lineups.count ?? 0
        if count < 26 {
            return "Plan \(String(UnicodeScalar(65 + count)!))"
        }
        return "Plan \(count + 1)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name der Aufstellung") {
                    TextField("z.B. Plan C", text: $name)
                }
            }
            .navigationTitle("Neue Aufstellung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        let n = name.trimmingCharacters(in: .whitespaces)
                        appStore.addLineup(name: n.isEmpty ? suggestedName : n)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear { name = suggestedName }
    }
}
