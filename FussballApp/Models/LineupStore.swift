import Foundation
import CoreGraphics
import Combine

final class LineupStore: ObservableObject {

    private let teamId: Int
    private let appStore: AppStore

    let allPlayerNames: [String]

    // MARK: - Active lineup state

    @Published var activeLineupIndex: Int

    private var suppressFormationDidSet = false
    @Published var formation: Formation {
        didSet {
            guard !suppressFormationDidSet else { return }
            let max = formation.totalSlots
            lineup = lineup.filter { (Int($0.key) ?? Int.max) < max }
            slotPositions = [:]
            save()
        }
    }

    @Published var lineup: [String: String] = [:]
    @Published var slotPositions: [String: [Double]] = [:]

    // MARK: - Team-level state

    @Published var captainName: String?
    @Published var tacticNotes: String
    @Published var setPieces: [SetPiece]

    // MARK: - Derived

    var benchPlayers: [String] {
        let assigned = Set(lineup.values)
        return allPlayerNames.filter { !assigned.contains($0) }
    }

    var lineupNames: [String] {
        appStore.team(for: teamId)?.lineups.map { $0.name } ?? ["Plan A", "Plan B"]
    }

    func playerName(forSlot slot: Int) -> String? { lineup[String(slot)] }
    func isGoalkeeper(slot: Int) -> Bool { slot == 0 }

    // MARK: - Position

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

    // MARK: - Lineup mutations

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

    // MARK: - Lineup switching (Plan A / Plan B)

    func switchLineup(to index: Int) {
        guard index != activeLineupIndex,
              let team = appStore.team(for: teamId),
              index < team.lineups.count else { return }
        save()
        activeLineupIndex = index
        let active = team.lineups[index]
        suppressFormationDidSet = true
        formation = Formation(rawValue: active.formationRaw) ?? .f442
        suppressFormationDidSet = false
        lineup = active.lineup
        slotPositions = active.slotPositions
    }

    // MARK: - Captain

    func toggleCaptain(for name: String) {
        captainName = captainName == name ? nil : name
        save()
    }

    // MARK: - Tactic notes

    func saveTacticNotes(_ notes: String) {
        tacticNotes = notes
        save()
    }

    // MARK: - Set pieces

    func saveSetPiece(_ piece: SetPiece) {
        if let idx = setPieces.firstIndex(where: { $0.id == piece.id }) {
            setPieces[idx] = piece
        } else {
            setPieces.append(piece)
        }
        save()
    }

    func deleteSetPiece(id: UUID) {
        setPieces.removeAll { $0.id == id }
        save()
    }

    // MARK: - Default positions

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

    // MARK: - Init

    init(team: Team, appStore: AppStore) {
        self.teamId = team.id
        self.appStore = appStore
        self.allPlayerNames = team.playerNames
        self.activeLineupIndex = team.activeLineupIndex
        let active = team.activeLineup
        self.formation = Formation(rawValue: active.formationRaw) ?? .f442
        self.lineup = active.lineup
        self.slotPositions = active.slotPositions
        self.captainName = team.captainName
        self.tacticNotes = team.tacticNotes
        self.setPieces = team.setPieces
    }

    // MARK: - Persistence

    private func save() {
        var team = appStore.team(for: teamId) ?? Team(id: teamId, name: "")
        while team.lineups.count <= activeLineupIndex {
            team.lineups.append(SavedLineup(name: "Plan \(team.lineups.count + 1)"))
        }
        team.lineups[activeLineupIndex].formationRaw = formation.rawValue
        team.lineups[activeLineupIndex].lineup = lineup
        team.lineups[activeLineupIndex].slotPositions = slotPositions
        team.activeLineupIndex = activeLineupIndex
        team.captainName = captainName
        team.tacticNotes = tacticNotes
        team.setPieces = setPieces
        appStore.save(team: team)
    }
}
