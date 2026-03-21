import SwiftUI

struct CompletedView: View {
    @EnvironmentObject var store: TodoStore

    var body: some View {
        NavigationView {
            Group {
                if store.recentlyCompleted.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(store.recentlyCompleted) { todo in
                            CompletedRowView(todo: todo)
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
            .navigationTitle("Done — Last 7 Days")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.4))
            Text("Nothing completed yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Todos you complete will appear here for 7 days.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
