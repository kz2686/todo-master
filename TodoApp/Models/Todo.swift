import SwiftUI

enum Priority: String, Codable, CaseIterable, Comparable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var symbol: String {
        switch self {
        case .low:    return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high:   return "arrow.up.circle"
        }
    }

    var color: Color {
        switch self {
        case .low:    return Color(red: 0.19, green: 0.82, blue: 0.61)
        case .medium: return Color(red: 1.0, green: 0.75, blue: 0.0)
        case .high:   return Color(red: 1.0, green: 0.27, blue: 0.34)
        }
    }
}

struct Todo: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var notes: String = ""
    var dueDate: Date? = nil
    var priority: Priority? = nil
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var createdAt: Date = Date()
}
