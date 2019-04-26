//
//  LoginResponseModel.swift
//  MUJ Buddy
//
//  Created by Nick on 4/26/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

struct LoginResponseModel: Codable {
    let sid: String
    let success: Bool
    let error: String?
    let vs: String?
    let ev: String?
}
