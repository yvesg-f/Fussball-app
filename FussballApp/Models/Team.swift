import Foundation

struct SavedLineup: Codable {
    var name: String
    var formationRaw: String
    var lineup: [String: String]
    var slotPositions: [String: [Double]]

    init(name: String, formationRaw: String = "4-4-2",
         lineup: [String: String] = [:], slotPositions: [String: [Double]] = [:]) {
        self.name = name
        self.formationRaw = formationRaw
        self.lineup = lineup
        self.slotPositions = slotPositions
    }
}

struct Team: Codable, Identifiable {
    var id: Int
    var name: String
    var playerNames: [String]
    var captainName: String?
    var tacticNotes: String
    var lineups: [SavedLineup]
    var activeLineupIndex: Int
    var setPieces: [SetPiece]

    var activeLineup: SavedLineup {
        get { lineups[activeLineupIndex] }
        set { lineups[activeLineupIndex] = newValue }
    }

    // Used by HomeView subtitle without changes
    var formationRaw: String { activeLineup.formationRaw }

    init(id: Int, name: String, playerNames: [String] = []) {
        self.id = id
        self.name = name
        self.playerNames = playerNames
        self.captainName = nil
        self.tacticNotes = ""
        self.lineups = [SavedLineup(name: "Plan A"), SavedLineup(name: "Plan B")]
        self.activeLineupIndex = 0
        self.setPieces = []
    }

    // MARK: - Custom Codable for migration from legacy format

    enum CodingKeys: String, CodingKey {
        case id, name, playerNames, captainName, tacticNotes
        case lineups, activeLineupIndex, setPieces
        // Legacy keys (read-only during migration)
        case formationRaw, lineup, slotPositions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(Int.self, forKey: .id)
        name            = try c.decode(String.self, forKey: .name)
        playerNames     = try c.decode([String].self, forKey: .playerNames)
        captainName     = try c.decodeIfPresent(String.self, forKey: .captainName)
        tacticNotes     = try c.decodeIfPresent(String.self, forKey: .tacticNotes) ?? ""
        activeLineupIndex = try c.decodeIfPresent(Int.self, forKey: .activeLineupIndex) ?? 0
        setPieces       = try c.decodeIfPresent([SetPiece].self, forKey: .setPieces) ?? []

        if let saved = try c.decodeIfPresent([SavedLineup].self, forKey: .lineups), !saved.isEmpty {
            lineups = saved
        } else {
            // Migrate from pre-lineups format
            let legacyFormation  = try c.decodeIfPresent(String.self, forKey: .formationRaw) ?? "4-4-2"
            let legacyLineup     = try c.decodeIfPresent([String: String].self, forKey: .lineup) ?? [:]
            let legacySlots      = try c.decodeIfPresent([String: [Double]].self, forKey: .slotPositions) ?? [:]
            lineups = [
                SavedLineup(name: "Plan A", formationRaw: legacyFormation,
                            lineup: legacyLineup, slotPositions: legacySlots),
                SavedLineup(name: "Plan B")
            ]
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,               forKey: .id)
        try c.encode(name,             forKey: .name)
        try c.encode(playerNames,      forKey: .playerNames)
        try c.encodeIfPresent(captainName, forKey: .captainName)
        try c.encode(tacticNotes,      forKey: .tacticNotes)
        try c.encode(lineups,          forKey: .lineups)
        try c.encode(activeLineupIndex, forKey: .activeLineupIndex)
        try c.encode(setPieces,        forKey: .setPieces)
    }
}
