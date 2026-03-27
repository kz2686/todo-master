import SwiftUI

struct TodoDetailView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss
    let todoID: UUID
    @State private var showingEdit = false

    private var todo: Todo? {
        store.todos.first { $0.id == todoID }
    }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if let todo {
                            titleSection(todo)

                            if let priority = todo.priority {
                                GlassSection(title: "Priority") {
                                    PriorityBadge(priority: priority)
                                }
                            }

                            if let dueDate = todo.dueDate {
                                GlassSection(title: "Due Date") {
                                    Label(
                                        dueDate.formatted(date: .long, time: .omitted),
                                        systemImage: "calendar"
                                    )
                                    .foregroundColor(isDueOverdue(dueDate) ? .accentPink : .white)
                                }
                            }

                            GlassSection(title: "Notes") {
                                if todo.notes.isEmpty {
                                    Text("No notes — tap Edit to add some.")
                                        .foregroundColor(.white.opacity(0.35))
                                        .italic()
                                } else {
                                    Text(todo.notes)
                                        .foregroundColor(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }

                            if todo.isCompleted, let completedAt = todo.completedAt {
                                GlassSection {
                                    Label(
                                        "Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))",
                                        systemImage: "checkmark.seal.fill"
                                    )
                                    .foregroundStyle(LinearGradient.pinkPurple)
                                    .font(.footnote)
                                }
                            }
                        } else {
                            Text("Todo not found.")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") { dismiss() }
                            .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Edit") { showingEdit = true }
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    if let todo {
                        AddEditTodoView(todo: todo)
                    }
                }
            }
        }
    }

    private func titleSection(_ todo: Todo) -> some View {
        GlassSection {
            HStack(alignment: .top, spacing: 14) {
                Button {
                    store.toggleComplete(todo)
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

                Text(todo.title)
                    .font(.headline)
                    .foregroundColor(todo.isCompleted ? .white.opacity(0.35) : .white)
                    .strikethrough(todo.isCompleted, color: .white.opacity(0.35))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func isDueOverdue(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
    }
}
