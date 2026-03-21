import SwiftUI

struct TodoRowView: View {
    @EnvironmentObject var store: TodoStore
    let todo: Todo
    @State private var showingDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleComplete(todo)
                }
            } label: {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : .secondary)
                    .font(.title2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center) {
                    Text(todo.title)
                        .font(.body)
                        .strikethrough(todo.isCompleted, color: .secondary)
                        .foregroundColor(todo.isCompleted ? .secondary : .primary)

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
                    .foregroundColor(isOverdue(dueDate) ? .red : .secondary)
                }

                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 1)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture { showingDetail = true }
        .sheet(isPresented: $showingDetail) {
            TodoDetailView(todoID: todo.id)
        }
    }

    private func isOverdue(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: date) < today
    }
}
