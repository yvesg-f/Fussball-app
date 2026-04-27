import SwiftUI

enum PitchZone: String, CaseIterable, Hashable {
    case leftWide  = "LA"
    case leftHalf  = "LH"
    case center    = "ZE"
    case rightHalf = "RH"
    case rightWide = "RA"

    var label: String {
        switch self {
        case .leftWide:  return "Links"
        case .leftHalf:  return "Halbspur L"
        case .center:    return "Zentrum"
        case .rightHalf: return "Halbspur R"
        case .rightWide: return "Rechts"
        }
    }

    var color: Color {
        switch self {
        case .leftWide, .rightWide: return .blue
        case .leftHalf, .rightHalf: return .orange
        case .center:               return .red
        }
    }

    var xStart: Double {
        switch self {
        case .leftWide:  return 0.0
        case .leftHalf:  return 0.2
        case .center:    return 0.4
        case .rightHalf: return 0.6
        case .rightWide: return 0.8
        }
    }

    var xEnd: Double { xStart + 0.2 }
}
