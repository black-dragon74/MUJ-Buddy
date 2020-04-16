//
//  HostingController.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/3/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Foundation
import SwiftUI

class HostingController: WKHostingController<AnyView> {
    override var body: AnyView {
        let envObj = DataProvider.shared
        return AnyView(
            DashboardView()
                .environmentObject(envObj)
        )
    }
}
