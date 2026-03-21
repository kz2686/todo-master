import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showingAdd = false

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            Group {
                if store.todayTodos.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.todayTodos) { todo in
                            TodoRowView(todo: todo)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        store.delete(todo)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(dateTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditTodoView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green.opacity(0.5))
            Text("All clear!")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Nothing due today. Tap + to add a todo.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
