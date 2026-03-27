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
        NavigationStack {
            Form {
                Section {
                    Picker("Work starts at", selection: $settings.workStartHour) {
                        ForEach(0..<24) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                    
                    Picker("Work ends at", selection: $settings.workEndHour) {
                        ForEach(0..<24) { hour in
                            Text(formatHour(hour)).tag(hour)
                        }
                    }
                } header: {
                    Text("Working Hours")
                } footer: {
                    Text("Todos created during working hours will default to Work category, others to Personal.")
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Text("Current time:")
                        Spacer()
                        Text(Date(), style: .time)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Default category:")
                        Spacer()
                        Label(settings.defaultCategory().rawValue, systemImage: settings.defaultCategory().icon)
                            .foregroundStyle(Color(settings.defaultCategory().color))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        guard let date = calendar.date(from: components) else { return "\(hour):00" }
        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView()
}
