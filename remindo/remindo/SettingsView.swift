//
//  SettingsView.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings = AppSettings.shared

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        GlassSection(title: "Working Hours") {
                            VStack(spacing: 14) {
                                HStack {
                                    Label("Work starts at", systemImage: "sunrise")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Picker("", selection: $settings.workStartHour) {
                                        ForEach(0..<24) { hour in
                                            Text(formatHour(hour)).tag(hour)
                                        }
                                    }
                                    .tint(.accentPink)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                HStack {
                                    Label("Work ends at", systemImage: "sunset")
                                        .foregroundColor(.white.opacity(0.7))
                                    Spacer()
                                    Picker("", selection: $settings.workEndHour) {
                                        ForEach(0..<24) { hour in
                                            Text(formatHour(hour)).tag(hour)
                                        }
                                    }
                                    .tint(.accentPink)
                                }
                            }
                        }

                        GlassSection(title: "Current Status") {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Current time")
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text(Date(), style: .time)
                                        .foregroundColor(.white.opacity(0.8))
                                }

                                Divider().background(Color.white.opacity(0.1))

                                HStack {
                                    Text("Default category")
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Label(settings.defaultCategory().rawValue,
                                          systemImage: settings.defaultCategory().icon)
                                        .foregroundColor(settings.defaultCategory().glassColor)
                                }
                            }
                        }

                        Text("Todos created during working hours default to Work, others to Personal.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Settings")
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

    private func formatHour(_ hour: Int) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:00 a"
        var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        c.hour = hour
        guard let date = Calendar.current.date(from: c) else { return "\(hour):00" }
        return f.string(from: date)
    }
}

#Preview {
    SettingsView()
}
