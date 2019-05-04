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

extension UIColor {
    // Darker colors
    static var skyBlue: UIColor { return UIColor(r: 48, g: 205, b: 196) }
    static var babyPink: UIColor { return UIColor(r: 244, g: 145, b: 162) }
    static var indigo: UIColor { return UIColor(r: 182, g: 139, b: 244) }
    static var jetStream: UIColor { return UIColor(r: 110, g: 142, b: 163) }
    static var paleOrange: UIColor { return UIColor(r: 237, g: 150, b: 82) }
    static var teal: UIColor { return UIColor(r: 1, g: 115, b: 92) }
    static var warmPurple: UIColor { return UIColor(r: 103, g: 79, b: 125) }
    static var brickRed: UIColor { return UIColor(r: 240, g: 97, b: 69) }
    static var navyBlue: UIColor { return UIColor(r: 27, g: 38, b: 56) }
    static var mujTheme: UIColor { return UIColor(r: 255, g: 152, b: 0) }
    static var parrotGreen: UIColor { return UIColor(r: 89, g: 193, b: 71) }
    
    // Lighter colors
    static var primaryLighter: UIColor { return UIColor(r: 238, g: 239, b: 243) }
    static var skyBlueLighter: UIColor { return UIColor(r: 216, g: 241, b: 241) }
    static var babyPinkLighter: UIColor { return UIColor(r: 254, g: 235, b: 238) }
    static var indigoLighter: UIColor { return UIColor(r: 235, g: 218, b: 255) }
    static var jetStreamLighter: UIColor { return UIColor(r: 185, g: 210, b: 204) }
    static var paleOrangeLighter: UIColor { return UIColor(r: 255, g: 250, b: 244) }
    static var tealLighter: UIColor { return UIColor(r: 176, g: 244, b: 235) }
    static var warmPurpleLighter: UIColor { return UIColor(r: 226, g: 211, b: 236) }
    static var brickRedLighter: UIColor { return UIColor(r: 256, g: 239, b: 234) }
}

func randomGradientColor() -> [UIColor] {
    //Colors
    let red = [#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1),#colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)]
    let orangeRed = [#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1),#colorLiteral(red: 0.8518816233, green: 0.1738803983, blue: 0.01849062555, alpha: 1)]
    let orange = [#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1),#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)]
    let yellow = [#colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1),#colorLiteral(red: 0.8931249976, green: 0.5340107679, blue: 0.08877573162, alpha: 1)]
    let green = [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)]
    let greenBlue = [#colorLiteral(red: 0.2761503458, green: 0.824685812, blue: 0.7065336704, alpha: 1),#colorLiteral(red: 0, green: 0.6422213912, blue: 0.568986237, alpha: 1)]
    let kindaBlue = [#colorLiteral(red: 0.2494148612, green: 0.8105323911, blue: 0.8425348401, alpha: 1),#colorLiteral(red: 0, green: 0.6073564887, blue: 0.7661359906, alpha: 1)]
    let skyBlue = [#colorLiteral(red: 0.3045541644, green: 0.6749247313, blue: 0.9517192245, alpha: 1),#colorLiteral(red: 0.008423916064, green: 0.4699558616, blue: 0.882807076, alpha: 1)]
    let blue = [#colorLiteral(red: 0.1774400771, green: 0.466574192, blue: 0.8732826114, alpha: 1),#colorLiteral(red: 0.00491155684, green: 0.287129879, blue: 0.7411141396, alpha: 1)]
    let bluePurple = [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1),#colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)]
    let purple = [#colorLiteral(red: 0.7080290914, green: 0.3073516488, blue: 0.8653779626, alpha: 1),#colorLiteral(red: 0.5031493902, green: 0.1100070402, blue: 0.6790940762, alpha: 1)]
    let pink = [#colorLiteral(red: 0.9495453238, green: 0.4185881019, blue: 0.6859942079, alpha: 1),#colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)]
    
    let colorsTable: [Int: [UIColor]] = [0: red, 1: orangeRed, 2: orange, 3: yellow, 4: green, 5: greenBlue, 6: kindaBlue, 7: skyBlue, 8: blue, 9: bluePurple, 10: bluePurple, 11: purple, 12: pink]
    
    let randomColors = colorsTable.values.randomElement()
    return randomColors!
}
