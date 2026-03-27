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
    private let workEndHourKey = "workEndHour"
    
    var workStartHour: Int {
        get {
            let value = defaults.integer(forKey: workStartHourKey)
            return value == 0 ? 9 : value // Default 9 AM
        }
        set {
            defaults.set(newValue, forKey: workStartHourKey)
        }
    }
    
    var workEndHour: Int {
        get {
            let value = defaults.integer(forKey: workEndHourKey)
            return value == 0 ? 17 : value // Default 5 PM
        }
        set {
            defaults.set(newValue, forKey: workEndHourKey)
        }
    }
    
    private init() {}
    
    func isWorkingHours() -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        return hour >= workStartHour && hour < workEndHour
    }
    
    func defaultCategory() -> Todo.Category {
        return isWorkingHours() ? .work : .personal
    }
}
