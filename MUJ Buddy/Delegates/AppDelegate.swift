//
//  AppDelegate.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import UserNotifications
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var watchSession = WCSessionManager.shared
    let notificationDelegate = AttendanceNotificationDelegate()
    private var launchedShortcutItem: UIApplicationShortcutItem?

    func application(_: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Delay the launch for splash image, disabled coz testing
//        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))

        // Set the window manually coz I hate using storyboards
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        // Set the root view controller
        if isLoggedIn() {
            window?.rootViewController = UINavigationController(rootViewController: DashboardViewController())
        } else {
            window?.rootViewController = LoginViewController()
        }

        // Handle the 3D touch platter
        if let selectedItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            launchedShortcutItem = selectedItem
        }

        // Get and set the update interval from the DB
        let interval = 60 * getRefreshInterval()
        UIApplication.shared.setMinimumBackgroundFetchInterval(Double(interval))

        // Ask permission for the notifications
        let notificationCenter = UNUserNotificationCenter.current()
        let options = UNAuthorizationOptions(arrayLiteral: [.alert, .sound])
        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Permission error: ", error.localizedDescription)
            }

            if !granted {
                print("Notification permission denied.")
            } else {
                print("Got the permission to display notifications")
            }
        }

        // Start the session for the watch connectivity
        WCSessionManager.shared.startSession()

        watchSession.iOSDelegate = self

        // Required
        return true
    }

    // Perform the actual fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.backgroundRefreshStatus == UIBackgroundRefreshStatus.available && getSessionID() != "NA" {
            Service.shared.getAttendance(sessionID: getSessionID(), isRefresh: true) { attendance, _, error in
                if let error = error {
                    print("Refresh error: ", error)
                    completionHandler(.failed)
                    return
                }

                if attendance != nil {
                    // Data save is handled by the API service itself
                    // Just notify the user if need be
                    print("Fetch completed.")
                    if shouldShowAttendanceNotification(), getLowAttendanceCount() > 0 {
                        let nc = UNUserNotificationCenter.current()
                        nc.delegate = self.notificationDelegate
                        setLastAttendanceNotificationDate(to: Date()) // To current date
                        nc.add(prepareNotification(withBody: "Running low in \(getLowAttendanceCount()) subject(s). Tap to check."), withCompletionHandler: { error in
                            if let error = error {
                                print(error)
                            }
                        })
                    }
                    completionHandler(.newData)
                    return
                }
            }
        } else {
            completionHandler(.failed)
            print("Background service disabled")
        }
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AppSessionManager.shared.needsReAuth = true // User will have to reauthenticate with biometrics
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppSessionManager.shared.needsReAuth = true // User will have to reauthenticate with biometrics
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if canUseBiometrics() && shouldUseBiometrics() && AppSessionManager.shared.needsReAuth {
            NotificationCenter.default.post(name: .isReauthRequired, object: nil)
        }
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        // Nil the value as a failsafe measure
        launchedShortcutItem = nil
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcutItem(item: shortcutItem))
    }

    fileprivate func handleShortcutItem(item: UIApplicationShortcutItem) -> Bool {
        // If user is not logged in, all the calls to shortcut items are returned as true
        if !isLoggedIn() {
            return true
        }

        var handled = false
        var vcToPush: UIViewController!

        switch item.type {
        case MUJShortcuts.attendance.value:
            vcToPush = AttendanceViewController(collectionViewLayout: UICollectionViewFlowLayout())
        case MUJShortcuts.contacts.value:
            vcToPush = ContactsViewController()
        case MUJShortcuts.internals.value:
            vcToPush = InternalsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        case MUJShortcuts.results.value:
            vcToPush = ResultsViewController(collectionViewLayout: UICollectionViewFlowLayout())
        default:
            break
        }

        if let mainVC = window?.rootViewController as? UINavigationController {
            mainVC.pushViewController(vcToPush, animated: true)
            handled = true
        }

        return handled
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        value(forKey: "statusBar") as? UIView
    }
}

extension AppDelegate: iOSDelegate {
    private func prepareDetails() -> WatchMessageModel {
        // First, see if the user is logged in or not
        let _loggedIn = isLoggedIn()
        let _semester = getSemester()
        let _sessionID = getSessionID()
        var _name: String?
        var _attendanceData: [AttendanceModel]?
        var _internalsData: [InternalsModel]?
        var _resultsData: [ResultsModel]?

        // Now we will continue and form everything else only if the user is logged in

        // Get the attendance data
        if _loggedIn {
            Service.shared.getAttendance(sessionID: _sessionID) { data, _, _ in
                if let data = data {
                    _attendanceData = data
                }
            }
        }

        // Get the name
        if _loggedIn {
            Service.shared.fetchDashDetails(sessionID: _sessionID) { data, _, _ in
                if let data = data {
                    _name = data.admDetails.name
                }
            }
        }

        // Get the internals
        if _loggedIn {
            Service.shared.fetchInternals(sessionID: _sessionID, semester: _semester) { data, _, _ in
                if let data = data {
                    _internalsData = data
                }
            }
        }

        // Get the results
        if _loggedIn {
            Service.shared.fetchResults(sessionID: _sessionID, semester: _semester) { data, _, _ in
                if let data = data {
                    _resultsData = data
                }
            }
        }

        // Now create an [WatchMessageModel] object with the required values and return it
        return WatchMessageModel(loggedIn: _loggedIn, name: _name, attendanceData: _attendanceData, internalsData: _internalsData, resultsData: _resultsData)
    }

    func messageReceived(tuple: MessageReceived) {
        let toSend = prepareDetails().encodeToData()

        guard let reply = tuple.replyHandler else { return }

        reply(["msg": toSend])
    }
}
