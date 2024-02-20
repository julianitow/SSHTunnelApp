//
//  NotificationService.swift
//  SSHTunneling
//
//  Created by Julien Guillan on 22/12/2023.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static var authorized = false
    static var center = UNUserNotificationCenter.current()
    
    static func exitCodeToBody(code: Int32) -> String {
        switch code {
        case 0:
            return "Connection closed normally"
        case 999:
            return "Connection closed due to a problem"
        default:
            return "Connection refused"
        }
    }
    
    static func requestAuthorization() -> Void {
        center.requestAuthorization(options: [.criticalAlert, .alert, .badge, .sound]) { (granted, error) in
            NotificationService.authorized = granted
        }
    }

    static func emitNotification(id: UUID?, title: String, body: String) -> Void {
        if (!NotificationService.authorized) {
            return
        }
        let content = UNMutableNotificationContent();
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        let request = UNNotificationRequest(identifier: id != nil ? id!.uuidString : UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}
