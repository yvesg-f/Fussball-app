import Foundation
import CoreGraphics
import Combine

final class LineupStore: ObservableObject {

    private let teamId: Int
    private let appStore: AppStore

    let allPlayerNames: [String]

    @Published var formation: Formation {
        didSet {
            let max = formation.totalSlots
            lineup = lineup.filter { (Int($0.key) ?? Int.max) < max }
            slotPositions = [:]
            save()
        }
    }

    @Published var lineup: [String: String] = [:]
    @Published var slotPositions: [String: [Double]] = [:]

    var benchPlayers: [String] {
        let assigned = Set(lineup.values)
        return allPlayerNames.filter { !assigned.contains($0) }
    }

    func playerName(forSlot slot: Int) -> String? { lineup[String(slot)] }
    func isGoalkeeper(slot: Int) -> Bool { slot == 0 }

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

    func defaultPosition(for slot: Int) -> CGPoint {
        let rows = formation.rows
        let totalRows = rows.count
        var cumulative = 0
        for (rowIdx, row) in rows.enumerated() {
            if slot < cumulative + row.count {
                let posInRow = slot - cumulative
                let x = (Double(posInRow) + 1.0) / Double(row.count + 1)
                let displayRowIdx = totalRows - 1 - rowIdx
                let y: Double = totalRows == 1 ? 0.5
                    : 0.13 + Double(displayRowIdx) / Double(totalRows - 1) * 0.74
                return CGPoint(x: x, y: y)
            }
            cumulative += row.count
        }
        return CGPoint(x: 0.5, y: 0.5)
    }

    init(team: Team, appStore: AppStore) {
        self.teamId = team.id
        self.appStore = appStore
        self.allPlayerNames = team.playerNames
        self.formation = Formation(rawValue: team.formationRaw) ?? .f442
        self.lineup = team.lineup
        self.slotPositions = team.slotPositions
    }

    private func save() {
        var team = appStore.team(for: teamId) ?? Team(id: teamId, name: "")
        team.formationRaw = formation.rawValue
        team.lineup = lineup
        team.slotPositions = slotPositions
        appStore.save(team: team)
    }
}
