import SwiftUI

struct AddEditTodoView: View {
    @EnvironmentObject var store: TodoStore
    @Environment(\.dismiss) var dismiss

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
            _title      = State(initialValue: todo.title)
            _notes      = State(initialValue: todo.notes)
            _hasDueDate = State(initialValue: todo.dueDate != nil)
            _dueDate    = State(initialValue: todo.dueDate ?? Date())
            _hasPriority = State(initialValue: todo.priority != nil)
            _priority   = State(initialValue: todo.priority ?? .medium)
        }
    }

    private var isEditing: Bool { editingTodo != nil }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        GlassSection(title: "Title") {
                            TextField("What needs to be done?", text: $title)
                                .font(.body)
                                .foregroundColor(.white)
                                .tint(.accentPink)
                                .submitLabel(.done)
                        }

                        // Due date
                        GlassSection(title: "Due Date") {
                            VStack(spacing: 12) {
                                Toggle(isOn: $hasDueDate.animation()) {
                                    Label("Set due date", systemImage: "calendar")
                                        .foregroundColor(.white)
                                }
                                .tint(.accentPink)

                                if hasDueDate {
                                    Divider()
                                        .background(Color.white.opacity(0.15))
                                    DatePicker(
                                        "Date",
                                        selection: $dueDate,
                                        displayedComponents: .date
                                    )
                                    .colorScheme(.dark)
                                }
                            }
                        }

                        // Priority
                        GlassSection(title: "Priority") {
                            VStack(spacing: 12) {
                                Toggle(isOn: $hasPriority.animation()) {
                                    Label("Set priority", systemImage: "flag")
                                        .foregroundColor(.white)
                                }
                                .tint(.accentPink)

                                if hasPriority {
                                    Divider()
                                        .background(Color.white.opacity(0.15))
                                    HStack(spacing: 8) {
                                        ForEach(Priority.allCases, id: \.self) { p in
                                            priorityButton(p)
                                        }
                                    }
                                }
                            }
                        }

                        // Notes
                        GlassSection(title: "Notes") {
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Add context, links, follow-up thoughts…")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.3))
                                        .allowsHitTesting(false)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $notes)
                                    .scrollContentBackground(.hidden)
                                    .foregroundColor(.white)
                                    .tint(.accentPink)
                                    .frame(minHeight: 120)
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(isEditing ? "Edit Todo" : "New Todo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.white.opacity(0.7))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Save" : "Add") { commit() }
                            .fontWeight(.semibold)
                            .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .white.opacity(0.3) : .white)
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    private func priorityButton(_ p: Priority) -> some View {
        let selected = priority == p && hasPriority

        return Button {
            priority = p
        } label: {
            HStack(spacing: 5) {
                Image(systemName: p.symbol)
                Text(p.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(selected ? p.color.opacity(0.25) : Color.white.opacity(0.06))
            .foregroundColor(selected ? p.color : .white.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selected ? p.color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func commit() {
        var todo = editingTodo ?? Todo(title: "")
        todo.title    = title.trimmingCharacters(in: .whitespaces)
        todo.notes    = notes
        todo.dueDate  = hasDueDate ? Calendar.current.startOfDay(for: dueDate) : nil
        todo.priority = hasPriority ? priority : nil

        isEditing ? store.update(todo) : store.add(todo)
        dismiss()
    }
}
