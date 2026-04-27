import SwiftUI

private struct PlayerEntry: Identifiable {
    var id = UUID()
    var name: String
}

struct TeamSetupView: View {
    let teamId: Int
    let appStore: AppStore
    @Binding var path: [AppRoute]

    @State private var teamName: String
    @State private var players: [PlayerEntry]
    @State private var newPlayer: String = ""
    @FocusState private var newPlayerFocused: Bool

    private var isEditing: Bool { appStore.team(for: teamId) != nil }
    private var canSave: Bool {
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty && !players.isEmpty
    }

    init(teamId: Int, appStore: AppStore, path: Binding<[AppRoute]>) {
        self.teamId = teamId
        self.appStore = appStore
        self._path = path
        let existing = appStore.team(for: teamId)
        self._teamName = State(initialValue: existing?.name ?? "")
        self._players = State(initialValue: existing?.playerNames.map { PlayerEntry(name: $0) } ?? [])
    }

    var body: some View {
        Form {
            Section("Team Name") {
                TextField("z.B. FC Zürich", text: $teamName)
            }

            Section {
                ForEach($players) { $player in
                    TextField("Spielername", text: $player.name)
                }
                .onDelete { players.remove(atOffsets: $0) }

                if players.count < 25 {
                    HStack {
                        TextField("Name hinzufügen…", text: $newPlayer)
                            .focused($newPlayerFocused)
                            .onSubmit { addPlayer() }
                        Button("Hinzufügen") { addPlayer() }
                            .disabled(newPlayer.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            } header: {
                HStack {
                    Text("Spieler (\(players.count)/25)")
                    Spacer()
                    if !players.isEmpty {
                        EditButton()
                            .font(.caption)
                    }
                }
            } footer: {
                if players.isEmpty {
                    Text("Mindestens 1 Spieler erforderlich.")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(isEditing ? "Team bearbeiten" : "Neues Team")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Speichern") { save() }
                    .disabled(!canSave)
                    .fontWeight(.semibold)
            }
        }
    }

    private func addPlayer() {
        let name = newPlayer.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, players.count < 25 else { return }
        players.append(PlayerEntry(name: name))
        newPlayer = ""
        newPlayerFocused = true
    }

    private func save() {
        var team = appStore.team(for: teamId) ?? Team(id: teamId, name: "")
        team.name = teamName.trimmingCharacters(in: .whitespaces)
        team.playerNames = players.map { $0.name }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let validNames = Set(team.playerNames)
        for i in team.lineups.indices {
            team.lineups[i].lineup = team.lineups[i].lineup.filter { validNames.contains($0.value) }
            let validSlots = Set(team.lineups[i].lineup.keys)
            team.lineups[i].slotPositions = team.lineups[i].slotPositions.filter { validSlots.contains($0.key) }
        }
        team.captainName = validNames.contains(team.captainName ?? "") ? team.captainName : nil
        appStore.save(team: team)
        path = [.lineup(teamId: teamId)]
    }
}
