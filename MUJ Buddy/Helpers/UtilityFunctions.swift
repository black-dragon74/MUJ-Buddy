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
func reloadTableView(tableViewToReload: UITableView) {
    tableViewToReload.reloadData()
}


func showAlert(with message: String) -> UIAlertController {
    let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
    let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(actionDismiss)
    return alertController
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
