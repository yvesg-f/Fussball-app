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
            slotPositions = [:]
            save()
        }
    }

    @Published var lineup: [String: String] = [:]

    // Relative positions (0–1) per slot, overriding the default grid layout
    @Published var slotPositions: [String: [Double]] = [:]

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
        slotPositions.removeValue(forKey: String(slot))
        save()
    }

    func isGoalkeeper(slot: Int) -> Bool {
        slot == 0
    }

    // Returns relative position (0–1) for a slot — custom or default grid position
    func position(for slot: Int) -> CGPoint {
        let key = String(slot)
        if let stored = slotPositions[key], stored.count == 2 {
            return CGPoint(x: stored[0], y: stored[1])
        }
        return defaultPosition(for: slot)
    }

    func setPosition(for slot: Int, point: CGPoint) {
        slotPositions[String(slot)] = [point.x, point.y]
        save()
    }

    // Calculates the default grid position for a slot based on the current formation
    func defaultPosition(for slot: Int) -> CGPoint {
        let rows = formation.rows
        let totalRows = rows.count
        var cumulative = 0

        for (rowIdx, row) in rows.enumerated() {
            if slot < cumulative + row.count {
                let posInRow = slot - cumulative
                let x = (Double(posInRow) + 1.0) / Double(row.count + 1)
                // Row 0 (GK) displayed at bottom (y ≈ 0.87), last row (ATT) at top (y ≈ 0.13)
                let displayRowIdx = totalRows - 1 - rowIdx
                let y: Double
                if totalRows == 1 {
                    y = 0.5
                } else {
                    y = 0.13 + Double(displayRowIdx) / Double(totalRows - 1) * 0.74
                }
                return CGPoint(x: x, y: y)
            }
            cumulative += row.count
        }
        return CGPoint(x: 0.5, y: 0.5)
    }

    init() {
        let f = UserDefaults.standard.string(forKey: "k_formation")
            .flatMap { Formation(rawValue: $0) } ?? .f442
        let l = (UserDefaults.standard.dictionary(forKey: "k_lineup") as? [String: String]) ?? [:]
        let p = (UserDefaults.standard.dictionary(forKey: "k_positions") as? [String: [Double]]) ?? [:]
        formation = f
        lineup = l
        slotPositions = p
    }

    private func save() {
        UserDefaults.standard.set(formation.rawValue, forKey: "k_formation")
        UserDefaults.standard.set(lineup, forKey: "k_lineup")
        UserDefaults.standard.set(slotPositions, forKey: "k_positions")
    }
}
