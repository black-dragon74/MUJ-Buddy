//
//  DataProvider.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import WatchConnectivity
import Combine

class DataProvider: NSObject, ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var isUserLoggedIn: Bool? {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var isAttendanceAvailable: Bool? {
        willSet {
            objectWillChange.send()
        }
    }
    @Published var attendanceData: [AttendanceModel]? {
        willSet {
            objectWillChange.send()
        }
    }
    
    private var session = WCSessionManager.shared
    
    // Publish the boolean values upon init
    override init() {
        super.init()
        
        self.setupSession()
        self.syncWithiPhone()
    }
    
    func setupSession() -> Void {
        session.startSession()
        session.watchOSDelegate = self
    }
    
    func syncWithiPhone() -> Void {
        print("Syncing with iPhone")
        
        sleep(1)
        
        // We will initiate a connection with the iPhone and Check if the data is available or not
        let messageRequest = ["requestFor": "attendance"]
        session.sendMessage(message: messageRequest as [String : AnyObject], replyHandler: { (iPhoneReply) in
            for key in iPhoneReply.keys {
                if key == "success" {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let parsed = try decoder.decode([AttendanceModel].self, from: iPhoneReply[key] as! Data)
                        
                        // Publish and update all the views
                        DispatchQueue.main.async {
                            self.isUserLoggedIn = true
                            self.isAttendanceAvailable = true
                            self.attendanceData = parsed
                        }
                    }
                    catch let ex {
                        print(ex.localizedDescription)
                    }
                }
                else {
                    print("Error in parsing reply: \(iPhoneReply[key] ?? "undefined")")
                    // Now we have to check the error message
                    switch iPhoneReply[key] as! String {
                    case "notloggedin":
                        DispatchQueue.main.async {
                            self.isUserLoggedIn = false
                            self.isAttendanceAvailable = false
                            self.attendanceData = nil
                        }
                    default:
                        DispatchQueue.main.async {
                            self.isUserLoggedIn = true
                            self.isAttendanceAvailable = false
                            self.attendanceData = nil
                        }
                    }
                }
            }
        }) { (err) in
            print("Error in sending message to iPhone from watch: \(err.localizedDescription)")
        }
    }
}


//MARK:- Extension to provide conectivity between watch and iPhone
extension DataProvider: WatchOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        print("message received from iPhone. Printing as is: \(tuple.message)")
    }
}
