import SwiftUI

struct AllTodosView: View {
    @EnvironmentObject var store: TodoStore
    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            Group {
                if store.allIncompleteTodos.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.allIncompleteTodos) { todo in
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
            .navigationTitle("All Todos")
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
            Image(systemName: "tray")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.4))
            Text("No todos yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to capture something you need to do.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
