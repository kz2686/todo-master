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
        .padding(.vertical, 16)
        .glassCard()
    }

    // MARK: - Check button

    private var checkButton: some View {
        Button(action: onToggle) {
            ZStack {
                Circle()
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1.5)
                    .frame(width: 26, height: 26)

                if todo.isCompleted {
                    Circle()
                        .fill(LinearGradient.pinkPurple)
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 2)
    }

    // MARK: - Content

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Title — bold, rounded, primary white
            Text(todo.title)
                .todoTitle(completed: todo.isCompleted)
                .strikethrough(todo.isCompleted, color: .white.opacity(0.28))

            // Notes preview — softer, secondary
            if !todo.notes.isEmpty {
                Text(todo.notes)
                    .secondaryLabel()
                    .lineLimit(2)
            }

            // Metadata row — ALL CAPS micro-labels
            HStack(spacing: 8) {
                MetaBadge(
                    text: todo.category.rawValue,
                    icon: todo.category.icon,
                    color: todo.category.glassColor
                )

                if todo.priority != .none {
                    MetaBadge(
                        text: todo.priority.displayName,
                        color: todo.priority.glassColor
                    )
                }

                if let dueDate = todo.dueDate {
                    MetaBadge(
                        text: formatDate(dueDate),
                        icon: "calendar",
                        color: isOverdue(dueDate) && !todo.isCompleted ? .accentPink : .white.opacity(0.35)
                    )
                }

                if todo.reminderDate != nil {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.white.opacity(0.32))
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
