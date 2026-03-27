//
//  Todo.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import Foundation
import SwiftData

@Model
final class Todo {
    var title: String
    var notes: String
    var priority: Priority
    var category: Category
    var dueDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var reminderDate: Date?
    var createdAt: Date
    
    enum Priority: Int, Codable, CaseIterable {
        case none = 0
        case low = 1
        case medium = 2
        case high = 3
        
        var displayName: String {
            switch self {
            case .none: return "None"
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        var color: String {
            switch self {
            case .none: return "gray"
            case .low: return "blue"
            case .medium: return "orange"
            case .high: return "red"
            }
        }
    }
    
    enum Category: String, Codable, CaseIterable {
        case personal = "Personal"
        case work = "Work"
        
        var icon: String {
            switch self {
            case .personal: return "house.fill"
            case .work: return "briefcase.fill"
            }
        }
        
        var color: String {
            switch self {
            case .personal: return "cyan"
            case .work: return "purple"
            }
        }
    }
    
    init(title: String, notes: String = "", priority: Priority = .none, category: Category = .personal, dueDate: Date? = nil, reminderDate: Date? = nil) {
        self.title = title
        self.notes = notes
        self.priority = priority
        self.category = category
        self.dueDate = dueDate
        self.isCompleted = false
        self.completedAt = nil
        self.reminderDate = reminderDate
        self.createdAt = Date()
    }
    
    var shouldShowToday: Bool {
        if dueDate == nil {
            return true // Always show todos without due date
        }
        
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate) || dueDate < Date()
    }
}
