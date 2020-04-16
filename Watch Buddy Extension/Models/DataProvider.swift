//
//  DataProvider.swift
//  Watch Buddy Extension
//
//  Created by Nick on 10/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Combine
import WatchConnectivity

class DataProvider: NSObject, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @Published var isFetchingData: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var messageFromIphone: WatchMessageModel? {
        willSet {
            objectWillChange.send()
        }
    }

    private var session = WCSessionManager.shared

    // Publish the boolean values upon init
    private override init() {
        super.init()

        setupSession()
        syncWithiPhone()
    }

    func setupSession() {
        session.startSession()
        session.watchOSDelegate = self
    }

    static let shared = DataProvider()

    func syncWithiPhone() {
        print("Syncing with iPhone")
        isFetchingData = true

        sleep(1) // Only for simulation

        // We will initiate a connection with the iPhone and Check if the data is available or not
        let messageRequest = ["requestFor": "attendance"]
        session.sendMessage(message: messageRequest as [String: AnyObject], replyHandler: { iPhoneReply in
            for key in iPhoneReply.keys {
                if key == "msg" {
                    do {
                        let parsed = try JSONDecoder().decode(WatchMessageModel.self, from: iPhoneReply[key] as! Data)
                        // time to set the status as fetched
                        print("Data fetched and decoded successfully")
                        DispatchQueue.main.async {
                            self.isFetchingData = false
                            self.messageFromIphone = parsed
                        }
                    } catch let ex {
                        print("Decoding error: \(ex.localizedDescription)")
                    }
                }
            }
        }) { err in
            print("Error in sending message to iPhone from watch: \(err.localizedDescription)")
        }
    }
}

// MARK: - Extension to provide conectivity between watch and iPhone

extension DataProvider: WatchOSDelegate {
    func messageReceived(tuple: MessageReceived) {
        print("message received from iPhone. Printing as is: \(tuple.message)")
    }
}
