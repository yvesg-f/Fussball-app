import SwiftUI

struct TeamSetupView: View {
    let teamId: Int
    let appStore: AppStore
    @Binding var path: [AppRoute]

    @State private var teamName: String
    @State private var players: [String]
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
        self._players = State(initialValue: existing?.playerNames ?? [])
    }

    var body: some View {
        Form {
            Section("Team Name") {
                TextField("z.B. FC Zürich", text: $teamName)
            }

            Section {
                ForEach(players.indices, id: \.self) { i in
                    TextField("Spieler \(i + 1)", text: $players[i])
                }
                .onDelete { players.remove(atOffsets: $0) }

                if players.count < 20 {
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
                    Text("Spieler (\(players.count)/20)")
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
        guard !name.isEmpty, players.count < 20 else { return }
        players.append(name)
        newPlayer = ""
        newPlayerFocused = true
    }

    private func save() {
        var team = appStore.team(for: teamId) ?? Team(id: teamId, name: "")
        team.name = teamName.trimmingCharacters(in: .whitespaces)
        team.playerNames = players.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        // Remove lineup entries whose players were deleted
        let validNames = Set(team.playerNames)
        team.lineup = team.lineup.filter { validNames.contains($0.value) }
        let validSlots = Set(team.lineup.keys)
        team.slotPositions = team.slotPositions.filter { validSlots.contains($0.key) }
        appStore.save(team: team)
        path = [.lineup(teamId: teamId)]
    }
}
