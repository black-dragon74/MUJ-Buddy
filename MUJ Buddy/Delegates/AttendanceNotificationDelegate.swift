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

class AttendanceNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Notification received while app is open
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Just display the notification for now
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            NotificationCenter.default.post(name: .didTapOnAttendanceNotification, object: nil)
            // Call the completion handler
            completionHandler()
        case UNNotificationDismissActionIdentifier:
            completionHandler()
        default:
            completionHandler()
        }
    }
}
