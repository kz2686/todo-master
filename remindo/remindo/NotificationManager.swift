//
//  NotificationManager.swift
//  remindo
//
//  Created by Andrejs Zile on 3/21/26.
//

import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleReminder(for todo: Todo, at date: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Todo Reminder"
        content.body = todo.title
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Use a unique identifier based on the todo's creation date and title
        let identifier = "\(todo.createdAt.timeIntervalSince1970)-\(todo.title)"
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    func cancelReminder(for todo: Todo) {
        let identifier = "\(todo.createdAt.timeIntervalSince1970)-\(todo.title)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }
}
