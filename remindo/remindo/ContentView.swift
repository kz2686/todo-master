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

        if let category = selectedCategory {
            todos = todos.filter { $0.category == category }
        }

        return todos.sorted { t1, t2 in
            if t1.priority.rawValue != t2.priority.rawValue {
                return t1.priority.rawValue > t2.priority.rawValue
            }
            if let d1 = t1.dueDate, let d2 = t2.dueDate { return d1 < d2 }
            if t1.dueDate != nil { return true }
            if t2.dueDate != nil { return false }
            return t1.createdAt < t2.createdAt
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GlassBackground()

                VStack(spacing: 0) {
                    filterBar
                    todoList
                }
            }
            .navigationTitle("Remindo")
            .preferredColorScheme(.dark)
                .navigationBarTitleDisplayMode(.large)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
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
                                .foregroundColor(.white)
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button { showingAddTodo = true } label: {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.pinkPurple)
                                    .frame(width: 32, height: 32)
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddTodo) { AddTodoView() }
                .sheet(item: $selectedTodo) { todo in TodoDetailView(todo: todo) }
                .sheet(isPresented: $showingSettings) { SettingsView() }
                .sheet(isPresented: $showingHistory) { HistoryView() }
                .task { await NotificationManager.shared.requestAuthorization() }
            }
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        VStack(spacing: 10) {
            // Main filter
            HStack(spacing: 8) {
                ForEach(FilterType.allCases, id: \.self) { filter in
                    filterChip(filter.rawValue, selected: selectedFilter == filter) {
                        withAnimation(.spring(response: 0.3)) { selectedFilter = filter }
                    }
                }
            }
            .padding(.horizontal)

            // Category filter
            HStack(spacing: 8) {
                categoryChip("All", icon: "square.grid.2x2", selected: selectedCategory == nil) {
                    withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                }
                ForEach(Todo.Category.allCases, id: \.self) { cat in
                    categoryChip(cat.rawValue, icon: cat.icon, color: cat.glassColor, selected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.3)) { selectedCategory = cat }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func filterChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(selected ? LinearGradient.pinkPurple : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(selected ? .white : .white.opacity(0.45))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(selected ? 0 : 0.12), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func categoryChip(_ label: String, icon: String, color: Color = .white.opacity(0.4), selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(0.5)
                .textCase(.uppercase)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(selected ? color.opacity(0.2) : Color.white.opacity(0.06))
                .foregroundColor(selected ? color : .white.opacity(0.38))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? color.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Todo list

    @ViewBuilder
    private var todoList: some View {
        if filteredTodos.isEmpty {
            emptyStateView
        } else {
            List {
                ForEach(filteredTodos) { todo in
                    Button { selectedTodo = todo } label: {
                        TodoRowView(todo: todo) { toggleTodo(todo) }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .onDelete(perform: deleteTodos)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: selectedFilter == .today ? "checkmark.circle.fill" : "tray")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(LinearGradient.pinkPurple)
            Text(selectedFilter == .today ? "All clear!" : "No todos")
                .font(.title2)
                .fontWeight(.black)
                .fontDesign(.rounded)
                .foregroundColor(.white)
            Text("Tap + to add something.")
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func toggleTodo(_ todo: Todo) {
        withAnimation {
            todo.isCompleted.toggle()
            todo.completedAt = todo.isCompleted ? Date() : nil
            if todo.isCompleted {
                NotificationManager.shared.cancelReminder(for: todo)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Todo.self, inMemory: true)
}
