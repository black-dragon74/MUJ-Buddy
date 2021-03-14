//
//  SwiftUIHelpers.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import SwiftUI

struct RoundedTextWithColor: ViewModifier {
    // Can be overridden whilst initializing
    var color: Color = .gray

    // Return the content with the modifiers applied
    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .font(.system(.subheadline, design: .rounded))
            .lineLimit(nil)
            .multilineTextAlignment(.center)
    }
}

fileprivate struct WithTapToRefresh: ViewModifier {
    @EnvironmentObject var dataProvider: DataProvider

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button(action: {
                    self.dataProvider.syncWithiPhone()
                }, label: {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                        Text("Refresh")
                    }
            })
            }
    }
}

struct WithLoaderView: ViewModifier {
    @EnvironmentObject var dataProvider: DataProvider
    
    func body(content: Content) -> some View {
        return dataProvider.isFetchingData ?
            AnyView(LoaderView().modifier(WithTapToRefresh())) :
            AnyView(
                content
                    .modifier(WithTapToRefresh())
            )
    }
}

struct WithDataProvider: ViewModifier {
    func body(content: Content) -> some View {
        content.environmentObject(DataProvider.shared)
    }
}
