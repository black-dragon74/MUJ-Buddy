//
//  FacultyContactCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit


class FacultyContactCell: UITableViewCell {
    
    var currentFaculty: FacultyContactModel? {
        didSet {
            guard let currF = currentFaculty else {return}
            facultyImage.dowloadAndSet(url: currF.image)
            facultyName.text = currF.name
            facultyDesignation.text = currF.designation
        }
    }
    
    // Let's create an image item for the profile image
    lazy var facultyImage: UIImageToDownload = {
        let f = UIImageToDownload()
        f.image = UIImage(named: "dummy")
        f.contentMode = .scaleAspectFill
        f.clipsToBounds = true
        f.layer.cornerRadius = 25 // Half of the cell's height
        f.layer.masksToBounds = true
        return f
    }()
    
    // Name
    let facultyName: UITextView = {
        let n = UITextView()
        n.text = "Dr. Something Something"
        n.textColor = .black
        n.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        n.isEditable = false
        n.isSelectable = false
        n.isScrollEnabled = false
        return n
    }()
    
    // Designation
    let facultyDesignation: UITextView = {
        let n = UITextView()
        n.text = "Senior Professor"
        n.textColor = .lightGray
        n.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        n.isEditable = false
        n.isSelectable = false
        n.isScrollEnabled = false
        return n
    }()
    
    // Override init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Call the func to set up the views
        setupViews()
    }
    
    // Setup the views
    func setupViews() {
        // Add the views to the subviews
        addSubview(facultyImage)
        addSubview(facultyName)
        addSubview(facultyDesignation)
        
        // Set the constraints
        _ = facultyImage.anchorWithConstantsToTop(top: topAnchor, right: nil, bottom: bottomAnchor, left: leftAnchor, topConstant: 5, rightConstant: 0, bottomConstant: 5, leftConstant: 10, heightConstant: nil, widthConstant: 50)
        
        _ = facultyName.anchorWithConstantsToTop(top: topAnchor, right: rightAnchor, bottom: nil, left: facultyImage.rightAnchor, topConstant: 0, rightConstant: 0, bottomConstant: 0, leftConstant: 10, heightConstant: 30, widthConstant: nil)
        
        _ = facultyDesignation.anchorWithConstantsToTop(top: facultyName.bottomAnchor, right: rightAnchor, bottom: nil, left: facultyImage.rightAnchor, topConstant: 0, rightConstant: 0, bottomConstant: 0, leftConstant: 10, heightConstant: 30, widthConstant: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
