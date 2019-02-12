//
//  StudentDetailedView.swift
//  MUJ Buddy
//
//  Created by Nick on 2/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class StudentDetailedView: UIViewController {
    
    // The current instance of the dashboard
    var currentDash: DashboardModel? {
        didSet {
            guard let dash = currentDash else { return }
            // Basics
            nameTF.text = dash.admDetails.name
            progTF.text = dash.admDetails.program
            //TODO:- Add support for profile image
            
            // Parent details
            fatherTF.text = dash.parentDetails.father.uppercased()
            motherTF.text = dash.parentDetails.mother.uppercased()
            emailTF.text = dash.parentDetails.email.lowercased()
            mobileTF.text = dash.parentDetails.mobileNo
            emergencyTF.text = dash.parentDetails.emergencyContact
        }
    }
    
    // That orange-y view
    let orangeview: UIImageView = {
        let oView = UIImageView()
        oView.image = UIImage(named: "galaxy")
        oView.clipsToBounds = true
        oView.contentMode = .scaleAspectFill
        oView.backgroundColor = DMSColors.orangeish.value
        return oView
    }()
    
    // Blurred image view
    let blurredProfileImage: UIImageView = {
        let blurred = UIImageView()
        blurred.image = UIImage(named: "nick")
        blurred.contentMode = .scaleAspectFill
        blurred.translatesAutoresizingMaskIntoConstraints = false
        blurred.heightAnchor.constraint(equalToConstant: 170).isActive = true
        blurred.widthAnchor.constraint(equalToConstant: 170).isActive = true
        blurred.layer.cornerRadius = 85
        blurred.layer.masksToBounds = true
        return blurred
    }()
    
    // Profile blur view
    let profileBlurView: UIVisualEffectView = {
        let blurProfile = UIBlurEffect(style: .light)
        let pbView = UIVisualEffectView(effect: blurProfile)
        pbView.layer.masksToBounds = true
        pbView.layer.cornerRadius = 85
        pbView.translatesAutoresizingMaskIntoConstraints = false
        pbView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        pbView.widthAnchor.constraint(equalToConstant: 170).isActive = true
        return pbView
    }()
    
    // Image view
    let profileImage: UIImageView = {
        let pImage = UIImageView()
        pImage.image = UIImage(named: "nick")
        pImage.contentMode = .scaleAspectFill
        pImage.clipsToBounds = true
        pImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
        pImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        pImage.layer.cornerRadius = 75
        pImage.layer.masksToBounds = true
        return pImage
    }()
    
    // Name text field
    let nameTF: UILabel = {
        let namelbl = UILabel()
        namelbl.font = UIFont.boldSystemFont(ofSize: 17)
        namelbl.translatesAutoresizingMaskIntoConstraints = false
        namelbl.text = " "
        return namelbl
    }()
    
    // Program tf
    let progTF: UILabel = {
        let progtf = UILabel()
        progtf.textColor = .lightGray
        progtf.font = UIFont.boldSystemFont(ofSize: 14)
        progtf.numberOfLines = 2
        progtf.text = " "
        return progtf
    }()
    
    // The scroll view that will contain the rest of the stuff
    let scrollableView: UIScrollView = {
        let sView = UIScrollView()
        return sView
    }()
    
    // Parent details elements will be contained here
    let parentCatLabel: UILabel = {
        let pcLabel = UILabel()
        pcLabel.text = "Parent Details:".uppercased()
        pcLabel.textColor = .gray
        pcLabel.font = UIFont.boldSystemFont(ofSize: 15)
        return pcLabel
    }()
    
    // Father label
    let fatherLabel: UILabel = {
        let fLabel = UILabel()
        fLabel.text = "Father:"
        fLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        return fLabel
    }()
    
    // Father Text
    let fatherTF: UILabel = {
        let fLabel = UILabel()
        return fLabel
    }()
    
    // Mother label
    let motherLabel: UILabel = {
        let mLabel = UILabel()
        mLabel.text = "Mother:"
        mLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        return mLabel
    }()
    
    // Mother Text
    let motherTF: UILabel = {
        let fLabel = UILabel()
        return fLabel
    }()
    
    // Email label
    let emailLabel: UILabel = {
        let eLabel = UILabel()
        eLabel.text = "Email:"
        eLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        return eLabel
    }()
    
    // Email Text
    let emailTF: UILabel = {
        let fLabel = UILabel()
        return fLabel
    }()
    
    // Mobile label
    let mobileLabel: UILabel = {
        let mLabel = UILabel()
        mLabel.text = "Mobile:"
        mLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        return mLabel
    }()
    
    // Mobile Text
    let mobileTF: UILabel = {
        let fLabel = UILabel()
        return fLabel
    }()
    
    // Emergency label
    let emergencyLabel: UILabel = {
        let eLabel = UILabel()
        eLabel.text = "Emergency:"
        eLabel.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        return eLabel
    }()
    
    // Emergency Text
    let emergencyTF: UILabel = {
        let fLabel = UILabel()
        return fLabel
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Student Details"
        view.backgroundColor = DMSColors.primaryLighter.value
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        // Add blur effect to the header
        let blurView = UIBlurEffect(style: .regular)
        let blur = UIVisualEffectView(effect: blurView)
        view.addSubview(orangeview)
        view.addSubview(blur)
        view.addSubview(nameTF)
        view.addSubview(progTF)
        view.addSubview(scrollableView)
        
        // All the rest of the items will be in the scroll view
        scrollableView.addSubview(parentCatLabel)
        scrollableView.addSubview(fatherLabel)
        scrollableView.addSubview(motherLabel)
        scrollableView.addSubview(emailLabel)
        scrollableView.addSubview(mobileLabel)
        scrollableView.addSubview(emergencyLabel)
        
        scrollableView.addSubview(fatherTF)
        scrollableView.addSubview(motherTF)
        scrollableView.addSubview(emailTF)
        scrollableView.addSubview(mobileTF)
        scrollableView.addSubview(emergencyTF)
        
        // That header constraints
        orangeview.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, height: view.frame.height / 6)
        blur.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, height: view.frame.height / 6)
        
        // Profile image
        view.addSubview(blurredProfileImage)
        view.addSubview(profileBlurView)
        blurredProfileImage.anchorWithConstraints(top: orangeview.bottomAnchor, topOffset: -85)
        blurredProfileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileBlurView.anchorWithConstraints(top: orangeview.bottomAnchor, topOffset: -85)
        profileBlurView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Profile image
        view.addSubview(profileImage)
        profileImage.anchorWithConstraints(top: orangeview.bottomAnchor, topOffset: -75)
        profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //NameTF constraints
        nameTF.anchorWithConstraints(top: profileBlurView.bottomAnchor, topOffset: 10)
        nameTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Program tf constraints
        progTF.anchorWithConstraints(top: nameTF.bottomAnchor, topOffset: 5)
        progTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Scrollable view anchors
        scrollableView.anchorWithConstraints(top: progTF.bottomAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)
        
        // Parent category label anchors
        parentCatLabel.anchorWithConstraints(top: scrollableView.topAnchor, left: scrollableView.leftAnchor)
        fatherLabel.anchorWithConstraints(top: parentCatLabel.bottomAnchor, left: scrollableView.leftAnchor, topOffset: 10)
        motherLabel.anchorWithConstraints(top: fatherLabel.bottomAnchor, left: scrollableView.leftAnchor, topOffset: 5)
        emailLabel.anchorWithConstraints(top: motherLabel.bottomAnchor, left: scrollableView.leftAnchor, topOffset: 5)
        mobileLabel.anchorWithConstraints(top: emailLabel.bottomAnchor, left: scrollableView.leftAnchor, topOffset: 5)
        emergencyLabel.anchorWithConstraints(top: mobileLabel.bottomAnchor, left: scrollableView.leftAnchor, topOffset: 5)
        
        // Parent category text field anchors
        fatherTF.anchorWithConstraints(top: parentCatLabel.bottomAnchor, left: fatherLabel.rightAnchor, topOffset: 10, leftOffset: 10)
        motherTF.anchorWithConstraints(top: fatherLabel.bottomAnchor, left: motherLabel.rightAnchor, topOffset: 5, leftOffset: 10)
        emailTF.anchorWithConstraints(top: motherLabel.bottomAnchor, left: emailLabel.rightAnchor, topOffset: 5, leftOffset: 10)
        mobileTF.anchorWithConstraints(top: emailLabel.bottomAnchor, left: mobileLabel.rightAnchor, topOffset: 5, leftOffset: 10)
        emergencyTF.anchorWithConstraints(top: mobileLabel.bottomAnchor, left: emergencyLabel.rightAnchor, topOffset: 5, leftOffset: 10)
    }
}
