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
