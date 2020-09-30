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
import WidgetKit

class Service {
    // Make the initializer private so that only the class itself can instantiate itself
    private init() {
        // Nothing, we don't do anything specific when initializing this singleton
    }

    // Shared static instance of the class
    static var shared = Service()

    // Function to send the OTP, requires just the userID as a parameter
    func sendOTPFor(userid: String, completion: @escaping (LoginResponseModel?, Error?) -> Void) {
        // Send the request to the API server and return the response
        let u = API_URL + "genotp?userid=\(userid)"
        guard let url = URL(string: u) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in

            if let error = error {
                completion(nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()

                do {
                    let resp = try decoder.decode(LoginResponseModel.self, from: data)
                    completion(resp, nil)
                    return
                } catch let e {
                    completion(nil, e)
                    return
                }
            }

        }.resume()
    }

    // Function to finish the API auth handshake
    func finishAuth(for student: String, session: String, otp: String, vs: String, ev: String, completion: @escaping (LoginResponseModel?, Error?) -> Void) {
        let u = API_URL + "finishauth?userid=\(student)&sessionid=\(session)&otp=\(otp)&ev=\(ev)&vs=\(vs)"
        guard let url = URL(string: u) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let resp = try decoder.decode(LoginResponseModel.self, from: data)
                    completion(resp, nil)
                    return
                } catch let ex {
                    completion(nil, ex)
                    return
                }
            }
        }.resume()
    }

    // Function to get dashboard details
    func fetchDashDetails(sessionID: String, isRefresh: Bool = false, completion: @escaping (DashboardModel?, ErrorModel?, Error?) -> Void) {
        if !isRefresh {
            if let datafromDB = getDashFromDB() {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode(DashboardModel.self, from: datafromDB)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        let u = API_URL + "dashboard?sessionid=\(sessionID)"
        guard let url = URL(string: u) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("HTTP Error: ", error)
                completion(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode(DashboardModel.self, from: data)
                    // Save to JSON
                    let encoder = JSONEncoder()
                    let dashData = try? encoder.encode(json)
                    updateDashInDB(data: dashData)
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to get contacts
    func getFacultyDetails(sessionID: String, isRefresh: Bool = false, uponFinishing: @escaping ([FacultyContactModel]?, ErrorModel?, Error?) -> Void) {
        let tURL = API_URL + "faculties?sessionid=\(sessionID)"

        guard let url = URL(string: tURL) else { return }

        if !isRefresh {
            // Check if the data is there in userdefaults
            if let data = UserDefaults.standard.object(forKey: FACULTY_CONTACT_KEY) as? Data {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([FacultyContactModel].self, from: data)
                    uponFinishing(json, nil, nil)
                    return
                } catch let err {
                    print("JSON ERROR in user defaults, ", err)
                    uponFinishing(nil, nil, err)
                    return
                }
            }
        }

        // Send the request, if the datat is not saved in user defaults
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("HTTP error: ", error)
                uponFinishing(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                // Try to decode
                do {
                    let json = try decoder.decode([FacultyContactModel].self, from: data)
                    // Encode and save
                    let encoder = JSONEncoder()
                    let encodedData = try? encoder.encode(json)
                    UserDefaults.standard.removeObject(forKey: FACULTY_CONTACT_KEY)
                    UserDefaults.standard.set(encodedData, forKey: FACULTY_CONTACT_KEY)
                    uponFinishing(json, nil, nil)
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        uponFinishing(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        uponFinishing(nil, nil, er)
                        return
                    }
                }
            }

        }.resume()
    }

    // Function to get Attendance
    func getAttendance(sessionID: String, isRefresh: Bool = false, completion: @escaping ([AttendanceModel]?, ErrorModel?, Error?) -> Void) {
        // Check if attendance is there in the DB, saves an extra call, but only when it is not a refresh request
        if !isRefresh {
            if let attendanceInDB = getAttendanceFromDB() {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([AttendanceModel].self, from: attendanceInDB)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        let u = API_URL + "attendance?sessionid=\(sessionID)"
        guard let url = URL(string: u) else { return }

        // Start a URL session
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, nil, error)
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
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadTimelines(ofKind: "com.mujbuddy.widgetkit.attendance-widget")
                    }
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to get Events
    func fetchEvents(sessionID: String, isRefresh: Bool = false, completion: @escaping ([EventsModel]?, ErrorModel?, Error?) -> Void) {
        // Form the URL
        let tURL = API_URL + "events?sessionid=\(sessionID)"
        guard let url = URL(string: tURL) else { return }

        // If not refresh, means we have to return data from the DB. Check and return
        if !isRefresh {
            // Check if the data is in DB
            if let dataFromDB = getEventsFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([EventsModel].self, from: dataFromDB)
                    // Return the data
                    completion(json, nil, nil)
                    return
                } catch let err {
                    print("Json error: ", err)
                    completion(nil, nil, err)
                    return
                }
            }
        }

        // Send a URL session
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("HTTP error: ", error)
                completion(nil, nil, error)
                return
            }

            if let data = data {
                // Decode
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([EventsModel].self, from: data)
                    // Save it
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateEventsInDB(events: dataToSave)
                    // Return with completion
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to get GPA
    func fetchGPA(sessionID: String, isRefresh: Bool = false, completion: @escaping (GpaModel?, ErrorModel?, Error?) -> Void) {
        if !isRefresh {
            if let data = getGPAFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode(GpaModel.self, from: data)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        // URL
        let tURL = API_URL + "gpa?sessionid=\(sessionID)"
        guard let url = URL(string: tURL) else { return }

        // Send a data request
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode(GpaModel.self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateGPAInDB(gpa: dataToSave)
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to fetch internals from the API
    func fetchInternals(sessionID: String, semester: Int, isRefresh: Bool = false, completion: @escaping ([InternalsModel]?, ErrorModel?, Error?) -> Void) {
        if !isRefresh {
            // Check if the data is there in the DB and return from there
            if let data = getInternalsFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([InternalsModel].self, from: data)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        // Else send a URL request
        let tURL = API_URL + "internals?sessionid=\(sessionID)&semester=\(semester)"
        guard let url = URL(string: tURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([InternalsModel].self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateInternalsInDB(internals: dataToSave)
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to fetch results from the API
    func fetchResults(sessionID: String, semester: Int, isRefresh: Bool = false, completion: @escaping ([ResultsModel]?, ErrorModel?, Error?) -> Void) {
        if !isRefresh {
            // Check if the data is there in the DB and return from there
            if let data = getResultsFromDB() {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode([ResultsModel].self, from: data)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        // Else send a URL request
        let tURL = API_URL + "results?sessionid=\(sessionID)&semester=\(semester)"
        guard let url = URL(string: tURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode([ResultsModel].self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateResultsInDB(results: dataToSave)
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }

    // Function to fetch fee details from the API
    func fetchFeeDetails(sessionID: String, isRefresh: Bool = false, completion: @escaping (FeeModel?, ErrorModel?, Error?) -> Void) {
        if !isRefresh {
            // Check if the data is there in the DB and return from there
            if let data = getFeeFromDB() {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode(FeeModel.self, from: data)
                    completion(json, nil, nil)
                    return
                } catch let err {
                    completion(nil, nil, err)
                    return
                }
            }
        }

        // Else send a URL request
        let tURL = API_URL + "feedetails?sessionid=\(sessionID)"
        guard let url = URL(string: tURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let json = try decoder.decode(FeeModel.self, from: data)
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateFeeInDB(fee: dataToSave)
                    completion(json, nil, nil)
                    return
                } catch {
                    // Try and see if the login has failed
                    do {
                        let errorMsg = try decoder.decode(ErrorModel.self, from: data)
                        completion(nil, errorMsg, nil)
                        return
                    } catch let er {
                        // This is the final error
                        completion(nil, nil, er)
                        return
                    }
                }
            }
        }.resume()
    }
    
    // Function to fetch a captcha from the sever, calling it again will act as refresh
    func fetchCaptchaFromServer(completion: @escaping(CaptchaModel?, Error?) -> Void) {
        let tURL = API_URL + "captcha"
        guard let url = URL(string: tURL) else { return }
        
        URLSession.shared.dataTask(with: url) {(data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let decoded = try decoder.decode(CaptchaModel.self, from: data)
                    completion(decoded, nil)
                    return
                }
                catch let ex{
                    completion(nil, ex)
                    return
                }
            }
        }.resume()
    }
    
    // Function to complete auth handshake with captcha
    func completeAuthWithCaptcha(sessionID: String, userName: String, password: String, captcha: String, completion: @escaping(CaptchaAuthResponseModel?, Error?) -> Void) {
        let tURL = API_URL + "captcha_auth?sessionid=\(sessionID)&username=\(userName)&password=\(password.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&captcha=\(captcha)"
        guard let url = URL(string: tURL) else { return }
        
        URLSession.shared.dataTask(with: url) {(data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let data = try decoder.decode(CaptchaAuthResponseModel.self, from: data)
                    completion(data, nil)
                    return
                }
                catch let ex {
                    completion(nil, ex)
                    return
                }
            }
        }.resume()
    }
}
