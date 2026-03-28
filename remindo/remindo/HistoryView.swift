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
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return allTodos.filter { todo in
            guard todo.isCompleted, let completedAt = todo.completedAt else { return false }
            if let category = selectedCategory, todo.category != category { return false }
            return completedAt >= sevenDaysAgo
        }
    }

    private var groupedByDay: [(Date, [Todo])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: completedTodos) { todo -> Date in
            calendar.startOfDay(for: todo.completedAt ?? todo.createdAt)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                VStack(spacing: 0) {
                    // Category filter chips
                    HStack(spacing: 8) {
                        categoryChip("All", icon: "square.grid.2x2", color: .white.opacity(0.5), selected: selectedCategory == nil) {
                            withAnimation { selectedCategory = nil }
                        }
                        ForEach(Todo.Category.allCases, id: \.self) { cat in
                            categoryChip(cat.rawValue, icon: cat.icon, color: cat.glassColor, selected: selectedCategory == cat) {
                                withAnimation { selectedCategory = cat }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)

                    if groupedByDay.isEmpty {
                        emptyStateView
                    } else {
                        List {
                            ForEach(groupedByDay, id: \.0) { date, todos in
                                Section {
                                    ForEach(todos) { todo in
                                        historyRow(todo)
                                            .listRowBackground(Color.clear)
                                            .listRowSeparator(.hidden)
                                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    }
                                } header: {
                                    HStack {
                                        Text(formatSectionDate(date))
                                            .font(.subheadline)
                                            .fontWeight(.black)
                                            .fontDesign(.rounded)
                                            .foregroundColor(.white.opacity(0.75))
                                        Spacer()
                                        Text("\(todos.count) done")
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .fontDesign(.rounded)
                                            .tracking(0.5)
                                            .textCase(.uppercase)
                                            .foregroundColor(.white.opacity(0.35))
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private func historyRow(_ todo: Todo) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient.pinkPurple.opacity(0.45))
                    .frame(width: 26, height: 26)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 7) {
                Text(todo.title)
                    .font(.body)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.white.opacity(0.5))
                    .strikethrough(true, color: .white.opacity(0.28))

                HStack(spacing: 8) {
                    MetaBadge(
                        text: todo.category.rawValue,
                        icon: todo.category.icon,
                        color: todo.category.glassColor.opacity(0.7)
                    )

                    if todo.priority != .none {
                        MetaBadge(
                            text: todo.priority.displayName,
                            color: todo.priority.glassColor.opacity(0.7)
                        )
                    }

                    if let completedAt = todo.completedAt {
                        MetaBadge(
                            text: completedAt.formatted(date: .omitted, time: .shortened),
                            icon: "clock",
                            color: .white.opacity(0.28)
                        )
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .glassCard(cornerRadius: 14)
    }

    private func categoryChip(_ label: String, icon: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .tracking(0.5)
                .textCase(.uppercase)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selected ? color.opacity(0.2) : Color.white.opacity(0.06))
                .foregroundColor(selected ? color : .white.opacity(0.45))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(selected ? color.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(LinearGradient.pinkPurple)
            Text("No completed todos")
                .font(.title2)
                .fontWeight(.black)
                .fontDesign(.rounded)
                .foregroundColor(.white)
            Text("Completed todos from the last 7 days will appear here.")
                .font(.subheadline)
                .fontDesign(.rounded)
                .foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formatSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date)     { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: Todo.self, inMemory: true)
}
