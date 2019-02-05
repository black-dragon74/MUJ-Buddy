//
//  BottomSheetDelegate.swift
//  MUJ Buddy
//
//  Created by Nick on 2/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

//
//  This delegate is used to pass data from BottomSheetController to another controller
//
protocol BottomSheetDelegate: AnyObject {
    func handleMenuSelect(forItem: String)
}
