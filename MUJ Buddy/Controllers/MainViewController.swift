//
//  MainViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let isLoggedIn = false // TODO: Implement this using UserDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        // If user is not logged in, present the login view controller with a slight delay to prevent thread crash
        if !isLoggedIn {
            perform(#selector(presentLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    @objc fileprivate func presentLoginController() {
        let loginController = LoginViewController()
        
        present(loginController, animated: true) {
            // Laters baby
        }
    }
}
