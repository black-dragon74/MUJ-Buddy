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
    static var titleFont: UIFont { return UIFont(name: "Poppins-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }
    
    // Used for description, usually below titles
    static var subtitleFont: UIFont { return UIFont(name: "Poppins-Light", size: 12) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }
    
    // Used for showing important info, like, grades or marks
    static var scoreFont: UIFont { return UIFont(name: "Poppins-SemiBold", size: 20) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }
    
    static var scoreFontBolder: UIFont { return UIFont(name: "Poppins-SemiBold", size: 30) ?? UIFont.systemFont(ofSize: 16, weight: .medium) }
    
}

// The font's color are also defined here
extension UIColor {
    static var textPrimary: UIColor { return .black }
    static var textPrimaryDarker: UIColor { return UIColor(r: 76, g: 76, b: 76) }
    static var textPrimaryLighter: UIColor { return UIColor(r: 130, g: 130, b: 130) }
    
    static var darkTextPrimary: UIColor { return .white }
    static var darkTextPrimaryDarker: UIColor { return .white }
    static var darkTextPrimaryLighter: UIColor { return UIColor(r: 203, g: 203, b: 203) }
    
    static var textInfo: UIColor { return UIColor(r: 87, g: 167, b: 255) }
    static var textSuccess: UIColor { return UIColor(r: 53, g: 205, b: 150) }
    static var textWarning: UIColor { return UIColor(r: 255, g: 177, b: 11) }
    static var textDanger: UIColor { return UIColor(r: 255, g: 73, b: 101) }
}
