//
//  AttendanceModel.swift
//  Test
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// Instantiate as an array
struct AttendanceModel: Codable {
    let section: String
    let present: String
    let absent: String
    let total: String
    let status: String
    let course: String
    let percentage: String
    let type: String
    let batch: String
    let index: String
}
