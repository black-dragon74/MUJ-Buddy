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
        u.keyboardType = .numberPad
        return u
    }()

    let passwordField: LeftPaddedTextField = {
        let p = LeftPaddedTextField()
        p.placeholder = "Enter your password"
        p.layer.borderColor = UIColor.lightGray.cgColor
        p.layer.borderWidth = 0.5
        p.isSecureTextEntry = true
        return p
    }()

    let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .orange
        b.setTitle("Log In", for: .normal)
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
    }

    func setupViews() {
        // Add child views to the subviews
        addSubview(progressBar)
        addSubview(logoView)
        addSubview(userTextField)
        addSubview(passwordField)
        addSubview(loginButton)
        addSubview(cpyLabel)

        // Set the constraints
        progressBar.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        progressBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        _ = logoView.anchorWithConstantsToTop(top: centerYAnchor, right: nil, bottom: nil, left: nil, topConstant: -200, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: 150, widthConstant: 150)
        logoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        _ = userTextField.anchorWithConstantsToTop(top: logoView.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topConstant: 16, rightConstant: 32, bottomConstant: 0, leftConstant: 32, heightConstant: 50, widthConstant: nil)

        _ = passwordField.anchorWithConstantsToTop(top: userTextField.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topConstant: 6, rightConstant: 32, bottomConstant: 0, leftConstant: 32, heightConstant: 50, widthConstant: nil)

        _ = loginButton.anchorWithConstantsToTop(top: passwordField.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topConstant: 12, rightConstant: 32, bottomConstant: 0, leftConstant: 32, heightConstant: 50, widthConstant: nil)

        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        cpyLabel.anchorWithConstraints(bottom: safeAreaLayoutGuide.bottomAnchor, bottomOffset: 5)
        cpyLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Handle login
    @objc fileprivate func handleLogin() {
        endEditing(true)
        if let delegate = delegate {
            delegate.handleLogin()
        }
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
