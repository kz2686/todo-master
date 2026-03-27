import SwiftUI

struct TodoRowView: View {
    @EnvironmentObject var store: TodoStore
    let todo: Todo
    @State private var showingDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            checkButton
            details
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassCard()
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture { showingDetail = true }
        .sheet(isPresented: $showingDetail) {
            TodoDetailView(todoID: todo.id)
        }
    }

    // MARK: - Sub-views

    private var checkButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                store.toggleComplete(todo)
            }
        } label: {
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
            HStack(alignment: .center) {
                Text(todo.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(todo.isCompleted ? .white.opacity(0.35) : .white)
                    .strikethrough(todo.isCompleted, color: .white.opacity(0.35))

                Spacer()

                if let priority = todo.priority {
                    PriorityBadge(priority: priority)
                }
            }

            if let dueDate = todo.dueDate {
                Label {
                    Text(dueDate, style: .date)
                } icon: {
                    Image(systemName: "calendar")
                }
                .font(.caption)
                .foregroundColor(isOverdue(dueDate) ? .accentPink : .white.opacity(0.45))
            }

            if !todo.notes.isEmpty {
                Text(todo.notes)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(2)
            }
        }
    }

    private func isOverdue(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
    }
}
