import SwiftUI

enum AppRoute: Hashable {
    case lineup(lineupIndex: Int)
}

struct HomeView: View {
    @ObservedObject var appStore: AppStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject private var settings: AppSettings
    @State private var path: [AppRoute] = []
    @State private var showSetup = false
    @State private var showAddLineup = false
    @State private var showUpgrade = false
    @State private var showSettings = false
    @State private var deleteLineupIndex: Int? = nil
    @State private var renameLineupIndex: Int? = nil
    @State private var renameName = ""

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
            .sheet(isPresented: $showUpgrade) {
                ProUpgradeView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert(settings.t("delete_lineup_title"), isPresented: Binding(
                get: { deleteLineupIndex != nil },
                set: { if !$0 { deleteLineupIndex = nil } }
            )) {
                Button(settings.t("delete"), role: .destructive) {
                    if let i = deleteLineupIndex { appStore.deleteLineup(at: i) }
                    deleteLineupIndex = nil
                }
                Button(settings.t("cancel"), role: .cancel) { deleteLineupIndex = nil }
            } message: {
                if let i = deleteLineupIndex, let t = appStore.team, i < t.lineups.count {
                    Text(String(format: settings.t("delete_lineup_message"), t.lineups[i].name))
                }
            }
            .alert(settings.t("rename_title"), isPresented: Binding(
                get: { renameLineupIndex != nil },
                set: { if !$0 { renameLineupIndex = nil } }
            )) {
                TextField(settings.t("name"), text: $renameName)
                Button(settings.t("rename")) {
                    let n = renameName.trimmingCharacters(in: .whitespaces)
                    if let i = renameLineupIndex, !n.isEmpty {
                        appStore.renameLineup(at: i, name: n)
                    }
                    renameLineupIndex = nil
                }
                Button(settings.t("cancel"), role: .cancel) { renameLineupIndex = nil }
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
                Text(appStore.team?.name ?? settings.t("lineup"))
                    .font(.title2.bold())
                if let team = appStore.team {
                    Text(String(format: settings.t("players_lineups"),
                                team.playerNames.count, team.lineups.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Color(.secondarySystemFill), in: Circle())
            }
            .buttonStyle(.plain)

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
                        onRename: { renameName = team.lineups[i].name; renameLineupIndex = i },
                        onDelete: { deleteLineupIndex = i }
                    )
                }

                Button {
                    if purchaseManager.isPro || team.lineups.count < PurchaseManager.freeLineupLimit {
                        showAddLineup = true
                    } else {
                        showUpgrade = true
                    }
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .strokeBorder(.quaternary, lineWidth: 1.5)
                                .frame(width: 40, height: 40)
                            Image(systemName: "plus")
                                .foregroundStyle(.tertiary)
                        }
                        Text(settings.t("new_lineup"))
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
            Text(settings.t("no_players_title"))
                .font(.headline)
            Text(settings.t("no_players_message"))
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
    @EnvironmentObject private var settings: AppSettings
    let lineup: SavedLineup
    let canDelete: Bool
    let onOpen: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    private var placedCount: Int { lineup.lineup.values.count }

    var body: some View {
        HStack(spacing: 8) {
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
                    Text(String(format: settings.t("formation_placed"),
                                lineup.formationRaw, placedCount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture { onOpen() }

            Button(action: onRename) {
                Image(systemName: "pencil")
                    .foregroundStyle(.secondary)
                    .padding(10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

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
    @EnvironmentObject private var settings: AppSettings
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
                Section(settings.t("lineup_name_section")) {
                    TextField(settings.t("lineup_name_placeholder"), text: $name)
                }
            }
            .navigationTitle(settings.t("new_lineup"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.t("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.t("add")) {
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
