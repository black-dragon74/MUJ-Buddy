//
//  OTPAuthController.swift
//  MUJ Buddy
//
//  Created by Nick on 4/26/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class OTPAuthController: UIViewController {
    
    var sessionID: String?
    var userID: String?
    var vs: String?
    var ev: String?
    
    let logo: UIImageView = {
        let logov = UIImageView()
        logov.contentMode = .scaleAspectFill
        logov.clipsToBounds = true
        logov.translatesAutoresizingMaskIntoConstraints = false
        logov.image = UIImage(named: "otp_auth")
        logov.heightAnchor.constraint(equalToConstant: 150).isActive = true
        logov.widthAnchor.constraint(equalToConstant: 150).isActive = true
        logov.layer.masksToBounds = true
        logov.layer.cornerRadius = (150 / 2)
        return logov
    }()
    
    let otpTF: LeftPaddedTextField = {
        let otp = LeftPaddedTextField()
        otp.keyboardType = .numberPad
        otp.placeholder = "Enter the 4 digit OTP"
        otp.translatesAutoresizingMaskIntoConstraints = false
        otp.layer.borderColor = UIColor.lightGray.cgColor
        otp.layer.borderWidth = 1
        otp.isSecureTextEntry = true
        if #available(iOS 12.0, *) {
            otp.textContentType = .oneTimeCode
        }
        return otp
    }()
    
    let verifyButton: UIButton = {
        let vBtn = UIButton()
        vBtn.backgroundColor = DMSColors.orangeish.value
        vBtn.setTitle("Verify OTP", for: .normal)
        return vBtn
    }()
    
    let dismissButton: UIButton = {
        let dBtn = UIButton()
        dBtn.backgroundColor = .red
        dBtn.setTitle("Cancel", for: .normal)
        return dBtn
    }()
    
    let progressBar: UIActivityIndicatorView = {
        let pBar = UIActivityIndicatorView()
        pBar.style = .whiteLarge
        pBar.color = .red
        pBar.translatesAutoresizingMaskIntoConstraints = false
        pBar.layer.zPosition = 999
        pBar.hidesWhenStopped = true
        return pBar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "OTP Authentication"
        
        view.backgroundColor = .white
        
        // Setup rest of the view here
        setupViews()
        
        // Print the values
        preventViewHijack()
        
        verifyButton.addTarget(self, action: #selector(handleOTPVerification), for: .touchUpInside)
    }
    
    fileprivate func setupViews() {
        // Add the subviews
        view.addSubview(logo)
        view.addSubview(otpTF)
        view.addSubview(verifyButton)
        view.addSubview(dismissButton)
        view.addSubview(progressBar)
        
        // Add the constraints
        logo.anchorWithConstraints(top: view.centerYAnchor, topOffset: -220)
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        otpTF.anchorWithConstraints(top: logo.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 20, rightOffset: 32, leftOffset: 32, height: 50)
        
        verifyButton.anchorWithConstraints(top: otpTF.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 12, rightOffset: 32, leftOffset: 32, height: 50)
        
        dismissButton.anchorWithConstraints(top: verifyButton.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 12, rightOffset: 32, leftOffset: 32, height: 50)
        
        progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        dismissButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
    }
    
    // Dismisses the current controller
    @objc fileprivate func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    // Prevent view hijacking
    fileprivate func preventViewHijack() {
        guard sessionID != nil,
        userID != nil,
        ev != nil,
        vs != nil
        else {
            Toast(with: "Bugger off tinkerer!").show(on: self.view)
            return
        }
    }
    
    // I deal with the mess
    @objc fileprivate func handleOTPVerification() {
        guard let userid = userID,
        let sessionid = sessionID,
        let ev = ev,
        let vs = vs,
        let otp = otpTF.text
        else { return }
        
        view.endEditing(true)
        
        // Show the progress bar
        enableProgressBar()
        
        Service.shared.finishAuth(for: userid, session: sessionid, otp: otp, vs: vs, ev: ev) {[weak self] (resp, err) in
            if let error = err {
                print(error.localizedDescription)
                self?.disableProgressBar()
                return
            }
            
            if let resp = resp {
                if (!resp.success) {
                    guard let e = resp.error else { return }
                    DispatchQueue.main.async {
                        Toast(with: e).show(on: self?.view)
                    }
                    self?.disableProgressBar()
                    return
                }
                
                // Else, we have successfully logged in
                // Predict the semester
                // Update the login state
                // Store the sessionID and the userID
                
                // Predict the semester
                var currSem: Int = -1
                let regDate = admDateFrom(regNo: userid)
                let monthSinceAdmission = regDate.monthsTillNow()
                
                // Now we just have to divide the months by 6 and floor it away from zero to get current semester
                let rawSem = (Float(monthSinceAdmission) / 6).rounded(.awayFromZero)
                currSem = Int(rawSem)  // Cast to int to get the exact value
                
                // Purge User Defaults
                purgeUserDefaults()
                
                // Set semester in the DB
                setSemester(as: currSem)
                
                // Update the credentials in the DB
                setUserID(to: userid)
                setSessionID(to: resp.sid)
                
                // Update the login state
                setLoginState(to: true)
                
                // Time to finally present the controller
                DispatchQueue.main.async {
                    let newController = UINavigationController(rootViewController: DashboardViewController())
                    newController.modalTransitionStyle = .crossDissolve
                    self?.present(newController, animated: true, completion: nil)
                }
                
                return
            }
        }
    }
    
    fileprivate func enableProgressBar() {
        DispatchQueue.main.async {
            self.progressBar.startAnimating()
            self.verifyButton.isUserInteractionEnabled = false
            self.dismissButton.isUserInteractionEnabled = false
        }
    }
    
    fileprivate func disableProgressBar() {
        DispatchQueue.main.async {
            self.progressBar.stopAnimating()
            self.verifyButton.isUserInteractionEnabled = true
            self.dismissButton.isUserInteractionEnabled = true
        }
    }
}
