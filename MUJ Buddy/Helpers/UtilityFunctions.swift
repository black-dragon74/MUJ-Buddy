//
//  UtilityFunctions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

//
//  Shared user defaults between app and extensions
//
private let sharedUserDefaults = UserDefaults(suiteName: "group.mujbuddy.shared")

//
//  General purpose functions
//

// Returns a dictionary with key and value
func valueAsDict(withKey key: String, value: String) -> [String: String] {
    return [key: value]
}

// Function to purge the Userdefaults
func purgeUserDefaults() {
    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.removeVolatileDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.removePersistentDomain(forName: "group.mujbuddy.shared")
    UserDefaults.standard.removeVolatileDomain(forName: "group.mujbuddy.shared")
    UserDefaults.standard.synchronize()
}

//
//  Login related functions
//

// Updates user id in the DB, used while reauth when session expires
func setUserID(to: String) {
    UserDefaults.standard.removeObject(forKey: USER_ID)
    UserDefaults.standard.set(to, forKey: USER_ID)
    UserDefaults.standard.synchronize()
}

// Updates password in the DB
func setPassword(to: String) {
    UserDefaults.standard.removeObject(forKey: PASSWORD)
    UserDefaults.standard.set(to, forKey: PASSWORD)
    UserDefaults.standard.synchronize()
}

// Updates the session ID in the DB, used for all API requests
func setSessionID(to: String) {
    UserDefaults.standard.removeObject(forKey: SESSION_ID)
    UserDefaults.standard.set(to, forKey: SESSION_ID)
    UserDefaults.standard.synchronize()
}

// Updates the login state to the shaerd user defaults
func setLoginState(to: Bool) {
    guard let sharedUD = sharedUserDefaults else { return }
    sharedUD.set(to, forKey: LOGGED_IN_KEY)
    sharedUD.synchronize()
}

// Returns the userID
func getUserID() -> String? {
    return UserDefaults.standard.object(forKey: USER_ID) as? String
}

// Returns the password
func getPassword() -> String? {
    return UserDefaults.standard.object(forKey: PASSWORD) as? String
}

// Returns the session id
func getSessionID() -> String {
    return UserDefaults.standard.object(forKey: SESSION_ID) as? String ?? "NA"
}

// Returns if the user is loggen in or not
func isLoggedIn() -> Bool {
    guard let sharedUD = sharedUserDefaults else { return false }
    return sharedUD.bool(forKey: LOGGED_IN_KEY)
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
    } else {
        return nil
    }
}

//
//  Attendance related functions, uses the shared container for app and extension
//
func updateAttendanceInDB(attendance: Data?) {
    guard let attendance = attendance else { return } // Safely unwrap the data
    guard let attendanceDB = sharedUserDefaults else { return }
    attendanceDB.removeObject(forKey: ATTENDANCE_KEY)
    attendanceDB.set(attendance, forKey: ATTENDANCE_KEY)
    attendanceDB.synchronize()
}

func getAttendanceFromDB() -> Data? {
    guard let attendanceDB = sharedUserDefaults else { return nil }
    if let att = attendanceDB.object(forKey: ATTENDANCE_KEY) as? Data {
        return att
    } else {
        return nil
    }
}

//
//  Attendance notification related utility functions
//
func userHasAllowedNotification() -> Bool {
    return UserDefaults.standard.object(forKey: USER_NOTIFICATION_PREFERENCE) as? Bool ?? true  // Defaulting to true
}

func userHasAllowedNotification(value: Bool) {
    UserDefaults.standard.removeObject(forKey: USER_NOTIFICATION_PREFERENCE)
    UserDefaults.standard.set(value, forKey: USER_NOTIFICATION_PREFERENCE)
    UserDefaults.standard.synchronize()
}

func getNotificationThresholdFromDB() -> Int {
    return UserDefaults.standard.object(forKey: NOTIFICATION_THRESHOLD) as? Int ?? 24
}

func setNotificationThreshold(to value: Int) {
    UserDefaults.standard.removeObject(forKey: NOTIFICATION_THRESHOLD)
    UserDefaults.standard.set(value, forKey: NOTIFICATION_THRESHOLD)
    UserDefaults.standard.synchronize()
}

func shouldShowAttendanceNotification() -> Bool {
    // As of now, if the last notification for attendance was shown within the past 24 hours
    // We will not show the notification for the same. Else, we will then issue the notification
    guard let lastNotificationDate = getLastAttendanceNotificationDate() else { return true }  // Return true if the last date is not set
    return lastNotificationDate.hoursTillNow() >= getNotificationThresholdFromDB() && userHasAllowedNotification()
}

