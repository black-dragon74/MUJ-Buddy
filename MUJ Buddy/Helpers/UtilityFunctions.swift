//
//  UtilityFunctions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

func reloadTableView(tableViewToReload: UITableView) {
    tableViewToReload.reloadData()
}


func showAlert(with message: String) -> UIAlertController {
    let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
    let actionDismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(actionDismiss)
    return alertController
}

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
