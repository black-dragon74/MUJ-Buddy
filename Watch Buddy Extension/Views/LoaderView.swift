//
//  LoaderView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 4/16/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct LoaderView: View {
    @State private var isSpinning = false

    var body: some View {
        if #available(watchOSApplicationExtension 7.0, *) {
            VStack (alignment: .center, spacing: 15, content: {
                ProgressView()
                    .frame(width: 40, height: 40)
                
                Text("Please wait")
            })
        } else {
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Spacer()
                    Image(systemName: "arrow.2.circlepath.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .rotationEffect(Angle(degrees: isSpinning ? 360 : 0))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
    
                    Text("Please wait")
                    Spacer()
                }
                Spacer()
            }.background(Color.black)
                .onAppear {
                    self.isSpinning.toggle()
                }
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
