//
//  AttendanceEntry.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AttendanceTimelineEntry: TimelineEntry {
    let date: Date
    let isLoggedIn: Bool
    let isAttendanceAvailable = getAttendanceFromDB() != nil
    let lowAttendanceCount: Int
}
                                              
