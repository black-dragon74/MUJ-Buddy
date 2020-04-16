//
//  GpaModel.swift
//  Test
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// TODO: - Implement it in a better way, update API to return array
struct GpaModel: Codable {
    let success: Bool
    let semester_1: String?
    let semester_2: String?
    let semester_3: String?
    let semester_4: String?
    let semester_5: String?
    let semester_6: String?
    let semester_7: String?
    let semester_8: String?
}
