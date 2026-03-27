import SwiftUI

struct CompletedRowView: View {
    @EnvironmentObject var store: TodoStore
    let todo: Todo
    @State private var showingDetail = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    store.toggleComplete(todo)
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient.pinkPurple.opacity(0.5))
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    Text(todo.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.35))
                        .strikethrough(true, color: .white.opacity(0.35))

                    Spacer()

                    if let priority = todo.priority {
                        PriorityBadge(priority: priority)
                            .opacity(0.5)
                    }
                }

                if let completedAt = todo.completedAt {
                    Label(completedAt.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.35))
                }

                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                        .lineLimit(2)
                }
            }
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
}
