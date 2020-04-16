//
//  ShortcutsHelper.swift
//  MUJ Buddy
//
//  Created by Nick on 2/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

enum MUJShortcuts: String {
    case attendance
    case contacts
    case internals
    case results

    var value: String {
        switch self {
        case .attendance:
            return "muj_attendance"
        case .contacts:
            return "muj_contacts"
        case .internals:
            return "muj_internals"
        case .results:
            return "muj_results"
        }
    }
}
