//
//  DashboardModel.swift
//  Test
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

struct DashboardModel: Codable {

    // For the basic info
    struct admDetails: Codable {
        let name: String
        let acadYear: String
        let regNo: String
        let program: String
    }

    // For edu quals
    struct eduQualifications: Codable {
        let index: String
        let obtainedMarks: String
        let maxMarks: String
        let year: String
        let percentage: String
        let board: String
        let grade: String
        let institution: String
    }
    
    // For parent details
    struct parentDetails: Codable {
        let mother: String
        let father: String
        let email: String
        let mobileNo: String
        let emergencyContact: String
    }

    // Real structure
    let admDetails: admDetails
    let eduQualifications: [eduQualifications]
    let parentDetails: parentDetails
}
