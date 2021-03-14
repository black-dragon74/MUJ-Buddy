//
//  AttendanceNotAvailableView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct TNotAvailableView: View {
    var t: String
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "xmark.icloud")
                .font(.system(.title, design: .rounded))
                .foregroundColor(.yellow)

            Text("No \(t) data found on your iPhone. Please fetch the \(t) at least once and try again.")
                .modifier(RoundedTextWithColor())
            Spacer()
        }
        .navigationBarTitle("MUJ Buddy")
//        .overlay(self.dataProvider.isFetchingData ? LoaderView() : nil)
        .modifier(WithLoaderView())
    }
}

struct TNotAvailableView_Previews: PreviewProvider {
    static var previews: some View {
        TNotAvailableView(t: "Test")
            .environmentObject(DataProvider.shared)
    }
}
