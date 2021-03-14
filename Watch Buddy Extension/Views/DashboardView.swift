//
//  DashboardView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 4/15/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

private let menuItems: [DashboardModel] = [
    DashboardModel(title: "Attendance", icon: "attendance"),
    DashboardModel(title: "Internals", icon: "internals"),
    DashboardModel(title: "Results", icon: "results"),
]

private let tileColor = Color(red: 36 / 255, green: 36 / 255, blue: 36 / 255)

struct DashboardView: View {
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        if (dataProvider.messageFromIphone?.loggedIn ?? false) == false && !dataProvider.isFetchingData {
            return AnyView(UserNotLoggedInView())
        }

        return AnyView(
            ScrollView {
                VStack(spacing: 5) {
                    HStack {
                        Image("student")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .background(Color.purple)
                            .clipShape(Circle())
                            .padding([.leading], 5)

                        Text(dataProvider.messageFromIphone?.name ?? "NA")
                            .lineLimit(2)

                        Spacer()
                    }
                    .frame(height: 60)
                    .background(tileColor)
                    .cornerRadius(10)

                    Spacer()

                    ForEach(menuItems, id: \.title) { item in
                        NavigationLink(destination: self.getViewFrom(title: item.title)) {
                            HStack(spacing: 4) {
                                Image(item.icon)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())

                                Text(item.title)

                                Spacer()
                            }.padding([.leading, .top, .bottom], 5)
                                .background(tileColor)
                                .cornerRadius(10)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }.navigationBarTitle("MUJ Buddy")
//                .overlay(self.dataProvider.isFetchingData ? LoaderView() : nil)
                .modifier(WithLoaderView())
        )
    }
    
    fileprivate func genView<T: View>(_ retView: T) -> AnyView {
        return AnyView(retView.modifier(WithDataProvider()))
    }

    fileprivate func getViewFrom(title: String) -> AnyView {
        switch title {
        case "Attendance":
            return genView(AttendanceView())
        case "Internals":
            return genView(InternalsView())
        case "Results":
            return genView(ResultsView())
        default:
            return genView(UserNotLoggedInView())
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
