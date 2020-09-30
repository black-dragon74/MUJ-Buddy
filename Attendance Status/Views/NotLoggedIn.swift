//
//  NotLoggedIn.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct NotLoggedIn: View {
    var body: some View {
        VStack {
            Text("You are not logged in. Please open the app and login")
                .font(.title)
                .foregroundColor(.white)
        }.padding()
    }
}
