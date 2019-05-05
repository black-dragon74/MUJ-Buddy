//
//  AppInfoViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 3/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {
    
    // The image view that will contain the logo
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.image = UIImage(named: "store_icon")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return imgView
    }()
    
    let textView: UILabel = {
        let tView = UILabel()
        tView.textAlignment = .justified
        tView.numberOfLines = 10
        tView.text = "This is just a hobby project and also my very first iOS App.\n\n\n\nNo external libraries have been used in creating this app."
        return tView
    }()
    
    let copyrightLabel: UILabel = {
        let cLabel = UILabel()
        cLabel.textColor = .darkGray
        cLabel.text = "Crafted with love by Nick"
        cLabel.translatesAutoresizingMaskIntoConstraints = false
        cLabel.font = UIFont.systemFont(ofSize: 12)
        return cLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
        let appversion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        
        navigationItem.setHeader(title: appName, subtitle: "Version "+appversion)
        
        view.backgroundColor = .white
        
        setupAdditionalViews()
    }
    
    fileprivate func setupAdditionalViews() {
        view.addSubview(imageView)
        view.addSubview(textView)
        view.addSubview(copyrightLabel)
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        
        textView.anchorWithConstraints(top: imageView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 20, rightOffset: 16, leftOffset: 16)
        
        copyrightLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        copyrightLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
    }
    
    @objc fileprivate func handleBiometricAuth() {
        self.navigationController?.present(BiometricAuthController(), animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }
}
