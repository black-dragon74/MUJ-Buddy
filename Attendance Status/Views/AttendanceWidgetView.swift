//
//  AttendanceWidgetView.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AttendanceWidgetView: View {
    let entry: AttendanceTimelineProvider.Entry

    var body: some View {
        ZStack {
            if !entry.isLoggedIn {
                GenericNAView(message: "You are not logged in.\n\nPlease open the app and login to view the attendance status.")
            }
            else if entry.isLoggedIn && !entry.isAttendanceAvailable {
                GenericNAView(message: "Attendance has not been fetched yet.\n\nPlease fetch it atleast once to view status.")
            }
            else {
                AttendanceView(lowCount: entry.lowAttendanceCount)
            }
        }
        .background(Image("manipal").overlay(Color.black.opacity(0.8)))
        .padding()
    }
}

struct AttendanceWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceWidgetView(entry: AttendanceTimelineEntry(date: Date(), isLoggedIn: true, lowAttendanceCount: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
