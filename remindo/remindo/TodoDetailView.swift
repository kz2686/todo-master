//
//  TodoDetailView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var todo: Todo
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("What needs to be done?", text: $todo.title, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if !todo.notes.isEmpty {
                    Section("Notes") {
                        Text(todo.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Details") {
                    HStack {
                        Text("Category")
                        Spacer()
                        Label(todo.category.rawValue, systemImage: todo.category.icon)
                            .foregroundStyle(Color(todo.category.color))
                    }
                    
                    HStack {
                        Text("Priority")
                        Spacer()
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(todo.priority.color))
                                .frame(width: 8, height: 8)
                            Text(todo.priority.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let dueDate = todo.dueDate {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Text(dueDate, style: .date)
                                .foregroundStyle(.secondary)
                            Text(dueDate, style: .time)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Text("None")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    
                    if let reminderDate = todo.reminderDate {
                        HStack {
                            Text("Reminder")
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(reminderDate, style: .date)
                                    .foregroundStyle(.secondary)
                                Text(reminderDate, style: .time)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(todo.isCompleted ? "Completed" : "Not completed")
                            .foregroundStyle(todo.isCompleted ? .green : .secondary)
                    }
                }
                
                Section {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(todo.createdAt, style: .date)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Todo Details")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
