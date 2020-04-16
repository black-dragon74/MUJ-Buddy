//
//  BiometricAuthView.swift
//  MUJ Buddy
//
//  Created by Nick on 2/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import LocalAuthentication
import UIKit

class BiometricAuthController: UIViewController {
    let authCtx = LAContext()
    let authRe = "Biometrics is required to unlock \(Bundle.main.infoDictionary!["CFBundleName"] as! String)"

    let authStatusLabel: UILabel = {
        let authLabel = UILabel()
        authLabel.font = UIFont.boldSystemFont(ofSize: 17)
        authLabel.translatesAutoresizingMaskIntoConstraints = false
        authLabel.alpha = 0
        authLabel.numberOfLines = 3
        return authLabel
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleReauth), name: .isReauthRequired, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(authStatusLabel)
        authStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        authStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        handleBiometricHandshake()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleReauth)))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    func handleBiometricHandshake() {
        if canUseBiometrics() {
            authStatusLabel.text = "" // Reset the text
            authCtx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authRe) { success, error in
                if success {
                    print("Biometric auth successful")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
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
        } else {
            authStatusLabel.text = authError!.localizedDescription
            DispatchQueue.main.async {
                self.authStatusLabel.text = authError?.localizedDescription ?? "Unable to acquire biometric device"
                UIView.animate(withDuration: 1, animations: {
                    self.authStatusLabel.alpha = 1
                })
            }
        }
    }

    @objc fileprivate func handleReauth() {
        handleBiometricHandshake()
    }
}
