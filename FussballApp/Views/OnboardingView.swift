import SwiftUI

private struct PlayerEntry: Identifiable {
    var id = UUID()
    var name: String
}

struct OnboardingView: View {
    let appStore: AppStore
    @EnvironmentObject private var settings: AppSettings

    @State private var teamName = ""
    @State private var players: [PlayerEntry] = []
    @State private var newPlayer = ""
    @State private var showDuplicateAlert = false
    @FocusState private var newPlayerFocused: Bool

    private var canStart: Bool {
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty && !players.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.12))
                            .frame(width: 90, height: 90)
                        Image(systemName: "soccerball")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)
                    }
                    Text("Tactix")
                        .font(.largeTitle.bold())
                    Text(settings.t("onboarding_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 48)

                VStack(alignment: .leading, spacing: 8) {
                    Text(settings.t("team_name"))
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 4)

                    TextField(settings.t("team_name_placeholder"), text: $teamName)
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(format: settings.t("players_count"), players.count))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        ForEach(players) { player in
                            HStack {
                                Text(player.name)
                                Spacer()
                                Button {
                                    players.removeAll { $0.id == player.id }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            if player.id != players.last?.id {
                                Divider().padding(.leading, 12)
                            }
                        }

                        if !players.isEmpty {
                            Divider().padding(.leading, 12)
                        }

                        HStack {
                            TextField(settings.t("add_name_placeholder"), text: $newPlayer)
                                .focused($newPlayerFocused)
                                .onSubmit { addPlayer() }
                            Button(settings.t("add")) { addPlayer() }
                                .disabled(newPlayer.trimmingCharacters(in: .whitespaces).isEmpty)
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))

                    if players.isEmpty {
                        Text(settings.t("at_least_one_player"))
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)

                Button { save() } label: {
                    Text(settings.t("get_started"))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(canStart ? Color.green : Color.secondary, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                }
                .disabled(!canStart)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .alert(settings.t("duplicate_player_title"), isPresented: $showDuplicateAlert) {
            Button(settings.t("ok"), role: .cancel) {}
        } message: {
            Text(settings.t("duplicate_player_message"))
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
        let name = teamName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, !players.isEmpty else { return }
        var team = Team(id: 0, name: name)
        team.playerNames = players.map { $0.name }
        team.lineups = [SavedLineup(name: "Plan A")]
        appStore.save(team: team)
    }
}
