//
//  CaptchaAuthController.swift
//  MUJ Buddy
//
//  Created by Nick on 8/30/20.
//  Copyright © 2020 Nick. All rights reserved.
//

import UIKit

class CaptchaAuthController: UIViewController {
    // These vars must be set from the presenting VC else the flow will be aborted
    var username: String?
    var password: String?
    
    // Validation variables
    private lazy var canBeDismissed = false
    private lazy var authSuccess = false
    
    // This will be set by the API calls
    private lazy var sessionID: String? = nil
    
    // UIImageView that will contain the CaptchaImage
    private let captchaImageView: UIImageView = {
        let captchaView = UIImageView()
        captchaView.image = UIImage(named: "loading_captcha")
        captchaView.contentMode = .scaleAspectFill
        captchaView.clipsToBounds = true
        captchaView.translatesAutoresizingMaskIntoConstraints = false
        captchaView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        captchaView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return captchaView
    }()
    
    private lazy var captchaTF: LeftPaddedTextField = {
        let captcha = LeftPaddedTextField()
        captcha.placeholder = "Enter the above captcha"
        captcha.translatesAutoresizingMaskIntoConstraints = false
        captcha.layer.borderColor = UIColor.lightGray.cgColor
        captcha.layer.borderWidth = 1
        captcha.delegate = self
        return captcha
    }()

    private let verifyButton: UIButton = {
        let vBtn = UIButton()
        vBtn.backgroundColor = .mujTheme
        vBtn.setTitle("Complete login", for: .normal)
        return vBtn
    }()
    
    private let regenCaptchaButton: UIButton = {
        let rButton = UIButton()
        rButton.backgroundColor = .yellow
        rButton.setTitle("Refresh Captcha", for: .normal)
        return rButton
    }()
    
    private let dismissButton: UIButton = {
        let dBtn = UIButton()
        dBtn.backgroundColor = .red
        dBtn.setTitle("Cancel", for: .normal)
        return dBtn
    }()

    private let progressBar: UIActivityIndicatorView = {
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
        
        navigationItem.title = "Solve the Captcha"
        view.backgroundColor = UIColor(named: "primaryLighter")
        
        preventHijack()
        loadViews()
        getCaptcha()
    }
    
    fileprivate func preventHijack() {
        if username == nil || password == nil {
            Toast(with: "Bugger off tinkerer").show(on: view)
        }
    }
    
    fileprivate func loadViews() {
        // Add views
        view.addSubview(captchaImageView)
        view.addSubview(captchaTF)
        view.addSubview(verifyButton)
        view.addSubview(regenCaptchaButton)
        view.addSubview(dismissButton)
        view.addSubview(progressBar)
        
        // Add Constraints
        captchaImageView.anchorWithConstraints(top: view.centerYAnchor, topOffset: -220)
        captchaImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        captchaTF.anchorWithConstraints(top: captchaImageView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 20, rightOffset: 32, leftOffset: 32, height: 50)

        verifyButton.anchorWithConstraints(top: captchaTF.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 24, rightOffset: 32, leftOffset: 32, height: 50)
        
        regenCaptchaButton.anchorWithConstraints(top: verifyButton.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 12, rightOffset: 32, leftOffset: 32, height: 50)

        dismissButton.anchorWithConstraints(top: regenCaptchaButton.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 12, rightOffset: 32, leftOffset: 32, height: 50)

        progressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Add actions to the buttons
        regenCaptchaButton.addTarget(self, action: #selector(refreshCaptcha), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // There can be 2 cases:
        // - Either the credentials are wrong
        // - Or the user dismissed it using veto
        if !canBeDismissed {
            NotificationCenter.default.post(name: .loginCancelled, object: nil, userInfo: ["message": "Login action was cancelled by the user"])
            return
        }
        
        if canBeDismissed && !authSuccess {
            NotificationCenter.default.post(name: .loginCancelled, object: nil, userInfo: ["message": "Incorrect username or password supplied"])
            return
        }
        
        if canBeDismissed && authSuccess {
            NotificationCenter.default.post(name: .loginSuccessful, object: nil, userInfo: ["sessionID": sessionID!])
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        captchaTF.layer.cornerRadius = 20
        captchaTF.dropShadow()

        verifyButton.layer.cornerRadius = 20
        verifyButton.dropShadow()
        verifyButton.linearGradient(from: #colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1), to: #colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1))
        
        regenCaptchaButton.layer.cornerRadius = 20
        regenCaptchaButton.dropShadow()
        regenCaptchaButton.linearGradient(from: #colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1), to: #colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1))


        dismissButton.layer.cornerRadius = 20
        dismissButton.dropShadow()
        dismissButton.linearGradient(from: #colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1), to: #colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
    
    //MARK:- Button handlers
    @objc fileprivate func refreshCaptcha() {
        getCaptcha()
    }
    
    @objc fileprivate func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func handleVerify() {
        // Update validators
        self.canBeDismissed = false
        self.authSuccess = false
        
        // Unwrap
        guard let user = username,
            let pass = password,
            captchaTF.text != nil,
            let session = sessionID
            else { return }
        
        progressBar.startAnimating()
        view.endEditing(true)
        
        Service.shared.completeAuthWithCaptcha(sessionID: session, userName: user, password: pass, captcha: captchaTF.text!) {[unowned self] (response, err) in
            // Check for error first
            if let err = err {
                print(err.localizedDescription)
                DispatchQueue.main.async {
                    self.progressBar.stopAnimating()
                }
                return
            }
            
            // Parse the response
            if let response = response {
                // Check if the captcha was successful
                if response.captchaFailed {
                    DispatchQueue.main.async {
                        Toast(with: "Invalid captcha, try again..").show(on: self.view)
                        self.progressBar.stopAnimating()
                        self.captchaTF.text = nil
                        self.captchaTF.becomeFirstResponder()
                    }
                    return
                }
                
                // Otherwise, creds might be wrong
                if response.credentialsError {
                    self.canBeDismissed = true
                    self.authSuccess = false
                    DispatchQueue.main.async {
                        self.progressBar.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                // Else, we got in
                if response.loginSucceeded {
                    self.sessionID = response.sessionid
                    self.canBeDismissed = true
                    self.authSuccess = true
                    DispatchQueue.main.async {
                        self.progressBar.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
            }
        }
    }
    
    //MARK:- API Calls
    fileprivate func getCaptcha() {
        // Start animating the progress view
        progressBar.startAnimating()
        
        // Make the call to the API
        Service.shared.fetchCaptchaFromServer {[unowned self] (response, error) in
            // Error handling
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.progressBar.stopAnimating()
                }
                return
            }
            
            // Parse the response
            if let response = response {
                self.sessionID = response.sessionid
                guard let imageData = Data(base64Encoded: response.encodedImage) else { return }
                DispatchQueue.main.async {
                    self.progressBar.stopAnimating()
                    self.captchaImageView.image = UIImage(data: imageData)
                }
                return
            }
        }
    }
}

extension CaptchaAuthController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
