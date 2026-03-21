import Foundation
import Combine

class TodoStore: ObservableObject {
    @Published var todos: [Todo] = []

    private let storageKey = "todos_v1"

    init() {
        load()
    }

    // MARK: - Filtered Views

    var todayTodos: [Todo] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        return todos
            .filter { todo in
                guard !todo.isCompleted else { return false }
                if let due = todo.dueDate {
                    return due >= today && due < tomorrow
                }
                return true // no due date → always show in Today
            }
            .sorted(by: sortTodos)
    }

    var allIncompleteTodos: [Todo] {
        todos
            .filter { !$0.isCompleted }
            .sorted(by: sortTodos)
    }

    var recentlyCompleted: [Todo] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return todos
            .filter { todo in
                guard todo.isCompleted, let completedAt = todo.completedAt else { return false }
                return completedAt >= cutoff
            }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }

    // MARK: - Sort

    private func sortTodos(_ a: Todo, _ b: Todo) -> Bool {
        let aPriority = a.priority?.sortOrder ?? 3
        let bPriority = b.priority?.sortOrder ?? 3
        if aPriority != bPriority { return aPriority < bPriority }

        switch (a.dueDate, b.dueDate) {
        case (let d1?, let d2?): return d1 < d2
        case (nil, _?):          return false
        case (_?, nil):          return true
        case (nil, nil):         return a.createdAt < b.createdAt
        }
    }

    // MARK: - CRUD

    func add(_ todo: Todo) {
        todos.append(todo)
        save()
    }

    func update(_ todo: Todo) {
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[idx] = todo
        save()
    }

    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        save()
    }

    func toggleComplete(_ todo: Todo) {
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[idx].isCompleted.toggle()
        todos[idx].completedAt = todos[idx].isCompleted ? Date() : nil
        save()
    }

    // MARK: - Persistence

    private func save() {
        guard let data = try? JSONEncoder().encode(todos) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let saved = try? JSONDecoder().decode([Todo].self, from: data)
        else { return }
        todos = saved
    }
}
