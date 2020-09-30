//
//  GenericNAView.swift
//  Attendance StatusExtension
//
//  Created by Nick on 9/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct GenericNAView: View {
    let message: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(message)
                .foregroundColor(.white)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
}
