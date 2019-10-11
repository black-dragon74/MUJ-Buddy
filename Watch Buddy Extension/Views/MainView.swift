//
//  ContentView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var dataProvider = DataProvider()
    
    var body: some View {
        
        if (!(self.dataProvider.isUserLoggedIn ?? false)) {
            return AnyView(UserNotLoggedInView().contextMenu {
                Button(action: {
                    self.dataProvider.syncWithiPhone()
                }, label: {
                    VStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Refresh")
                    }
                })
            })
        }

        if (!(self.dataProvider.isAttendanceAvailable ?? false)){
            return AnyView(AttendanceNotAvailableView().contextMenu {
                Button(action: {
                    self.dataProvider.syncWithiPhone()
                }, label: {
                    VStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Refresh")
                    }
                })
            })
        }

        if (self.dataProvider.attendanceData != nil) {
            return AnyView(AttendanceView(attendances: self.dataProvider.attendanceData!).contextMenu{
                Button(action: {
                    self.dataProvider.syncWithiPhone()
                }, label: {
                    VStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Refresh")
                    }
                })
            })
        }

        return AnyView(Text("Loading...").onAppear() {
            self.dataProvider.syncWithiPhone()
        }.contextMenu {
            Button(action: {
                self.dataProvider.syncWithiPhone()
            }, label: {
                VStack{
                    Image(systemName: "arrow.clockwise")
                        .font(.title)
                    Text("Refresh")
                }
            })
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
