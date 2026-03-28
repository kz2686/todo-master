//
//  AppSettings.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import Foundation

@Observable
class AppSettings {
    static let shared = AppSettings()

    private let defaults = UserDefaults.standard
    private let workStartHourKey = "workStartHour"
    private let workEndHourKey   = "workEndHour"
    private let workingDaysKey   = "workingDays"

    // Default: Mon–Fri (Calendar.weekday: Sun=1, Mon=2 … Sat=7)
    private static let defaultWorkingDays: Set<Int> = [2, 3, 4, 5, 6]

    var workStartHour: Int {
        get {
            let v = defaults.integer(forKey: workStartHourKey)
            return v == 0 ? 9 : v
        }
        set { defaults.set(newValue, forKey: workStartHourKey) }
    }

    var workEndHour: Int {
        get {
            let v = defaults.integer(forKey: workEndHourKey)
            return v == 0 ? 17 : v
        }
        set { defaults.set(newValue, forKey: workEndHourKey) }
    }

    var workingDays: Set<Int> {
        get {
            guard let stored = defaults.array(forKey: workingDaysKey) as? [Int] else {
                return Self.defaultWorkingDays
            }
            return Set(stored)
        }
        set { defaults.set(Array(newValue), forKey: workingDaysKey) }
    }

    private init() {}

    func isWorkingHours() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour    = calendar.component(.hour,    from: now)
        let weekday = calendar.component(.weekday, from: now)
        return workingDays.contains(weekday) && hour >= workStartHour && hour < workEndHour
    }

    func defaultCategory() -> Todo.Category {
        return isWorkingHours() ? .work : .personal
    }
}
