//
//  AttendanceView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct AttendanceView: View {
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        if dataProvider.messageFromIphone!.attendanceData == nil {
            return AnyView(TNotAvailableView(t: "attendance"))
        }

        return AnyView(
            List {
                ForEach(dataProvider.messageFromIphone!.attendanceData!, id: \.index) { attendance in
                    VStack(alignment: .leading) {
                        Text(attendance.course)
                            .lineLimit(3)
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(attendance.percentage) %")
                            Spacer()
                        }
                        Spacer()
                        HStack {
                            Text("P: \(attendance.present)")
                            Spacer()
                            Text("A: \(attendance.present)")
                        }
                    }.padding()
                }.frame(height: 150)
            }.listStyle(CarouselListStyle())
                .navigationBarTitle("Attendance")
                .modifier(WithTapToRefresh())
        )
    }
}

// struct AttendanceView_Previews: PreviewProvider {
//
//
//    static var previews: some View {
//
//    }
// }
