import SwiftUI

struct CompletedView: View {
    @EnvironmentObject var store: TodoStore

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                todoList
                    .navigationTitle("Done — Last 7 Days")
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
        }
    }

    @ViewBuilder
    private var todoList: some View {
        if store.recentlyCompleted.isEmpty {
            emptyState
        } else {
            List {
                ForEach(store.recentlyCompleted) { todo in
                    CompletedRowView(todo: todo)
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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.white.opacity(0.25))
            Text("Nothing completed yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text("Todos you complete will appear here for 7 days.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
