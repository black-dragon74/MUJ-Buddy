//
//  FeeModel.swift
//  Test
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

//TODO:- Get hold of proper fee model
struct FeeModel: Codable {

    struct paid: Codable {
        let semester1: String?
        let total: String?
    }

    struct unpaid: Codable {
        let total: String?
    }

    let paid: paid?
    let unpaid: unpaid?
}
