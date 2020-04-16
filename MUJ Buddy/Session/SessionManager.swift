//
//  SessionManager.swift
//  MUJ Buddy
//
//  Created by Nick on 2/9/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class AppSessionManager: NSObject {
    static let shared = AppSessionManager()

    var needsReAuth = false
}