func getLastAttendanceNotificationDate() -> Date? {
    if let date = UserDefaults.standard.object(forKey: LAST_ATTENDANCE_NOTIFICATION_KEY) as? Date {
        return date
    } else {
        return nil
    }
}

func setLastAttendanceNotificationDate(to: Date) {
    UserDefaults.standard.removeObject(forKey: LAST_ATTENDANCE_NOTIFICATION_KEY)
    UserDefaults.standard.set(to, forKey: LAST_ATTENDANCE_NOTIFICATION_KEY)
    UserDefaults.standard.synchronize()
}

func getLowAttendanceCount() -> Int {
    var count = 0
    // Parse the attendance here
    guard let attendance = getAttendanceFromDB() else { return 0 }
    let decoder = JSONDecoder()
    do {
        let data = try decoder.decode([AttendanceModel].self, from: attendance)
        for d in data {
            if (Int(d.percentage.isEmpty ? "75" : d.percentage)! < 75) {  //TODO:- Implement it in a better way
                count += 1
            }
        }
    } catch {
        return 0
    }
    return count
}

//
//  Attendance fetch interval related values
//
func getRefreshInterval() -> Int {
    return UserDefaults.standard.object(forKey: REFRESH_INTERVAL) as? Int ?? 15  // Default fetch interval is 15 minutes
}

func setRefreshInterval(as value: Int) {
    UserDefaults.standard.removeObject(forKey: REFRESH_INTERVAL)
    UserDefaults.standard.set(value, forKey: REFRESH_INTERVAL)
    UserDefaults.standard.synchronize()
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
    } else {
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
    } else {
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
    } else {
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
    } else {
        return nil
    }
}

//
//  Current semester related handlers
//
func getSemester() -> Int {
    if let sem = UserDefaults.standard.object(forKey: CURRENT_SEMESTER) as? Int {
        return sem
    } else {
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
    } else {
        return nil
    }
}

//
//  Semester predictor related functions
//
func admDateFrom(regNo: String) -> Date {
    // Extract the year from the reg number
    let regYear = "20" + regNo.prefix(2)

    // Semesters generally start at JULY
    let semStartDate = "\(regYear)-07-01 00:00:00"  // Will return 20 + first two digits of reg number

    // Create a date formatter instance to format our custom date
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    return formatter.date(from: semStartDate)! //TODO: Do not force unwrap the date although it won't bite
}

func setShowSemesterDialog(as val: Bool) {
    UserDefaults.standard.removeObject(forKey: DIALOG_KEY)
    UserDefaults.standard.set(val, forKey: DIALOG_KEY)
    UserDefaults.standard.synchronize()
}

func showSemesterDialog() -> Bool {
    // If value is there in the UserDefaults, return that
    return UserDefaults.standard.object(forKey: DIALOG_KEY) as? Bool ?? true
}

//
//  Background app refresh related functions
//
func setShowRefreshDialog(as val: Bool) {
    UserDefaults.standard.removeObject(forKey: REFRESH_KEY)
    UserDefaults.standard.set(val, forKey: REFRESH_KEY)
    UserDefaults.standard.synchronize()
}

func showRefreshDialog() -> Bool {
    return UserDefaults.standard.object(forKey: REFRESH_KEY) as? Bool ?? true
}

//
//  Profile image updaters
//
func getProfileImage() -> UIImage? {
    if let image = UserDefaults.standard.value(forKey: PROFILE_IMG_KEY) as? Data {
        let image = UIImage(data: image)
        return image
    }
    else {
        return nil
    }
}

func setProfileImage(image: Data) {
    UserDefaults.standard.removeObject(forKey: PROFILE_IMG_KEY)
    UserDefaults.standard.set(image, forKey: PROFILE_IMG_KEY)
    UserDefaults.standard.synchronize()
}

//
//  Dark theme helper functions
//
func shoudUseDarkMode() -> Bool {
    return UserDefaults.standard.object(forKey: DARK_MODE) as? Bool ?? false
}

func setDarkMode(to: Bool) {
    UserDefaults.standard.removeObject(forKey: DARK_MODE)
    UserDefaults.standard.set(to, forKey: DARK_MODE)
    UserDefaults.standard.synchronize()
}
