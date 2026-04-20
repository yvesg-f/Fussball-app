import Foundation
import Combine

final class AppStore: ObservableObject {
    static let maxTeams = 5

    @Published private(set) var teams: [Int: Team] = [:]

    init() { load() }

    func save(team: Team) {
        teams[team.id] = team
        persist()
    }

    func delete(id: Int) {
        teams.removeValue(forKey: id)
        persist()
    }

    func team(for id: Int) -> Team? { teams[id] }

    // MARK: - Persistence

    private func persist() {
        let keyed = Dictionary(uniqueKeysWithValues: teams.map { (String($0.key), $0.value) })
        if let data = try? JSONEncoder().encode(keyed) {
            UserDefaults.standard.set(data, forKey: "app_teams")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: "app_teams"),
              let keyed = try? JSONDecoder().decode([String: Team].self, from: data)
        else { return }
        teams = Dictionary(uniqueKeysWithValues: keyed.compactMap { k, v in
            Int(k).map { ($0, v) }
        })
    }
}
