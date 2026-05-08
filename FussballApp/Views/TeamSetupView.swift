import SwiftUI

private struct PlayerEntry: Identifiable {
    var id = UUID()
    var name: String
}

struct TeamSetupView: View {
    let appStore: AppStore
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
                Section("Team Name") {
                    TextField("z.B. FC Mein Team", text: $teamName)
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
            .alert("Spieler bereits vorhanden", isPresented: $showDuplicateAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Ein Spieler mit diesem Namen existiert bereits.")
            }
            .navigationTitle(appStore.team == nil ? "Neues Team" : "Team bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") { save() }
                        .disabled(!canSave)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func addPlayer() {
        let name = newPlayer.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, players.count < 25 else { return }
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
