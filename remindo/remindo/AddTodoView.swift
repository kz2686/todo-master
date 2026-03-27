//
//  AddTodoView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var notes = ""
    @State private var selectedPriority: Todo.Priority = .none
    @State private var selectedCategory: Todo.Category
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var hasReminder = false
    @State private var reminderHours: Double = 3

    init() {
        _selectedCategory = State(initialValue: AppSettings.shared.defaultCategory())
    }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Title
                        GlassSection(title: "Title") {
                            TextField("What needs to be done?", text: $title, axis: .vertical)
                                .lineLimit(3...6)
                                .font(.body)
                                .foregroundColor(.white)
                                .tint(.accentPink)
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
                                    .frame(minHeight: 100)
                            }
                        }

                        // Category
                        GlassSection(title: "Category") {
                            HStack(spacing: 8) {
                                ForEach(Todo.Category.allCases, id: \.self) { cat in
                                    categoryButton(cat)
                                }
                            }
                        }

                        // Priority
                        GlassSection(title: "Priority") {
                            HStack(spacing: 8) {
                                ForEach(Todo.Priority.allCases, id: \.self) { p in
                                    priorityButton(p)
                                }
                            }
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
                                    Divider().background(Color.white.opacity(0.15))
                                    DatePicker("Date & time", selection: $dueDate,
                                               displayedComponents: [.date, .hourAndMinute])
                                        .colorScheme(.dark)
                                    Text("Todos without a due date always appear in today's list")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                        }

                        // Reminder
                        GlassSection(title: "Reminder") {
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle(isOn: $hasReminder.animation()) {
                                    Label("Remind me if not done", systemImage: "bell")
                                        .foregroundColor(.white)
                                }
                                .tint(.accentPink)

                                if hasReminder {
                                    Divider().background(Color.white.opacity(0.15))
                                    Text("Remind me in \(Int(reminderHours)) hour\(reminderHours == 1 ? "" : "s")")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Slider(value: $reminderHours, in: 1...24, step: 1)
                                        .tint(.accentPink)
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("New Todo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.white.opacity(0.7))
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") { saveTodo() }
                            .fontWeight(.semibold)
                            .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .white.opacity(0.3) : .white)
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    // MARK: - Buttons

    private func categoryButton(_ cat: Todo.Category) -> some View {
        let selected = selectedCategory == cat
        return Button { selectedCategory = cat } label: {
            Label(cat.rawValue, systemImage: cat.icon)
                .font(.subheadline)
                .fontWeight(selected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selected ? cat.glassColor.opacity(0.2) : Color.white.opacity(0.06))
                .foregroundColor(selected ? cat.glassColor : .white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected ? cat.glassColor.opacity(0.5) : Color.clear, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func priorityButton(_ p: Todo.Priority) -> some View {
        let selected = selectedPriority == p
        return Button { selectedPriority = p } label: {
            HStack(spacing: 5) {
                Circle()
                    .fill(p.glassColor)
                    .frame(width: 7, height: 7)
                Text(p.displayName)
                    .font(.caption)
                    .fontWeight(selected ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(selected ? p.glassColor.opacity(0.2) : Color.white.opacity(0.06))
            .foregroundColor(selected ? p.glassColor : .white.opacity(0.45))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected ? p.glassColor.opacity(0.5) : Color.clear, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save

    private func saveTodo() {
        let reminderDate = hasReminder ? Date().addingTimeInterval(reminderHours * 3600) : nil
        let todo = Todo(
            title: title,
            notes: notes,
            priority: selectedPriority,
            category: selectedCategory,
            dueDate: hasDueDate ? dueDate : nil,
            reminderDate: reminderDate
        )
        modelContext.insert(todo)
        if let reminderDate {
            Task { await NotificationManager.shared.scheduleReminder(for: todo, at: reminderDate) }
        }
        dismiss()
    }
}

#Preview {
    AddTodoView()
        .modelContainer(for: Todo.self, inMemory: true)
}
