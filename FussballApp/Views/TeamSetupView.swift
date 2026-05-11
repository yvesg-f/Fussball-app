import SwiftUI

private struct PlayerEntry: Identifiable {
    var id = UUID()
    var name: String
}

struct TeamSetupView: View {
    let appStore: AppStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var teamName: String
    @State private var players: [PlayerEntry]
    @State private var newPlayer: String = ""
    @State private var showDuplicateAlert = false
    @FocusState private var newPlayerFocused: Bool

    private var canSave: Bool {
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty && !players.isEmpty
    }

    init(appStore: AppStore) {
        self.appStore = appStore
        let existing = appStore.team
        self._teamName = State(initialValue: existing?.name ?? "")
        self._players = State(initialValue: existing?.playerNames.map { PlayerEntry(name: $0) } ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(settings.t("team_name")) {
                    TextField(settings.t("team_name_placeholder"), text: $teamName)
                }

                Section {
                    ForEach($players) { $player in
                        TextField(settings.t("player_name_placeholder"), text: $player.name)
                    }
                    .onDelete { players.remove(atOffsets: $0) }

                    if players.count < 35 {
                        HStack {
                            TextField(settings.t("add_name_placeholder"), text: $newPlayer)
                                .focused($newPlayerFocused)
                                .onSubmit { addPlayer() }
                            Button(settings.t("add")) { addPlayer() }
                                .disabled(newPlayer.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                } header: {
                    HStack {
                        Text(String(format: settings.t("players_count"), players.count))
                        Spacer()
                        if !players.isEmpty {
                            EditButton()
                                .font(.caption)
                        }
                    }
                } footer: {
                    if players.isEmpty {
                        Text(settings.t("at_least_one_player"))
                            .foregroundStyle(.red)
                    }
                }
            }
            .alert(settings.t("duplicate_player_title"), isPresented: $showDuplicateAlert) {
                Button(settings.t("ok"), role: .cancel) {}
            } message: {
                Text(settings.t("duplicate_player_message"))
            }
            .navigationTitle(appStore.team == nil ? settings.t("new_team") : settings.t("edit_team"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.t("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(settings.t("save")) { save() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addPlayer() {
        let name = newPlayer.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, players.count < 35 else { return }
        let isDuplicate = players.contains {
            $0.name.trimmingCharacters(in: .whitespaces).lowercased() == name.lowercased()
        }
        guard !isDuplicate else { showDuplicateAlert = true; return }
        players.append(PlayerEntry(name: name))
        newPlayer = ""
        newPlayerFocused = true
    }

    private func save() {
        var team = appStore.team ?? Team(id: 0, name: "")
        team.name = teamName.trimmingCharacters(in: .whitespaces)
        team.playerNames = players.map { $0.name }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let validNames = Set(team.playerNames)
        for i in team.lineups.indices {
            team.lineups[i].lineup = team.lineups[i].lineup.filter { validNames.contains($0.value) }
            let validSlots = Set(team.lineups[i].lineup.keys)
            team.lineups[i].slotPositions = team.lineups[i].slotPositions.filter { validSlots.contains($0.key) }
            team.lineups[i].benchPlayerNames = team.lineups[i].benchPlayerNames.filter { validNames.contains($0) }
        }
        team.captainName = validNames.contains(team.captainName ?? "") ? team.captainName : nil
        appStore.save(team: team)
        dismiss()
    }
}
