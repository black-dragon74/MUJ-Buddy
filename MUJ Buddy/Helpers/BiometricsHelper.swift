//
//  BiometricsHelper.swift
//  MUJ Buddy
//
//  Created by Nick on 2/7/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import LocalAuthentication
import UIKit

private let authContext = LAContext()
private let authReason = "To login"
var authError: NSError?

// This function determines whether the user's device supports biometrics authentication
func canUseBiometrics() -> Bool {
    if #available(iOS 8.0, *) {
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            return true
        }
        return false
    }
    return false
}

// This function tells the app if the biometric authentication is to be used
func shouldUseBiometrics() -> Bool {
    UserDefaults.standard.object(forKey: BIOMETRICS_KEY) as? Bool ?? false
}

func setBiometricsState(to: Bool) {
    UserDefaults.standard.removeObject(forKey: BIOMETRICS_KEY)
    UserDefaults.standard.set(to, forKey: BIOMETRICS_KEY)
    UserDefaults.standard.synchronize()
}

//
//  Functions for the biometrics events
//
func takeBiometricAction(navController: UINavigationController) {
    let biometryController = BiometricAuthController()
    biometryController.modalPresentationStyle = .fullScreen
    navController.present(biometryController, animated: true, completion: nil)
}
