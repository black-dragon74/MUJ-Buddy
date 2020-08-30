//
//  CaptchaAuthResponseModel.swift
//  MUJ Buddy
//
//  Created by Nick on 8/31/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import Foundation

struct CaptchaAuthResponseModel: Codable {
    let sessionid: String
    let username: String?
    let captchaFailed: Bool
    let loginSucceeded: Bool
    let credentialsError: Bool
}
