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
        // Initialize with default category based on working hours
        _selectedCategory = State(initialValue: AppSettings.shared.defaultCategory())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What needs to be done?", text: $title, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Notes") {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Todo.Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(Todo.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(priority.color))
                                    .frame(width: 8, height: 8)
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("Due Date")
                } footer: {
                    if !hasDueDate {
                        Text("Todos without a due date always appear in today's list")
                            .font(.caption)
                    }
                }
                
                Section {
                    Toggle("Remind me if not done", isOn: $hasReminder)
                    
                    if hasReminder {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Remind me in \(Int(reminderHours)) hour\(reminderHours == 1 ? "" : "s")")
                                .font(.subheadline)
                            
                            Slider(value: $reminderHours, in: 1...24, step: 1)
                        }
                    }
                } header: {
                    Text("Reminder")
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("New Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveTodo()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
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
        
        if let reminderDate = reminderDate {
            scheduleNotification(for: todo, at: reminderDate)
        }
        
        dismiss()
    }
    
    private func scheduleNotification(for todo: Todo, at date: Date) {
        Task {
            await NotificationManager.shared.scheduleReminder(for: todo, at: date)
        }
    }
}

#Preview {
    AddTodoView()
        .modelContainer(for: Todo.self, inMemory: true)
}

