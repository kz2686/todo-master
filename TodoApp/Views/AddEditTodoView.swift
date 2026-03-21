import SwiftUI

struct AddEditTodoView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss

    // nil = adding a new todo
    var editingTodo: Todo?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var hasPriority: Bool = false
    @State private var priority: Priority = .medium

    init(todo: Todo? = nil) {
        self.editingTodo = todo
        if let todo {
            _title = State(initialValue: todo.title)
            _notes = State(initialValue: todo.notes)
            _hasDueDate = State(initialValue: todo.dueDate != nil)
            _dueDate = State(initialValue: todo.dueDate ?? Date())
            _hasPriority = State(initialValue: todo.priority != nil)
            _priority = State(initialValue: todo.priority ?? .medium)
        }
    }

    private var isEditing: Bool { editingTodo != nil }

    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("What needs to be done?", text: $title)
                        .submitLabel(.done)
                }

                Section {
                    Toggle("Due Date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker(
                            "Date",
                            selection: $dueDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section {
                    Toggle("Priority", isOn: $hasPriority.animation())
                    if hasPriority {
                        Picker("Level", selection: $priority) {
                            ForEach(Priority.allCases, id: \.self) { p in
                                Label(p.rawValue, systemImage: p.symbol).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section("Notes") {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text("Add context, links, follow-up thoughts…")
                                .foregroundColor(.secondary.opacity(0.6))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 120)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Todo" : "New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        commit()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func commit() {
        var todo = editingTodo ?? Todo(title: "")
        todo.title = title.trimmingCharacters(in: .whitespaces)
        todo.notes = notes
        todo.dueDate = hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil
        todo.priority = hasPriority ? priority : nil

        if isEditing {
            store.update(todo)
        } else {
            store.add(todo)
        }
        dismiss()
    }
}
