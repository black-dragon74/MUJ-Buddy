//
//  StudentDetailedView.swift
//  MUJ Buddy
//
//  Created by Nick on 2/12/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import Photos

class StudentDetailedView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // The current instance of the dashboard
    var currentDash: DashboardModel? {
        didSet {
            guard let dash = currentDash else { return }
            // Basics
            nameTF.text = dash.admDetails.name
            progTF.text = dash.admDetails.program
            //TODO:- Add support for profile image
            
            // Parent details
            fatherTF.text = dash.parentDetails.father.capitalizeFirstLetter()
            motherTF.text = dash.parentDetails.mother.capitalizeFirstLetter()
            mobileTF.text = dash.parentDetails.mobileNo
        }
    }
    
    // That orange-y view
    let orangeview: UIImageView = {
        let oView = UIImageView()
        oView.clipsToBounds = true
        oView.contentMode = .scaleAspectFill
        return oView
    }()
    
    // Blurred image view
    let blurredProfileImage: UIImageView = {
        let blurred = UIImageView()
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
    
    // Parent details elements will be contained here
    let parentCatLabel: UILabel = {
        let pcLabel = UILabel()
        pcLabel.text = "Parent Details".uppercased()
        pcLabel.textColor = .white
        pcLabel.textAlignment = .center
        pcLabel.translatesAutoresizingMaskIntoConstraints = false
        pcLabel.font = UIFont.boldSystemFont(ofSize: 15)
        return pcLabel
    }()
    
    // Father label
    let fatherLabel: UILabel = {
        let fLabel = UILabel()
        fLabel.textColor = .white
        fLabel.text = "Father:"
        fLabel.font = UIFont.systemFont(ofSize: 15)
        return fLabel
    }()
    
    // Father Text
    let fatherTF: UILabel = {
        let fLabel = UILabel()
        fLabel.textColor = .white
        fLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return fLabel
    }()
    
    // Mother label
    let motherLabel: UILabel = {
        let mLabel = UILabel()
        mLabel.textColor = .white
        mLabel.text = "Mother:"
        mLabel.font = UIFont.systemFont(ofSize: 15)
        return mLabel
    }()
    
    // Mother Text
    let motherTF: UILabel = {
        let fLabel = UILabel()
        fLabel.textColor = .white
        fLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return fLabel
    }()
    
    // Mobile label
    let mobileLabel: UILabel = {
        let mLabel = UILabel()
        mLabel.text = "Mobile:"
        mLabel.textColor = .white
        mLabel.font = UIFont.systemFont(ofSize: 15)
        return mLabel
    }()
    
    // Mobile Text
    let mobileTF: UILabel = {
        let fLabel = UILabel()
        fLabel.textColor = .white
        fLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return fLabel
    }()
    
    // Scroll view to contain cards
    let scrollView: UIScrollView = {
        let sView = UIScrollView()
        return sView
    }()
    
    // The parent details card
    let parentCard: UIView = {
        let pCard = UIView()
        pCard.dropShadow()
        pCard.backgroundColor = .navyBlue
        pCard.translatesAutoresizingMaskIntoConstraints = false
        pCard.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return pCard
    }()
    
    
    
    // Separator
    let pSeparator: UIView = {
        let ps = UIView()
        ps.translatesAutoresizingMaskIntoConstraints = false
        ps.heightAnchor.constraint(equalToConstant: 1).isActive = true
        ps.backgroundColor = .lightGray
        return ps
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
        view.backgroundColor = .primaryLighter
        
        setupViews()
        
        renderDynamicBlur()
    }
    
    fileprivate func renderDynamicBlur() {
        // If UIImage is there in the DB, use that
        if let image = getProfileImage() {
            orangeview.image = image
            blurredProfileImage.image = image
            profileImage.image = image
            
            // Exit
            return
        }
        
        // Else, fallback baby!
        orangeview.image = UIImage(named: "nick")
        blurredProfileImage.image = UIImage(named: "nick")
        profileImage.image = UIImage(named: "nick")
        
    }
    
    fileprivate func setupViews() {
        // Add blur effect to the header
        let blurView = UIBlurEffect(style: .regular)
        let blur = UIVisualEffectView(effect: blurView)
        view.addSubview(orangeview)
        view.addSubview(blur)
        view.addSubview(nameTF)
        view.addSubview(progTF)
        
        view.addSubview(scrollView)
        scrollView.anchorWithConstraints(top: progTF.bottomAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, topOffset: 10, rightOffset: 0, bottomOffset: 0, leftOffset: 0)
        
        scrollView.addSubview(parentCard)
        
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
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        
        //NameTF constraints
        nameTF.anchorWithConstraints(top: profileBlurView.bottomAnchor, topOffset: 10)
        nameTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Program tf constraints
        progTF.anchorWithConstraints(top: nameTF.bottomAnchor, topOffset: 5)
        progTF.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Parent card anchors
        parentCard.anchorWithConstraints(top: scrollView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, rightOffset: 10, leftOffset: 10)
        
        // Add elements to the card
        parentCard.addSubview(parentCatLabel)
        parentCard.addSubview(pSeparator)
        parentCard.addSubview(fatherLabel)
        parentCard.addSubview(fatherTF)
        parentCard.addSubview(motherLabel)
        parentCard.addSubview(motherTF)
        parentCard.addSubview(mobileLabel)
        parentCard.addSubview(mobileTF)
        
        
        // Parent's card elements
        // The category label
        parentCatLabel.topAnchor.constraint(equalTo: parentCard.topAnchor, constant: 5).isActive = true
        parentCatLabel.centerXAnchor.constraint(equalTo: parentCard.centerXAnchor).isActive = true
        
        // The separator
        pSeparator.anchorWithConstraints(top: parentCatLabel.bottomAnchor, right: parentCard.rightAnchor, left: parentCard.leftAnchor, topOffset: 2, rightOffset: 10, leftOffset: 10)
        
        // Father Label
        fatherLabel.anchorWithConstraints(top: pSeparator.bottomAnchor, left: parentCard.leftAnchor, topOffset: 10, leftOffset: 10)
        fatherTF.anchorWithConstraints(top: pSeparator.bottomAnchor, right: parentCard.rightAnchor, left: fatherLabel.rightAnchor, topOffset: 10, rightOffset: 10, leftOffset: 14)
        
        // Mother Label
        motherLabel.anchorWithConstraints(top: fatherLabel.bottomAnchor, left: parentCard.leftAnchor, topOffset: 10, leftOffset: 10)
        motherTF.anchorWithConstraints(top: fatherLabel.bottomAnchor, left: motherLabel.rightAnchor, topOffset: 10, rightOffset: 10, leftOffset: 8)
        
        // Mobile Label
        mobileLabel.anchorWithConstraints(top: motherLabel.bottomAnchor, left: parentCard.leftAnchor, topOffset: 10, leftOffset: 10)
        mobileTF.anchorWithConstraints(top: motherLabel.bottomAnchor, left: mobileLabel.rightAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)
    }
    
    @objc fileprivate func handleImageTap() {
        // Create a UIImagePickerView
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    //MARK:- Picker delegate
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            orangeview.image = pickedImage
            blurredProfileImage.image = pickedImage
            profileImage.image = pickedImage
            
            // Save the image somehow in the UserDefaults by converting to data
            if let imageData = pickedImage.pngData() {
                setProfileImage(image: imageData)
            }
        }
        
        // Dismiss the view controller
        dismiss(animated: true, completion: nil)
    }
}
