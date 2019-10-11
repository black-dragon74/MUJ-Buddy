//
//  AttendanceNotAvailableView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct AttendanceNotAvailableView: View {
    var body: some View {
        VStack {
            Image(systemName: "xmark.icloud")
                .font(.system(.title, design: .rounded))
                .foregroundColor(.yellow)
            
            Text("No attendance data found on your iPhone. Please fetch the attedance at least once and try again.")
                .modifier(RoundedTextWithColor())
        }
        .navigationBarTitle("MUJ Buddy")
    }
}

struct AttendanceNotAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceNotAvailableView()
    }
}
