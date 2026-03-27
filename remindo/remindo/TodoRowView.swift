//
//  TodoRowView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI

struct TodoRowView: View {
    let todo: Todo
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion button
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(todo.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                
                // Notes preview
                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    // Category indicator
                    Label(todo.category.rawValue, systemImage: todo.category.icon)
                        .font(.caption)
                        .foregroundStyle(Color(todo.category.color))
                    
                    // Priority indicator
                    if todo.priority != .none {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(todo.priority.color))
                                .frame(width: 6, height: 6)
                            Text(todo.priority.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Due date
                    if let dueDate = todo.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(formatDate(dueDate))
                                .font(.caption)
                        }
                        .foregroundStyle(isOverdue(dueDate) && !todo.isCompleted ? .red : .secondary)
                    }
                    
                    // Reminder indicator
                    if todo.reminderDate != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Notes indicator
                    if !todo.notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        date < Date()
    }
}
