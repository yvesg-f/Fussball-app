import Foundation

enum SetPieceType: String, Codable, CaseIterable {
    case cornerLeft  = "Eckball Links"
    case cornerRight = "Eckball Rechts"
    case freeKick    = "Freistoß"
    case penalty     = "Elfmeter"
    case throwIn     = "Einwurf"
    case freeTactic  = "Freie Taktik"

    var symbol: String {
        switch self {
        case .cornerLeft:  return "arrow.turn.up.left"
        case .cornerRight: return "arrow.turn.up.right"
        case .freeKick:    return "soccerball"
        case .penalty:     return "scope"
        case .throwIn:     return "arrow.up.circle"
        case .freeTactic:  return "rectangle.and.pencil.and.ellipsis"
        }
    }

    var defaultBallPosition: [Double] {
        switch self {
        case .cornerLeft:  return [0.03, 0.04]
        case .cornerRight: return [0.97, 0.04]
        case .freeKick:    return [0.50, 0.38]
        case .penalty:     return [0.50, 0.20]
        case .throwIn:     return [0.03, 0.40]
        case .freeTactic:  return [0.50, 0.50]
        }
    }

    var usesFullPitch: Bool { self == .freeTactic }
}

enum SetPiecePhase: String, Codable, CaseIterable {
    case attacking = "Angriff"
    case defending = "Verteidigung"
}

enum ArrowColor: String, Codable, CaseIterable {
    case blue   = "Lauf"
    case orange = "Flanke"
    case red    = "Block"
}

struct DrawnArrow: Codable, Identifiable {
    var id: UUID = UUID()
    var points: [[Double]]
    var color: ArrowColor
}

struct SetPiece: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var type: SetPieceType
    var phase: SetPiecePhase
    var playerPositions: [String: [Double]]
    var ballPosition: [Double]
    var arrows: [DrawnArrow]
    var opponentPositions: [[Double]]

    init(name: String = "", type: SetPieceType, phase: SetPiecePhase = .attacking) {
        self.name = name
        self.type = type
        self.phase = phase
        self.playerPositions = [:]
        self.ballPosition = type.defaultBallPosition
        self.arrows = []
        self.opponentPositions = []
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, phase, playerPositions, ballPosition, arrows, opponentPositions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name              = try c.decode(String.self, forKey: .name)
        type              = try c.decode(SetPieceType.self, forKey: .type)
        phase             = try c.decodeIfPresent(SetPiecePhase.self, forKey: .phase) ?? .attacking
        playerPositions   = try c.decodeIfPresent([String: [Double]].self, forKey: .playerPositions) ?? [:]
        ballPosition      = try c.decodeIfPresent([Double].self, forKey: .ballPosition) ?? type.defaultBallPosition
        arrows            = try c.decodeIfPresent([DrawnArrow].self, forKey: .arrows) ?? []
        opponentPositions = try c.decodeIfPresent([[Double]].self, forKey: .opponentPositions) ?? []
    }
}
