//
//  CaptchaModel.swift
//  MUJ Buddy
//
//  Created by Nick on 8/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import Foundation

struct CaptchaModel: Codable {
    let sessionid: String
    let generator: String
    let encodedImage: String
}
