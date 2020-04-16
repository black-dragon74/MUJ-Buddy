//
//  UserNotLoggedInView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct UserNotLoggedInView: View {
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "person.badge.minus")
                .foregroundColor(.red)
                .font(.system(.title, design: .rounded))

            Text("You are not logged in. Please login to the MUJ Buddy app on your iPhone to continue.")
                .modifier(RoundedTextWithColor())

            Spacer()
        }
        .navigationBarTitle("MUJ Buddy")
//        .overlay(self.dataProvider.isFetchingData ? LoaderView() : nil)
        .modifier(WithTapToRefresh())
    }
}

// struct UserNotLoggedInView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserNotLoggedInView()
//    }
// }
