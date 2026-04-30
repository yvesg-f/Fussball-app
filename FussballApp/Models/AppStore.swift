import Foundation
import Combine

final class AppStore: ObservableObject {
    @Published private(set) var team: Team?

    init() { load() }

    func save(team: Team) {
        self.team = team
        persist()
    }

    func deleteTeam() {
        team = nil
        UserDefaults.standard.removeObject(forKey: "app_team_v2")
    }

    func addLineup(name: String) {
        guard team != nil else { return }
        team!.lineups.append(SavedLineup(name: name))
        persist()
    }

    func deleteLineup(at index: Int) {
        guard var t = team, t.lineups.count > 1, index < t.lineups.count else { return }
        t.lineups.remove(at: index)
        if t.activeLineupIndex >= t.lineups.count {
            t.activeLineupIndex = t.lineups.count - 1
        }
        team = t
        persist()
    }

    private func persist() {
        guard let t = team, let data = try? JSONEncoder().encode(t) else { return }
        UserDefaults.standard.set(data, forKey: "app_team_v2")
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "app_team_v2"),
           let t = try? JSONDecoder().decode(Team.self, from: data) {
            team = t
            return
        }
        // Migrate from old multi-team format (slot 0)
        if let data = UserDefaults.standard.data(forKey: "app_teams"),
           let keyed = try? JSONDecoder().decode([String: Team].self, from: data),
           let t = keyed["0"] {
            team = t
            persist()
        }
    }
}
