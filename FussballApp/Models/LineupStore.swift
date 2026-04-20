import Foundation
import Combine

final class LineupStore: ObservableObject {

    static let allPlayerNames: [String] = [
        "Medo", "Cucu", "David", "Flo", "Gilbi", "Jonas (2. TW)",
        "Lars", "Lau", "Linus", "Nali", "Nicci", "Welte", "Noah",
        "Noel", "Noe", "Oli", "Steffo", "Vital"
    ]

    @Published var formation: Formation {
        didSet {
            let max = formation.totalSlots
            lineup = lineup.filter { (Int($0.key) ?? Int.max) < max }
            save()
        }
    }

    @Published var lineup: [String: String] = [:]

    private var assignedNames: Set<String> { Set(lineup.values) }

    var benchPlayers: [String] {
        Self.allPlayerNames.filter { !assignedNames.contains($0) }
    }

    func playerName(forSlot slot: Int) -> String? {
        lineup[String(slot)]
    }

    func assign(name: String, toSlot slot: Int) {
        lineup = lineup.filter { $0.value != name }
        lineup[String(slot)] = name
        save()
    }

    func remove(fromSlot slot: Int) {
        lineup.removeValue(forKey: String(slot))
        save()
    }

    init() {
        let f = UserDefaults.standard.string(forKey: "k_formation")
            .flatMap { Formation(rawValue: $0) } ?? .f442
        let l = (UserDefaults.standard.dictionary(forKey: "k_lineup") as? [String: String]) ?? [:]
        formation = f
        lineup = l
    }

    private func save() {
        UserDefaults.standard.set(formation.rawValue, forKey: "k_formation")
        UserDefaults.standard.set(lineup, forKey: "k_lineup")
    }
}
