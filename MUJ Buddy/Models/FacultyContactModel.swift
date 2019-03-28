//
//  FacultyContactModel.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// Structure for the faculty contacts model
struct FacultyContactModel: Codable {
    let id: Int
    let name: String
    let designation: String
    let department: String
    let email: String
    let phone: String
    let image: String
}
