//
//  Font.swift
//  MUJ Buddy
//
//  Created by Nick on 5/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// The app's type face
extension UIFont {
    // Used for card title
    static var titleFont: UIFont { UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }

    // Used for description, usually below titles
    static var subtitleFont: UIFont { UIFont(name: "Poppins-Light", size: 12) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }

    // Used for showing important info, like, grades or marks
    static var scoreFont: UIFont { UIFont(name: "Poppins-SemiBold", size: 20) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }

    static var scoreFontBolder: UIFont { UIFont(name: "Poppins-SemiBold", size: 30) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }
}

// The font's color are also defined here
extension UIColor {
    static var textInfo: UIColor { UIColor(r: 87, g: 167, b: 255) }
    static var textSuccess: UIColor { UIColor(r: 53, g: 205, b: 150) }
    static var textWarning: UIColor { UIColor(r: 255, g: 177, b: 11) }
    static var textDanger: UIColor { UIColor(r: 255, g: 73, b: 101) }
}
