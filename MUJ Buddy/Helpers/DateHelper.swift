//
//  DateHelper.swift
//  MUJ Buddy
//
//  Created by Nick on 10/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation

// MARK: - Date Extensions
extension Date {
    func monthsTillNow() -> Int {
        // This will return the months from the given date to current date
        let rawMonths = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
        return rawMonths
    }

    func hoursTillNow() -> Int {
        // Returns interval in hours from the input date to current
        let rawHours = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
        return rawHours
    }
}
