//
//  AttendanceView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct AttendanceView: View {
    
    // Placeholder data
    let attendances: [AttendanceModel]
    
    // Card list platter colors
    var cardColors = [
        Color(#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1)),
        Color(#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1)),
        Color(#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1)),
        Color(#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)),
        Color(#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1)),
        Color(#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1)),
        Color(#colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)),
        Color(#colorLiteral(red: 0.00491155684, green: 0.287129879, blue: 0.7411141396, alpha: 1)),
        Color(#colorLiteral(red: 0, green: 0.6073564887, blue: 0.7661359906, alpha: 1))
    ]
    
    // The main view
    var body: some View {
        List {
            ForEach(attendances, id:\.index) { atn in
                VStack(alignment: .leading) {
                    Text(atn.course)
                        .multilineTextAlignment(.leading)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("\(atn.percentage)")
                        .font(.system(.subheadline, design: .rounded))
                    }
                    
                }.padding([.top, .bottom])
                    .listRowPlatterColor(self.cardColors[Int.random(in: 0..<self.cardColors.count)])
            }.frame(height: 100)
        }.navigationBarTitle("Attendance")
        .listStyle(CarouselListStyle())
    }
}

//struct AttendanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//    }
//}
