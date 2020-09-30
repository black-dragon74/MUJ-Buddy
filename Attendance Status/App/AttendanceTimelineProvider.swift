//
//  TimelineProvider.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AttendanceTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> AttendanceTimelineEntry {
        let date = Date()
        let loggedInStatus = isLoggedIn()
        let lowAttendanceCount = getLowAttendanceCount()
        
        return AttendanceTimelineEntry(date: date, isLoggedIn: loggedInStatus, lowAttendanceCount: lowAttendanceCount)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AttendanceTimelineEntry) -> ()) {
        let date = Date()
        let loggedInStatus = isLoggedIn()
        let lowAttendanceCount = getLowAttendanceCount()
        
        let entry = AttendanceTimelineEntry(date: date, isLoggedIn: loggedInStatus, lowAttendanceCount: lowAttendanceCount)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AttendanceTimelineEntry>) -> ()) {
        var entries: [AttendanceTimelineEntry] = []
        
        let currentDate = Date()
        let loggedInStatus = isLoggedIn()
        let lowAttendanceCount = getLowAttendanceCount()
        
        let entry = AttendanceTimelineEntry(date: currentDate, isLoggedIn: loggedInStatus, lowAttendanceCount: lowAttendanceCount)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
