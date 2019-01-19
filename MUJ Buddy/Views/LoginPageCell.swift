//
//  LoginPageCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// Defines the layout of the cell on the login page
class LoginPageCell: UICollectionViewCell {
    
    var page: LoginPage? {
        didSet {
            
            // Verify that the value being set in an instance of Page
            guard let page = page else {return}
            
            // Set the image
            imageView.image = UIImage(named: page.image)
            
            // Set the text with attributes
            let color = UIColor(white: 0.3, alpha: 1)
            let attributedText = NSMutableAttributedString(string: page.title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor: color])
            attributedText.append(NSAttributedString(string: "\n\n\(page.subtitle)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: color]))
            let pStyle = NSMutableParagraphStyle()
            pStyle.alignment = .center
            let len = attributedText.string.count
            attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: pStyle, range: NSRange(location: 0, length: len))
            textView.attributedText = attributedText
        }
    }
    
    // Image view that will contain the image to show
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // Text view that will contain the description text
    let textView: UITextView = {
        let tv = UITextView()
        tv.isSelectable = false
        tv.isEditable = false
        tv.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        return tv
    }()
    
    // A spearator, that thin grey line :P
    let separator: UIView = {
        let s = UIView()
        s.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return s
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    func setupViews() {
        // Add to the cell's view
        addSubview(imageView)
        addSubview(textView)
        addSubview(separator)
        
        // Set the constraints
        imageView.anchorToTop(top: topAnchor, right: rightAnchor, bottom: textView.topAnchor, left: leftAnchor)
        _ = textView.anchorWithConstantsToTop(top: nil, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topConstant: 0, rightConstant: 16, bottomConstant: 0, leftConstant: 16)
        textView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3).isActive = true
        separator.anchorToTop(top: nil, right: rightAnchor, bottom: textView.topAnchor, left: leftAnchor)
        separator.heightAnchor.constraint(equalToConstant: 2).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
