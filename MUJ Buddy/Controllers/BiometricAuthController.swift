//
//  BiometricAuthView.swift
//  MUJ Buddy
//
//  Created by Nick on 2/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import LocalAuthentication

class BiometricAuthController: UIViewController {
    
    let authStatusLabel: UILabel = {
        let authLabel = UILabel()
        authLabel.font = UIFont.boldSystemFont(ofSize: 17)
        authLabel.translatesAutoresizingMaskIntoConstraints = false
        authLabel.alpha = 0
        authLabel.numberOfLines = 3
        return authLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.addSubview(authStatusLabel)
        authStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        authStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        handleBiometricHandshake()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reAuth)))
    }
    
    func handleBiometricHandshake() {
        if canUseBiometrics() {
            self.authStatusLabel.text = ""  // Reset the text
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason) {(success, error) in
                if success {
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
                else {
                    print("Auth failed")
                    DispatchQueue.main.async {
                        self.authStatusLabel.text = "Biometric authentication failed."
                        UIView.animate(withDuration: 1, animations: {
                            self.authStatusLabel.alpha = 1
                        })
                    }
                }
                
                if error != nil {
                    print(error!.localizedDescription)
                }
            }
        }
        else {
            self.authStatusLabel.text = authError!.localizedDescription
            DispatchQueue.main.async {
                self.authStatusLabel.text = authError?.localizedDescription ?? "Unable to acquire biometric device"
                UIView.animate(withDuration: 1, animations: {
                    self.authStatusLabel.alpha = 1
                })
            }
        }
    }
    
    @objc fileprivate func reAuth() {
        handleBiometricHandshake()
    }
}
