//
//  Enumerators.swift
//  MUJ Buddy
//
//  Created by Nick on 1/30/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

//
//  This file is here to make app more consistent and we can change colors globally from here
//

enum DMSColors {
    case primaryLighter // Kind of light gray, used as a background
    case kindOfPurple
    case orangeish
}

extension DMSColors {
    var value: UIColor {
        get {
            switch self {
            case .primaryLighter:
                return UIColor(r: 238, g: 239, b: 243)
            case .kindOfPurple:
                return UIColor(r: 27, g: 38, b: 56)
            case .orangeish:
                return UIColor(r: 255, g: 152, b: 0)
            }
        }
    }
}
