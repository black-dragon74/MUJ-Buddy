//
//  InternalsView.swift
//  Watch Buddy Extension
//
//  Created by Nick on 4/16/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import SwiftUI

struct InternalsView: View {
    @EnvironmentObject var dataProvider: DataProvider

    var body: some View {
        if dataProvider.messageFromIphone!.internalsData == nil {
            return AnyView(TNotAvailableView(t: "internals"))
        }

        return AnyView(
            List {
                ForEach(dataProvider.messageFromIphone!.internalsData!, id: \.subject_codes) { intrnl in
                    VStack(alignment: .leading) {
                        Text(intrnl.subject_codes)
                            .lineLimit(2)
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("MTE1: \(intrnl.mte_1 ?? "0")")
                            Text("MTE2: \(intrnl.mte_2 ?? "0")")
                            Text("CWS: \(intrnl.cws ?? "00.00")")
                            Text("PRS: \(intrnl.prs ?? "0")")
                            Text("RE: \(intrnl.resession ?? "0")")
                            Text("TTL: \(intrnl.total ?? "0")")
                        }
                        Spacer()
                    }.padding()
                }.frame(height: 150)
            }.listStyle(CarouselListStyle())
                .navigationBarTitle("Internals")
                .modifier(WithTapToRefresh())
        )
    }
}
