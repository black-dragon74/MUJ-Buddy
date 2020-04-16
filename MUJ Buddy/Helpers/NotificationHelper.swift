//
//  NotificationHelper.swift
//  MUJ Buddy
//
//  Created by Nick on 2/6/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UserNotifications

//
//  Helper class to return a prepared notification request to present
//

func prepareNotification(withBody: String) -> UNNotificationRequest {
    let content: UNMutableNotificationContent = {
        let c = UNMutableNotificationContent()
        c.title = "Attendance"
        c.body = withBody
        c.sound = UNNotificationSound.default
        return c
    }()

    let identifier = "notif\(Int.random(in: 1 ... 234_213))"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

    return request
}
