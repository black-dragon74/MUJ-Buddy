//
//  App.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct AttendanceWidget: Widget {
    let kind: String = "com.mujbuddy.widgetkit.attendance-widget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AttendanceTimelineProvider()) { entry in
            AttendanceWidgetView(entry: entry)
        }
        .configurationDisplayName("MUJ Buddy Attendance")
        .description("A glance at your attendance status")
        .supportedFamilies([.systemSmall])
    }
}
