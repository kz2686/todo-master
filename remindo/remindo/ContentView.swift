//
//  ContentView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTodos: [Todo]
    
    @State private var showingAddTodo = false
    @State private var selectedFilter: FilterType = .today
    @State private var selectedCategory: Todo.Category?
    @State private var selectedTodo: Todo?
    @State private var showingSettings = false
    @State private var showingHistory = false
    
    enum FilterType: String, CaseIterable {
        case today = "Today"
        case upcoming = "Upcoming"
        case all = "All"
    }
    
    private var filteredTodos: [Todo] {
        var todos: [Todo]
        
        switch selectedFilter {
        case .today:
            todos = allTodos.filter { !$0.isCompleted && $0.shouldShowToday }
        case .upcoming:
            todos = allTodos.filter { !$0.isCompleted && $0.dueDate != nil && !$0.shouldShowToday }
        case .all:
            todos = allTodos.filter { !$0.isCompleted }
        }
        
        // Filter by category if selected
        if let category = selectedCategory {
            todos = todos.filter { $0.category == category }
        }
        
        // Sort by priority (high to low) then by due date
        return todos.sorted { todo1, todo2 in
            if todo1.priority.rawValue != todo2.priority.rawValue {
                return todo1.priority.rawValue > todo2.priority.rawValue
            }
            
            if let date1 = todo1.dueDate, let date2 = todo2.dueDate {
                return date1 < date2
            }
            
            if todo1.dueDate != nil {
                return true
            }
            
            if todo2.dueDate != nil {
                return false
            }
            
            return todo1.createdAt < todo2.createdAt
        }
    }
    
    private var completedTodos: [Todo] {
        var todos = allTodos.filter { $0.isCompleted }
        
        // Filter by category if selected
        if let category = selectedCategory {
            todos = todos.filter { $0.category == category }
        }
        
        return todos.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter picker
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Category filter
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(nil as Todo.Category?)
                        ForEach(Todo.Category.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category as Todo.Category?)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Main content
                    if filteredTodos.isEmpty && completedTodos.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            if !filteredTodos.isEmpty {
                                Section {
                                    ForEach(filteredTodos) { todo in
                                        Button {
                                            selectedTodo = todo
                                        } label: {
                                            TodoRowView(todo: todo) {
                                                toggleTodo(todo)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .listRowBackground(Color.clear)
                                    }
                                    .onDelete(perform: deleteTodos)
                                }
                            }
                            
                            if !completedTodos.isEmpty {
                                Section("Completed") {
                                    ForEach(completedTodos) { todo in
                                        Button {
                                            selectedTodo = todo
                                        } label: {
                                            TodoRowView(todo: todo) {
                                                toggleTodo(todo)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .listRowBackground(Color.clear)
                                    }
                                    .onDelete(perform: deleteCompletedTodos)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Remindo")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showingHistory = true
                        } label: {
                            Label("History", systemImage: "clock.arrow.circlepath")
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTodo = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTodo) {
                AddTodoView()
            }
            .sheet(item: $selectedTodo) { todo in
                TodoDetailView(todo: todo)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .task {
                await NotificationManager.shared.requestAuthorization()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text(selectedFilter == .today ? "Nothing for today" : "No todos")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Tap + to add a new todo")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func toggleTodo(_ todo: Todo) {
        withAnimation {
            todo.isCompleted.toggle()
            
            if todo.isCompleted {
                // Set completion date and cancel reminder
                todo.completedAt = Date()
                NotificationManager.shared.cancelReminder(for: todo)
            } else {
                // Clear completion date
                todo.completedAt = nil
            }
        }
    }
    
    private func deleteTodos(at offsets: IndexSet) {
        for index in offsets {
            let todo = filteredTodos[index]
            NotificationManager.shared.cancelReminder(for: todo)
            modelContext.delete(todo)
        }
    }
    
    private func deleteCompletedTodos(at offsets: IndexSet) {
        for index in offsets {
            let todo = completedTodos[index]
            modelContext.delete(todo)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Todo.self, inMemory: true)
}
