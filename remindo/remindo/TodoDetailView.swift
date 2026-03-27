//
//  TodoDetailView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var todo: Todo

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        // Title
                        GlassSection(title: "Title") {
                            HStack(alignment: .top, spacing: 14) {
                                ZStack {
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    if todo.isCompleted {
                                        Circle()
                                            .fill(LinearGradient.pinkPurple)
                                            .frame(width: 22, height: 22)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.top, 2)

                                TextField("Title", text: $todo.title, axis: .vertical)
                                    .lineLimit(3...6)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .tint(.accentPink)
                                    .strikethrough(todo.isCompleted, color: .white.opacity(0.35))
                            }
                        }

                        // Notes
                        GlassSection(title: "Notes") {
                            if todo.notes.isEmpty {
                                Text("No notes added.")
                                    .foregroundColor(.white.opacity(0.35))
                                    .italic()
                            } else {
                                Text(todo.notes)
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        // Details
                        GlassSection(title: "Details") {
                            VStack(spacing: 14) {
                                detailRow("Category") {
                                    Label(todo.category.rawValue, systemImage: todo.category.icon)
                                        .foregroundColor(todo.category.glassColor)
                                        .font(.subheadline)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                detailRow("Priority") {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(todo.priority.glassColor)
                                            .frame(width: 8, height: 8)
                                        Text(todo.priority.displayName)
                                            .foregroundColor(.white.opacity(0.7))
                                            .font(.subheadline)
                                    }
                                }

                                Divider().background(Color.white.opacity(0.1))

                                detailRow("Due Date") {
                                    if let dueDate = todo.dueDate {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(dueDate, style: .date)
                                            Text(dueDate, style: .time)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    } else {
                                        Text("None")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.3))
                                    }
                                }

                                if let reminderDate = todo.reminderDate {
                                    Divider().background(Color.white.opacity(0.1))

                                    detailRow("Reminder") {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(reminderDate, style: .date)
                                            Text(reminderDate, style: .time)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                Divider().background(Color.white.opacity(0.1))

                                detailRow("Status") {
                                    Text(todo.isCompleted ? "Completed" : "Open")
                                        .font(.subheadline)
                                        .foregroundColor(todo.isCompleted ? Color(red: 0.19, green: 0.82, blue: 0.61) : .white.opacity(0.5))
                                }
                            }
                        }

                        // Created date
                        GlassSection {
                            detailRow("Created") {
                                Text(todo.createdAt, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Details")
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

    private func detailRow<T: View>(_ label: String, @ViewBuilder value: () -> T) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            value()
        }
    }
}
