//
//  ResultsView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 4/16/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        if dataProvider.messageFromIphone!.resultsData == nil {
            return AnyView(TNotAvailableView(t: "result"))
        }

        return AnyView(
            List {
                ForEach(dataProvider.messageFromIphone!.resultsData!, id: \.index) { rslt in
                    VStack(alignment: .leading) {
                        Text(rslt.courseName)
                            .lineLimit(3)
                        Spacer()

                        HStack {
                            Text("Cr: \(rslt.credits)")
                            Spacer()
                            Text("Gr: \(rslt.grade)")
                        }
                    }.padding()
                }.frame(height: 100)
            }.listStyle(CarouselListStyle())
                .navigationBarTitle("Results")
                .modifier(WithLoaderView())
        )
    }
}
