//
//  ResultsModel.swift
//  Test
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

struct ResultsModel: Codable {
    let index: String
    let courseName: String
    let courseCode: String
    let academicEssion: String //TODO:- Update this typo in the API
    let grade: String
    let credits: String
}

