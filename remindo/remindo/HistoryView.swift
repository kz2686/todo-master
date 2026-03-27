//
//  HistoryView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allTodos: [Todo]
    
    @State private var selectedCategory: Todo.Category?
    
    private var completedTodos: [Todo] {
        allTodos.filter { todo in
            guard todo.isCompleted, let completedAt = todo.completedAt else { return false }
            
            // Filter by category if selected
            if let category = selectedCategory, todo.category != category {
                return false
            }
            
            // Only show todos completed in last 7 days
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            return completedAt >= sevenDaysAgo
        }
    }
    
    private var groupedByDay: [(Date, [Todo])] {
        let calendar = Calendar.current
        
        // Group todos by day
        let grouped = Dictionary(grouping: completedTodos) { todo -> Date in
            let completedAt = todo.completedAt ?? todo.createdAt
            return calendar.startOfDay(for: completedAt)
        }
        
        // Sort by date descending (most recent first)
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                Picker("Category", selection: $selectedCategory) {
                    Text("All").tag(nil as Todo.Category?)
                    ForEach(Todo.Category.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category as Todo.Category?)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if groupedByDay.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(groupedByDay, id: \.0) { date, todos in
                            Section {
                                ForEach(todos) { todo in
                                    HStack(spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(todo.title)
                                                .font(.body)
                                            
                                            HStack(spacing: 8) {
                                                Label(todo.category.rawValue, systemImage: todo.category.icon)
                                                    .font(.caption)
                                                    .foregroundStyle(Color(todo.category.color))
                                                
                                                if todo.priority != .none {
                                                    HStack(spacing: 4) {
                                                        Circle()
                                                            .fill(Color(todo.priority.color))
                                                            .frame(width: 6, height: 6)
                                                        Text(todo.priority.displayName)
                                                    }
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                }
                                                
                                                if let completedAt = todo.completedAt {
                                                    Text(completedAt, style: .time)
                                                        .font(.caption)
                                                        .foregroundStyle(.tertiary)
                                                }
                                            }
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                HStack {
                                    Text(formatSectionDate(date))
                                        .font(.headline)
                                    Spacer()
                                    Text("\(todos.count) completed")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("History")
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
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("No completed todos")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Completed todos from the last 7 days will appear here")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Todo.self, inMemory: true)
}
