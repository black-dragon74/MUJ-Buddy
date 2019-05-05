//
//  LoginCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class LoginCell: UICollectionViewCell {

    // Delegate
    weak var delegate: LoginDelegate?
    
    // The login button's title based on client type
    private var loginTitle: String = "Student Login"
    
    // The client to login for
    private var loginFor: String = "student"

    // Image view to contain the logo
    let logoView: UIImageView = {
        let l = UIImageView()
        l.image = UIImage(named: "mu_logo")
        l.contentMode = .scaleAspectFit
        return l
    }()

    let userTextField: LeftPaddedTextField = {
        let u = LeftPaddedTextField()
        u.placeholder = "Enter DMS userid"
        u.layer.borderColor = UIColor.lightGray.cgColor
        u.layer.borderWidth = 1
        u.layer.cornerRadius = 20
        u.keyboardType = .numberPad
        return u
    }()

    let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .orange
        b.setTitle("Send OTP", for: .normal)
        b.setTitleColor(.white, for: .normal)
        return b
    }()

    // Progress bar to show while loggin in
    let progressBar: UIActivityIndicatorView = {
        let p = UIActivityIndicatorView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.style = .whiteLarge
        p.color = .red
        p.hidesWhenStopped = true
        return p
    }()
    
    // Info label
    let cpyLabel: UILabel = {
        let cLabel = UILabel()
        cLabel.textColor = .darkGray
        cLabel.text = "Crafted with love by Nick"
        cLabel.font = UIFont.systemFont(ofSize: 12)
        return cLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Setup the views
        setupViews()
        
        // Call the selector manually for propagation of the values
        handleSegmentWith(index: 0)
    }

    func setupViews() {
        // Add child views to the subviews
        addSubview(progressBar)
        addSubview(logoView)
        addSubview(userTextField)
        addSubview(loginButton)
        addSubview(cpyLabel)

        // Set the constraints
        progressBar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        _ = logoView.anchorWithConstantsToTop(top: centerYAnchor, right: nil, bottom: nil, left: nil, topConstant: -220, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: 150, widthConstant: 150)
        logoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        _ = userTextField.anchorWithConstantsToTop(top: logoView.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topConstant: 24, rightConstant: 32, bottomConstant: 0, leftConstant: 32, heightConstant: 50, widthConstant: nil)


        _ = loginButton.anchorWithConstantsToTop(top: userTextField.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topConstant: 24, rightConstant: 32, bottomConstant: 0, leftConstant: 32, heightConstant: 50, widthConstant: nil)

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
//        loginSelector.addTarget(self, action: #selector(handleLoginSelector), for: .valueChanged)
        
        cpyLabel.anchorWithConstraints(bottom: safeAreaLayoutGuide.bottomAnchor, bottomOffset: 5)
        cpyLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        progressBar.layer.zPosition = 999
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        loginButton.layer.cornerRadius = 20
        loginButton.dropShadow()
        loginButton.linearGradient(from: #colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1), to: #colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1))
        
        userTextField.dropShadow()
    }

    // Handle login
    @objc fileprivate func handleLogin() {
        endEditing(true)
        if let delegate = delegate {
            delegate.handleLogin(for: loginFor)
        }
    }
    
    // Handle switch
    @objc fileprivate func handleLoginSelector(_ sender: UISegmentedControl) {
        handleSegmentWith(index: sender.selectedSegmentIndex)
    }
    
    // Function to update the title and the client based on segment's value
    fileprivate func handleSegmentWith(index: Int) {
        if index == 0 {
            loginButton.setTitle("Send OTP", for: .normal)
            loginFor = "student"
        }
//        else {
//            loginButton.setTitle("Parent Login", for: .normal)
//            loginFor = "parent"
//        }
    }
}

class LeftPaddedTextField: UITextField {
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
}
