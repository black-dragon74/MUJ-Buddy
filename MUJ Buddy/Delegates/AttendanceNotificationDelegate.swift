//
//  NotificationDelegate.swift
//  MUJ Buddy
//
//  Created by Nick on 2/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UserNotifications

//
//  Acts as a notification delegate for the MUJ attendance notifications
//

class AttendanceDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    var delegate: AttendanceNotificationDelegate?
    
    // Notification received while app is open
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Just display the notification for now
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let del = delegate else { return }
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            del.handleNotificationTap(identifier: "Default")
            completionHandler()
        case UNNotificationDismissActionIdentifier:
            completionHandler()
        default:
            completionHandler()
            break
        }
    }
}

protocol AttendanceNotificationDelegate {
    func handleNotificationTap(identifier: String)
}
