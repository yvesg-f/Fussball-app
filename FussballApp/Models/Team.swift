import Foundation

struct Team: Codable, Identifiable {
    var id: Int
    var name: String
    var playerNames: [String]
    var formationRaw: String
    var lineup: [String: String]
    var slotPositions: [String: [Double]]

    init(id: Int, name: String, playerNames: [String] = []) {
        self.id = id
        self.name = name
        self.playerNames = playerNames
        self.formationRaw = "4-4-2"
        self.lineup = [:]
        self.slotPositions = [:]
    }
}
