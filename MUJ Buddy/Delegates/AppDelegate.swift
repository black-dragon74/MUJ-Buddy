//
//  AppDelegate.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationDelegate = AttendanceNotificationDelegate()
    private var launchedShortcutItem: UIApplicationShortcutItem? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Permission error: ", error.localizedDescription)
            }

            if !granted {
                print("Notification permission denied.")
            } else {
                print("Got the permission to display notifications")
            }
        }

        // Required
        return true
    }

    // Perform the actual fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.backgroundRefreshStatus == UIBackgroundRefreshStatus.available && getSessionID() != "NA" {
            Service.shared.getAttendance(sessionID: getSessionID(), isRefresh: true) { (attendance, _, error) in
                if let error = error {
                    print("Refresh error: ", error)
                    completionHandler(.failed)
                    return
                }

                if attendance != nil {
                    // Data save is handled by the API service itself
                    // Just notify the user if need be
                    print("Fetch completed.")
                    if shouldShowAttendanceNotification() && getLowAttendanceCount() > 0 {
                        let nc = UNUserNotificationCenter.current()
                        nc.delegate = self.notificationDelegate
                        setLastAttendanceNotificationDate(to: Date())  // To current date
                        nc.add(prepareNotification(withBody: "Running low in \(getLowAttendanceCount()) subject(s). Tap to check."), withCompletionHandler: { (error) in
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        AppSessionManager.shared.needsReAuth = true  // User will have to reauthenticate with biometrics
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AppSessionManager.shared.needsReAuth = true  // User will have to reauthenticate with biometrics
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if canUseBiometrics() && shouldUseBiometrics() && AppSessionManager.shared.needsReAuth {
            NotificationCenter.default.post(name: .isReauthRequired, object: nil)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // Nil the value as a failsafe measure
        launchedShortcutItem = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
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
            vcToPush = AttendanceViewController()
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
