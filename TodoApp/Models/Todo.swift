import Foundation

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
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        }
    }

    var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

import SwiftUI

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
