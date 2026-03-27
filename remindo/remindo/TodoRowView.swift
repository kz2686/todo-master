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
        HStack(alignment: .top, spacing: 14) {
            checkButton
            details
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
    }

    // MARK: - Sub-views

    private var checkButton: some View {
        Button(action: onToggle) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                    .frame(width: 26, height: 26)

                if todo.isCompleted {
                    Circle()
                        .fill(LinearGradient.pinkPurple)
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 1)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(todo.title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(todo.isCompleted ? .white.opacity(0.35) : .white)
                .strikethrough(todo.isCompleted, color: .white.opacity(0.35))

            if !todo.notes.isEmpty {
                Text(todo.notes)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(2)
            }

            HStack(spacing: 10) {
                // Category
                Label(todo.category.rawValue, systemImage: todo.category.icon)
                    .font(.caption)
                    .foregroundColor(todo.category.glassColor)

                // Priority
                if todo.priority != .none {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(todo.priority.glassColor)
                            .frame(width: 6, height: 6)
                        Text(todo.priority.displayName)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Due date
                if let dueDate = todo.dueDate {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                        Text(formatDate(dueDate))
                    }
                    .font(.caption)
                    .foregroundColor(isOverdue(dueDate) && !todo.isCompleted ? .accentPink : .white.opacity(0.45))
                }

                // Reminder indicator
                if todo.reminderDate != nil {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date)     { return "Today" }
        if calendar.isDateInTomorrow(date)  { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func isOverdue(_ date: Date) -> Bool { date < Date() }
}
