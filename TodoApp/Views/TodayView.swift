import SwiftUI

struct TodayView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showingAdd = false

    private var dateTitle: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                todoList
                    .navigationTitle(dateTitle)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            addButton
                        }
                    }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditTodoView()
        }
    }

    @ViewBuilder
    private var todoList: some View {
        if store.todayTodos.isEmpty {
            emptyState
        } else {
            List {
                ForEach(store.todayTodos) { todo in
                    TodoRowView(todo: todo)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { store.delete(todo) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
        }
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(LinearGradient.pinkPurple)
            Text("All clear!")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text("Nothing due today. Tap + to add something.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
