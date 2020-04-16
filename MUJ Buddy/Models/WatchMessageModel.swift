//
//  WatchMessageModel.swift
//  MUJ Buddy
//
//  Created by Nick on 4/16/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import Foundation

struct WatchMessageModel: Codable {
    let loggedIn: Bool
    let name: String?
    let attendanceData: [AttendanceModel]?
    let internalsData: [InternalsModel]?
    let resultsData: [ResultsModel]?
}

extension WatchMessageModel {
    func encodeToData() -> Data {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(self)
        } catch let ex {
            fatalError("Unable to decode: \(ex.localizedDescription)")
        }
    }
}
