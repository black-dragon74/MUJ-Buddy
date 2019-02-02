//
//  UtilityFunctions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit


//
//  General purpose functions
//

// Used to show alerts in this app
func showAlert(with message: String) -> UIAlertController {
    let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
    let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(actionDismiss)
    return alertController
}

// Returns a dictionary with key and value
func valueAsDict(withKey key: String, value: String) -> [String: String] {
    return [key: value]
}

// Function to purge the Userdefaults
func purgeUserDefaults() {
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.removeVolatileDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
}


//
//  Login related functions
//
func updateAndSetToken(to: String) {
    UserDefaults.standard.removeObject(forKey: TOKEN_KEY)
    UserDefaults.standard.set(to, forKey: TOKEN_KEY)
    
    // Update user login state
    UserDefaults.standard.set(true, forKey: LOGGED_IN_KEY)
}

func getToken() -> String {
    if let token = UserDefaults.standard.object(forKey: TOKEN_KEY) as? String {
        return token
    }
    else {
        return "nil"
    }
}

func isLoggedIn() -> Bool {
    return UserDefaults.standard.bool(forKey: LOGGED_IN_KEY)
}


//
//  Dashboard related functions
//
func updateDashInDB(data: Data?) {
    guard let data = data else { return }
    UserDefaults.standard.removeObject(forKey: DASHBOARD_KEY)
    UserDefaults.standard.set(data, forKey: DASHBOARD_KEY)
    UserDefaults.standard.synchronize()
}

func getDashFromDB() -> Data? {
    if let data = UserDefaults.standard.object(forKey: DASHBOARD_KEY) as? Data {
        return data
    }
    else {
        return nil
    }
}


//
//  Attendance related functions
//
func updateAttendanceInDB(attendance: Data?) {
    guard let attendance = attendance else { return } // Safely unwrap the data
    UserDefaults.standard.removeObject(forKey: ATTENDANCE_KEY)
    UserDefaults.standard.set(attendance, forKey: ATTENDANCE_KEY)
    UserDefaults.standard.synchronize()
}

func getAttendanceFromDB() -> Data? {
    if let att = UserDefaults.standard.object(forKey: ATTENDANCE_KEY) as? Data {
        return att
    }
    else {
        return nil
    }
}


//
//  Events related function
//
func updateEventsInDB(events: Data?) {
    guard let events = events else { return } // Safely unwrap the data
    UserDefaults.standard.removeObject(forKey: EVENTS_KEY)
    UserDefaults.standard.set(events, forKey: EVENTS_KEY)
    UserDefaults.standard.synchronize()
}

func getEventsFromDB() -> Data? {
    if let eventFromDb = UserDefaults.standard.object(forKey: EVENTS_KEY) as? Data {
        return eventFromDb
    }
    else {
        return nil
    }
}


//
//  GPA related functions
//
func updateGPAInDB(gpa: Data?) {
    guard let gpa = gpa else { return }
    UserDefaults.standard.removeObject(forKey: GPA_KEY)
    UserDefaults.standard.set(gpa, forKey: GPA_KEY)
    UserDefaults.standard.synchronize()
}

func getGPAFromDB() -> Data? {
    if let gpa = UserDefaults.standard.object(forKey: GPA_KEY) as? Data {
        return gpa
    }
    else {
        return nil
    }
}


//
//  Internals related functions
//
func updateInternalsInDB(internals: Data?) {
    guard let internals = internals else { return }
    UserDefaults.standard.removeObject(forKey: INTERNALS_KEY)
    UserDefaults.standard.set(internals, forKey: INTERNALS_KEY)
    UserDefaults.standard.synchronize()
}

func getInternalsFromDB() -> Data? {
    if let data = UserDefaults.standard.object(forKey: INTERNALS_KEY) as? Data {
        return data
    }
    else {
        return nil
    }
}


//
//  Results related functions
//
func updateResultsInDB(results: Data?) {
    guard let results = results else { return }
    UserDefaults.standard.removeObject(forKey: RESULTS_KEY)
    UserDefaults.standard.set(results, forKey: RESULTS_KEY)
    UserDefaults.standard.synchronize()
}

func getResultsFromDB() -> Data? {
    if let data = UserDefaults.standard.object(forKey: RESULTS_KEY) as? Data {
        return data
    }
    else {
        return nil
    }
}


//
//  Current semester related handlers
//
func getSemester() -> Int {
    if let sem = UserDefaults.standard.object(forKey: CURRENT_SEMESTER) as? Int {
        return sem
    }
    else {
        return -1
    }
}

func setSemester(as currSem: Int) {
    UserDefaults.standard.removeObject(forKey: CURRENT_SEMESTER)
    UserDefaults.standard.set(currSem, forKey: CURRENT_SEMESTER)
    UserDefaults.standard.synchronize()
}


//
//  Fee handlers
//
func updateFeeInDB(fee: Data?) {
    UserDefaults.standard.removeObject(forKey: FEES_KEY)
    UserDefaults.standard.set(fee, forKey: FEES_KEY)
    UserDefaults.standard.synchronize()
}

func getFeeFromDB() -> Data? {
    if let fee = UserDefaults.standard.object(forKey: FEES_KEY) as? Data {
        return fee
    }
    else {
        return nil
    }
}
