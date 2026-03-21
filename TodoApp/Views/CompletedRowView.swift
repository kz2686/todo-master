import SwiftUI

struct CompletedRowView: View {
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
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green.opacity(0.6))
                    .font(.title2)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .center) {
                    Text(todo.title)
                        .font(.body)
                        .strikethrough(true, color: .secondary)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let priority = todo.priority {
                        PriorityBadge(priority: priority)
                            .opacity(0.6)
                    }
                }

                if let completedAt = todo.completedAt {
                    Label(completedAt.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
}
