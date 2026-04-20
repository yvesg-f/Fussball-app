import SwiftUI

enum AppRoute: Hashable {
    case setup(teamId: Int)
    case lineup(teamId: Int)
}

struct HomeView: View {
    @ObservedObject var appStore: AppStore
    @State private var path: [AppRoute] = []
    @State private var deleteTarget: Int? = nil

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "soccerball")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    Text("Aufstellung")
                        .font(.largeTitle.bold())
                    Text("Wähle ein Team")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 48)
                .padding(.bottom, 36)

                // 5 team slots
                VStack(spacing: 12) {
                    ForEach(0..<AppStore.maxTeams, id: \.self) { slot in
                        TeamSlotCard(
                            slot: slot,
                            team: appStore.team(for: slot),
                            onOpen:   { path.append(.lineup(teamId: slot)) },
                            onEdit:   { path.append(.setup(teamId: slot)) },
                            onNew:    { path.append(.setup(teamId: slot)) },
                            onDelete: { deleteTarget = slot }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .setup(let id):
                    TeamSetupView(teamId: id, appStore: appStore, path: $path)
                case .lineup(let id):
                    if let team = appStore.team(for: id) {
                        ContentView(team: team, appStore: appStore)
                    }
                }
            }
            .alert("Team löschen?", isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }
            )) {
                Button("Löschen", role: .destructive) {
                    if let s = deleteTarget { appStore.delete(id: s) }
                    deleteTarget = nil
                }
                Button("Abbrechen", role: .cancel) { deleteTarget = nil }
            } message: {
                if let s = deleteTarget, let t = appStore.team(for: s) {
                    Text("\"\(t.name)\" wird gelöscht.")
                }
            }
        }
    }
}

// MARK: - Team slot card

private struct TeamSlotCard: View {
    let slot: Int
    let team: Team?
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onNew: () -> Void
    let onDelete: () -> Void

    var body: some View {
        if let team {
            // Filled slot — open area and action buttons are siblings, not nested
            HStack(spacing: 14) {
                // Tappable info area
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Text(String(team.name.prefix(1)).uppercased())
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(team.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("\(team.playerNames.count) Spieler · \(team.formationRaw)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { onOpen() }

                // Action buttons (separate from open area — no tap conflict)
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 14))

        } else {
            // Empty slot
            Button(action: onNew) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .strokeBorder(.quaternary, lineWidth: 1.5)
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .foregroundStyle(.tertiary)
                    }
                    Text("Neues Team")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Slot \(slot + 1)")
                        .font(.caption)
                        .foregroundStyle(.quaternary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
}
