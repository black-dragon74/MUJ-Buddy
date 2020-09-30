//
//  AttendanceView.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct AttendanceView: View {
    var lowCount: Int = 2
    
    var body: some View {
        Circle()
            .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
            .foregroundColor(getColorFromCount())
        
        VStack {
            if (lowCount == 0) {
                Text("All good\n🔥")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            }
            else {
                Text("\(lowCount)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text(getLowString())
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
    }
    
    fileprivate func getColorFromCount() -> Color {
        return (lowCount > 0) ? .red : .green
    }
    
    fileprivate func getLowString() -> String {
        return (lowCount == 1) ? "Subject has low attendance" : "Subjects have low attendance"
    }
}
