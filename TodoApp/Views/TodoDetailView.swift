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
        NavigationView {
            Group {
                if let todo {
                    Form {
                        // Title + complete toggle
                        Section {
                            HStack(alignment: .top, spacing: 12) {
                                Button {
                                    store.toggleComplete(todo)
                                } label: {
                                    Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(todo.isCompleted ? .green : .secondary)
                                        .font(.title2)
                                }
                                .buttonStyle(.plain)

                                Text(todo.title)
                                    .font(.headline)
                                    .strikethrough(todo.isCompleted, color: .secondary)
                                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                            }
                            .padding(.vertical, 4)
                        }

                        // Priority
                        if let priority = todo.priority {
                            Section("Priority") {
                                HStack {
                                    PriorityBadge(priority: priority)
                                    Spacer()
                                }
                            }
                        }

                        // Due date
                        if let dueDate = todo.dueDate {
                            Section("Due Date") {
                                Label(dueDate.formatted(date: .long, time: .omitted),
                                      systemImage: "calendar")
                                    .foregroundColor(isDueOverdue(dueDate) ? .red : .primary)
                            }
                        }

                        // Notes
                        Section("Notes") {
                            if todo.notes.isEmpty {
                                Text("No notes — tap Edit to add some.")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                Text(todo.notes)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Completion info
                        if todo.isCompleted, let completedAt = todo.completedAt {
                            Section {
                                Label("Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))",
                                      systemImage: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                    .font(.footnote)
                            }
                        }
                    }
                } else {
                    Text("Todo not found.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") { showingEdit = true }
                }
            }
            .sheet(isPresented: $showingEdit) {
                if let todo {
                    AddEditTodoView(todo: todo)
                }
            }
        }
    }

    private func isDueOverdue(_ date: Date) -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: date) < today
    }
}
