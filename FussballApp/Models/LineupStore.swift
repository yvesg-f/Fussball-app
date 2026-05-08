import Foundation
import CoreGraphics
import Combine

final class LineupStore: ObservableObject {

    private let lineupIndex: Int
    private let appStore: AppStore

    let allPlayerNames: [String]

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
    @Published var benchPlayerNames: [String] = []
    @Published var captainName: String?
    @Published var tacticNotes: String
    @Published var setPieces: [SetPiece]

    var benchPlayers: [String] {
        let assigned = Set(lineup.values)
        return benchPlayerNames.filter { !assigned.contains($0) }
    }

    var unselectedPlayers: [String] {
        let assigned = Set(lineup.values)
        let benched  = Set(benchPlayerNames)
        return allPlayerNames.filter { !assigned.contains($0) && !benched.contains($0) }
    }

    func addToBench(_ name: String) {
        guard !benchPlayerNames.contains(name) else { return }
        benchPlayerNames.append(name)
        save()
    }

    func removeFromBench(_ name: String) {
        benchPlayerNames.removeAll { $0 == name }
        save()
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
        benchPlayerNames.removeAll { $0 == name }
        save()
    }

    func remove(fromSlot slot: Int) {
        lineup.removeValue(forKey: String(slot))
        slotPositions.removeValue(forKey: String(slot))
        save()
    }

    func toggleCaptain(for name: String) {
        captainName = captainName == name ? nil : name
        save()
    }

    func saveTacticNotes(_ notes: String) {
        tacticNotes = notes
        save()
    }

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

    init(team: Team, lineupIndex: Int, appStore: AppStore) {
        self.lineupIndex = lineupIndex
        self.appStore = appStore
        self.allPlayerNames = team.playerNames
        let active = lineupIndex < team.lineups.count
            ? team.lineups[lineupIndex]
            : SavedLineup(name: "Plan \(lineupIndex + 1)")
        self.formation = Formation(rawValue: active.formationRaw) ?? .f442
        self.lineup = active.lineup
        self.slotPositions = active.slotPositions
        self.benchPlayerNames = active.benchPlayerNames
        self.captainName = team.captainName
        self.tacticNotes = team.tacticNotes
        self.setPieces = team.setPieces
    }

    private func save() {
        guard var team = appStore.team else { return }
        while team.lineups.count <= lineupIndex {
            team.lineups.append(SavedLineup(name: "Plan \(team.lineups.count + 1)"))
        }
        team.lineups[lineupIndex].formationRaw = formation.rawValue
        team.lineups[lineupIndex].lineup = lineup
        team.lineups[lineupIndex].slotPositions = slotPositions
        team.lineups[lineupIndex].benchPlayerNames = benchPlayerNames
        let validPlayerNames = Set(team.playerNames)
        team.captainName = validPlayerNames.contains(captainName ?? "") ? captainName : nil
        team.tacticNotes = tacticNotes
        team.setPieces = setPieces
        appStore.save(team: team)
    }
}
