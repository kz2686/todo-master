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

    // Mon → Sun, with Calendar.weekday values (Sun=1 … Sat=7)
    private let days: [(label: String, weekday: Int)] = [
        ("M", 2), ("T", 3), ("W", 4), ("T", 5), ("F", 6), ("S", 7), ("S", 1)
    ]

    var body: some View {
        ZStack {
            GlassBackground()

            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {

                        // Working days
                        GlassSection(title: "Working Days") {
                            HStack(spacing: 0) {
                                ForEach(days, id: \.weekday) { day in
                                    dayCircle(day)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Working hours
                        GlassSection(title: "Working Hours") {
                            VStack(spacing: 14) {
                                HStack {
                                    Label("Work starts at", systemImage: "sunrise")
                                        .foregroundColor(.white.opacity(0.7))
                                        .fontDesign(.rounded)
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
                                        .fontDesign(.rounded)
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

                        // Current status
                        GlassSection(title: "Current Status") {
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Current time")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontDesign(.rounded)
                                    Spacer()
                                    Text(Date(), style: .time)
                                        .foregroundColor(.white.opacity(0.8))
                                        .fontDesign(.rounded)
                                }

                                Divider().background(Color.white.opacity(0.1))

                                HStack {
                                    Text("Default category")
                                        .foregroundColor(.white.opacity(0.6))
                                        .fontDesign(.rounded)
                                    Spacer()
                                    Label(settings.defaultCategory().rawValue,
                                          systemImage: settings.defaultCategory().icon)
                                        .foregroundColor(settings.defaultCategory().glassColor)
                                        .fontDesign(.rounded)
                                }
                            }
                        }

                        Text("Todos created during working hours on working days default to Work, others to Personal.")
                            .font(.caption)
                            .fontDesign(.rounded)
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

    // MARK: - Day circle

    private func dayCircle(_ day: (label: String, weekday: Int)) -> some View {
        let selected = settings.workingDays.contains(day.weekday)
        return Button {
            withAnimation(.spring(response: 0.25)) {
                var days = settings.workingDays
                if days.contains(day.weekday) {
                    days.remove(day.weekday)
                } else {
                    days.insert(day.weekday)
                }
                settings.workingDays = days
            }
        } label: {
            ZStack {
                Circle()
                    .fill(selected ? LinearGradient.pinkPurple : LinearGradient(colors: [Color.white.opacity(0.08)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(Color.white.opacity(selected ? 0 : 0.15), lineWidth: 0.8)
                    )

                Text(day.label)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(selected ? .white : .white.opacity(0.38))
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

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
