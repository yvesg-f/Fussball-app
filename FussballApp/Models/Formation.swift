import Foundation

enum Formation: String, CaseIterable {
    case f442  = "4-4-2"
    case f433  = "4-3-3"
    case f352  = "3-5-2"
    case f4231 = "4-2-3-1"
    case f532  = "5-3-2"
    case f4141 = "4-1-4-1"
    case f343  = "3-4-3"
    case f451  = "4-5-1"

    struct Row {
        let label: String
        let count: Int
    }

    var rows: [Row] {
        switch self {
        case .f442:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 4),
                    Row(label: "MIT", count: 4), Row(label: "STU", count: 2)]
        case .f433:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 4),
                    Row(label: "MIT", count: 3), Row(label: "STU", count: 3)]
        case .f352:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 3),
                    Row(label: "MIT", count: 5), Row(label: "STU", count: 2)]
        case .f4231:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 4),
                    Row(label: "DM",  count: 2), Row(label: "AM",  count: 3),
                    Row(label: "STU", count: 1)]
        case .f532:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 5),
                    Row(label: "MIT", count: 3), Row(label: "STU", count: 2)]
        case .f4141:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 4),
                    Row(label: "DM",  count: 1), Row(label: "MIT", count: 4),
                    Row(label: "STU", count: 1)]
        case .f343:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 3),
                    Row(label: "MIT", count: 4), Row(label: "STU", count: 3)]
        case .f451:
            return [Row(label: "TW", count: 1), Row(label: "ABW", count: 4),
                    Row(label: "MIT", count: 5), Row(label: "STU", count: 1)]
        }
    }

    var totalSlots: Int { rows.reduce(0) { $0 + $1.count } }
}
