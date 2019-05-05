//
//  GPACell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/31/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class GPACell: UICollectionViewCell {

    let semLabel: UILabel = {
        let s = UILabel()
        s.font = .titleFont
        s.textColor = .textPrimary
        return s
    }()

    let gpaLabel: UILabel = {
        let g = UILabel()
        g.textColor = .textDanger
        g.font = .scoreFontBolder
        return g
    }()

    var currentGPA: [String: String]? {
        didSet {
            guard let gpa = currentGPA else { return }
            let key = Array(gpa.keys)[0]  // Coz, baby steps
            semLabel.text = key
            gpaLabel.text = gpa[key]
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 17
        dropShadow()

        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(semLabel)
        addSubview(gpaLabel)
        
        semLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        gpaLabel.anchorWithConstraints(right: rightAnchor, bottom: bottomAnchor, rightOffset: 12, bottomOffset: 12)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
