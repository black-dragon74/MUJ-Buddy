//
//  API.swift
//  MUJ Buddy
//
//  Created by Nick on 1/31/19.
//  Copyright © 2019 Nick. All rights reserved.
//

//
//  This file will contain all the methods for fetching details from the API
//  The static instance of this class can be accessed using the shared var
//  The aim is to provide a standard interface for the app to interact with
//

import UIKit

class Service {
    
    // Shared static instance of the class
    static var shared = Service()
    
    // Function to get dashboard details
    func fetchDashDetails(token: String, isRefresh: Bool = false, completion: @escaping(DashboardModel?, Error?) -> Void) {
        // We hate empty tokens, right?
        if token == "nil" {
            return
        }
        
        if !isRefresh {
            if let datafromDB = getDashFromDB() {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode(DashboardModel.self, from: datafromDB)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }
        
        let u = API_URL + "dashboard?token=\(token)"
        guard let url = URL(string: u) else { return }
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("HTTP Error: ", error)
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode(DashboardModel.self, from: data)
                    // Save to JSON
                    let encoder = JSONEncoder()
                    let dashData = try! encoder.encode(json)
                    updateDashInDB(data: dashData)
                    completion(json, nil)
                    return
                }
                catch let ex {
                    print("JSON ERROR: ", ex)
                    completion(nil, ex)
                    return
                }
            }
            }.resume()
    }
    
    // Function to get contacts
    func getFacultyDetails(token: String, isRefresh: Bool = false, uponFinishing: @escaping ([FacultyContactModel]?, Error?) -> ()) {
        // We hate empty tokens, right?
        if token == "nil" {
            return
        }
        
        let tURL = API_URL + "faculties?token=\(token)"
        
        guard let url = URL(string: tURL) else { return }
        
        if !isRefresh {
            // Check if the data is there in userdefaults
            if let data = UserDefaults.standard.object(forKey: FACULTY_CONTACT_KEY) as? Data {
                print("Processing User Defaults data")
                do {
                    let decoder = JSONDecoder()
                    let json =  try decoder.decode([FacultyContactModel].self, from: data)
                    print("Got data as JSON from user defaults")
                    uponFinishing(json, nil)
                    return
                }
                catch let err {
                    print("JSON ERROR in user defaults, ",err)
                    uponFinishing(nil, err)
                    return
                }
            }
        }
        
        // Send the request, if the datat is not saved in user defaults
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("HTTP error: ", error)
                uponFinishing(nil, error)
                return
            }
            
            if let data = data {
                // Try to decode
                do {
                    let decoder = JSONDecoder()
                    let json =  try decoder.decode([FacultyContactModel].self, from: data)
                    print("Got data as JSON from the web")
                    // Encode and save
                    let encoder = JSONEncoder()
                    let encodedData = try! encoder.encode(json)
                    UserDefaults.standard.removeObject(forKey: FACULTY_CONTACT_KEY)
                    UserDefaults.standard.set(encodedData, forKey: FACULTY_CONTACT_KEY)
                    uponFinishing(json, nil)
                }
                catch let err {
                    print("JSON ERROR, ",err)
                    uponFinishing(nil, err)
                    return
                }
            }
            
            }.resume()
    }
    
    // Function to get Attendance
    func getAttendance(token: String, isRefresh: Bool = false, completion: @escaping([AttendanceModel]?, Error?) -> Void) {
        // We hate empty tokens, right?
        if token == "nil" {
            return
        }
        
        // Check if attendance is there in the DB, saves an extra call, but only when it is not a refresh request
        if !isRefresh {
            if let attendanceInDB = getAttendanceFromDB() {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([AttendanceModel].self, from: attendanceInDB)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }
        
        let u = API_URL + "attendance?token=\(token)"
        guard let url = URL(string: u) else { return }
        
        // Start a URL session
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([AttendanceModel].self, from: data)
                    // Save to user defaults
                    let encoder = JSONEncoder()
                    let attendanceData = try? encoder.encode(json) // If it is empty, nil value will be returned from the utility function
                    updateAttendanceInDB(attendance: attendanceData)
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("JSON ERROR, ", err)
                    completion(nil, err)
                    return
                }
            }
            }.resume()
    }
    
    // Function to get Events
    func fetchEvents(token: String, isRefresh: Bool = false, completion: @escaping([EventsModel]?, Error?) -> Void) {
        // We hate empty tokens
        if (token == "nil") {
            return
        }
        
        // Form the URL
        let tURL = API_URL + "events?token=\(token)"
        guard let url = URL(string: tURL) else { return }
        
        // If not refresh, means we have to return data from the DB. Check and return
        if !isRefresh {
            // Check if the data is in DB
            if let dataFromDB = getEventsFromDB() {
                print("Data from DB")
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([EventsModel].self, from: dataFromDB)
                    // Return the data
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("Json error: ", err)
                    completion(nil, err)
                    return
                }
            }
        }
        
        // Send a URL session
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("HTTP error: ", error)
                completion(nil, error)
                return
            }
            
            if let data = data {
                // Decode
                let decoder = JSONDecoder()
                print("Data from URL")
                do {
                    let json = try decoder.decode([EventsModel].self, from: data)
                    // Save it
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateEventsInDB(events: dataToSave)
                    // Return with completion
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("Json parse error: ", err)
                    completion(nil, err)
                    return
                }
            }
            }.resume()
    }
    
    // Function to get GPA
    func fetchGPA(token: String, isRefresh: Bool = false, completion: @escaping(GpaModel?, Error?) -> Void) {
        if token == "nil" {
            return
        }
        
        if !isRefresh {
            if let data = getGPAFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode(GpaModel.self, from: data)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }
        
        // URL
        let tURL = API_URL + "gpa?token=\(token)"
        guard let url = URL(string: tURL) else { return }
        
        // Send a data request
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode(GpaModel.self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateGPAInDB(gpa: dataToSave)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
            }.resume()
    }
    
    // Function to fetch internals from the API
    func fetchInternals(token: String, semester: Int, isRefresh: Bool = false, completion: @escaping([InternalsModel]?, Error?) -> Void) {
        if token == "nil" {
            return
        }
        
        if !isRefresh {
            // Check if the data is there in the DB and return from there
            if let data = getInternalsFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([InternalsModel].self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateInternalsInDB(internals: dataToSave)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }
        
        // Else send a URL request
        let tURL = API_URL + "internals?token=\(token)&semester=\(semester)"
        guard let url = URL(string: tURL) else { return }
        URLSession.shared.dataTask(with: url){(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([InternalsModel].self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateInternalsInDB(internals: dataToSave)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }.resume()
    }
}
