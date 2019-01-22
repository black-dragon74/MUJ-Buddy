//
//  FacultyContactView.swift
//  MUJ Buddy
//
//  Created by Nick on 1/21/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class FacultyContactView: UIViewController {
    
    var currentFaculty: FacultyContactModel? {
        didSet {
            guard let currF = currentFaculty else {return}
            teacherImage.downloadImage(from: currF.image)
            designationLabel.text = currF.designation
            departmentLabel.text = currF.designation
            facultyEmail.text = currF.email
            facultyPhone.text = "+91-\(currF.phone)"
        }
    }
    
    // UI Image view that will contain the image for the teacher
    let teacherImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.layer.masksToBounds = true
        iv.downloadImage(from: "")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    // Bold label to show name
    let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "Teacher Ka Name"
        l.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return l
    }()
    
    // Another label to show the designation
    let designationLabel: UILabel = {
        let d = UILabel()
        d.text = "Asst. Professor"
        d.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return d
    }()
    
    // Department Label
    let departmentLabel: UILabel = {
        let d = UILabel()
        d.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        d.textColor = .lightGray
        d.text = "Department of IT"
        return d
    }()
    
    // Create a separator
    let separator: UIView = {
        let s = UIView()
        s.backgroundColor = UIColor(white: 0.2, alpha: 1)
        s.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return s
    }()
    
    // Contact details info label
    let contactDetails: UILabel = {
        let l = UILabel()
        l.text = "Contact details:"
        l.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        return l
    }()
    
    // Email label
    let emailLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.boldSystemFont(ofSize: 16)
        e.text = "Email: "
        return e
    }()
    
    // Phone label
    let phoneLabel: UILabel = {
        let e = UILabel()
        e.font = UIFont.boldSystemFont(ofSize: 16)
        e.text = "Mobile: "
        return e
    }()
    
    // Real Email
    let facultyEmail: UILabel = {
        let f = UILabel()
        f.text = "someone@something.com"
        return f
    }()
    
    // Real phone number
    let facultyPhone: UILabel = {
        let f = UILabel()
        f.text = "+91-123456789"
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        // Add view to the subviews
        view.addSubview(teacherImage)
        view.addSubview(nameLabel)
        view.addSubview(designationLabel)
        view.addSubview(departmentLabel)
        view.addSubview(separator)
        view.addSubview(contactDetails)
        view.addSubview(emailLabel)
        view.addSubview(phoneLabel)
        view.addSubview(facultyEmail)
        view.addSubview(facultyPhone)
        
        // Set the contraints
        _ = teacherImage.anchorWithConstantsToTop(top: view.centerYAnchor, right: nil, bottom: nil, left: nil, topConstant: -250, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: 120, widthConstant: 120)
        teacherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = nameLabel.anchorWithConstantsToTop(top: teacherImage.bottomAnchor, right: nil, bottom: nil, left: nil, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: nil, widthConstant: nil)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = designationLabel.anchorWithConstantsToTop(top: nameLabel.bottomAnchor, right: nil, bottom: nil, left: nil, topConstant: 5, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: nil, widthConstant: nil)
        designationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = departmentLabel.anchorWithConstantsToTop(top: designationLabel.bottomAnchor, right: nil, bottom: nil, left: nil, topConstant: 5, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: nil, widthConstant: nil)
        departmentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        _ = separator.anchorWithConstantsToTop(top: departmentLabel.bottomAnchor, right: view.rightAnchor, bottom: nil, left: view.leftAnchor, topConstant: 5, rightConstant: 8, bottomConstant: 0, leftConstant: 8, heightConstant: nil, widthConstant: nil)
        
        _ = contactDetails.anchorWithConstantsToTop(top: separator.bottomAnchor, right: nil, bottom: nil, left: view.leftAnchor, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 8, heightConstant: nil, widthConstant: nil)
        
        _ = emailLabel.anchorWithConstantsToTop(top: contactDetails.bottomAnchor, right: nil, bottom: nil, left: view.leftAnchor, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 8, heightConstant: nil, widthConstant: nil)
        
        _ = phoneLabel.anchorWithConstantsToTop(top: emailLabel.bottomAnchor, right: nil, bottom: nil, left: view.leftAnchor, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 8, heightConstant: nil, widthConstant: nil)
        
        _ = facultyEmail.anchorWithConstantsToTop(top: contactDetails.bottomAnchor, right: nil, bottom: nil, left: emailLabel.rightAnchor, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 20, heightConstant: nil, widthConstant: nil)
        
        _ = facultyPhone.anchorWithConstantsToTop(top: facultyEmail.bottomAnchor, right: nil, bottom: nil, left: phoneLabel.rightAnchor, topConstant: 10, rightConstant: 0, bottomConstant: 0, leftConstant: 10, heightConstant: nil, widthConstant: nil)
    }
}
