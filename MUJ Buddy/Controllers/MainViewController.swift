//
//  MainViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    let isLoggedIn = true // TODO: Implement this using UserDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        
        // If user is not logged in, present the login view controller with a slight delay to prevent thread crash
        if !isLoggedIn {
            perform(#selector(presentLoginController), with: nil, afterDelay: 0.01)
        }
        
        // Call the setup views function
        setupViews()
    }
    
    fileprivate func setupViews() {
        // Set the views to the tabs
        
        let dashController = DashboardViewController()
        dashController.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        
        
        let acadController = AcademicsViewController()
        acadController.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        
        
        let conController = ContactsViewController()
        conController.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 2)
        
        
        let aboutController = AboutViewController()
        aboutController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
        
        // Construct the list of the views
        let controllersForTabBar = [dashController, acadController, conController, aboutController]
        
        viewControllers = controllersForTabBar.map{UINavigationController(rootViewController: $0)}
    }
    
    @objc fileprivate func presentLoginController() {
        let loginController = LoginViewController()
        
        present(loginController, animated: true) {
            // Laters baby
        }
    }
}
