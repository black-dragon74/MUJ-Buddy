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
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()

    let gpaLabel: UILabel = {
        let g = UILabel()
        g.textColor = .red
        g.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return g
    }()

    let separator: UIView = {
        let s = UIView()
        s.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        s.translatesAutoresizingMaskIntoConstraints = false
        s.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return s
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

        dropShadow()
        backgroundColor = .white

        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(semLabel)
        addSubview(separator)
        addSubview(gpaLabel)

        semLabel.anchorWithConstraints(top: topAnchor, left: leftAnchor, topOffset: 16, leftOffset: 16)
        separator.anchorWithConstraints(top: semLabel.bottomAnchor, right: rightAnchor, left: leftAnchor, topOffset: 5)
        gpaLabel.anchorWithConstraints(top: separator.bottomAnchor, left: leftAnchor, topOffset: 8, leftOffset: 16)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
