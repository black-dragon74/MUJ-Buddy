//
//  DashCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class DashCell: UICollectionViewCell {

    var items: MenuItems? {
        didSet {
            guard let item = items else { return }
            tLabel.text = item.title
            sLabel.text = item.subtitle
            cellIcon.image = UIImage(named: item.image)
        }
    }

    // Parent controller
    let cellUIView: UIView = {
        let c = UIView()
//      c.clipsToBounds = true //TODO:- Fix overlap in a better way on iPhone 5s
        return c
    }()

    // Image that will contain the logo
    let cellIcon: UIImageView = {
        let c = UIImageView()
        c.clipsToBounds = true
        c.layer.masksToBounds = true
        c.contentMode = .scaleAspectFill
        return c
    }()

    // Title Label
    let tLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return l
    }()

    // Subtitle label
    let sLabel: UILabel = {
        let s = UILabel()
        s.textColor = .darkGray
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(cellUIView)
        cellUIView.addSubview(cellIcon)
        cellUIView.addSubview(tLabel)
        cellUIView.addSubview(sLabel)

        // Root container
        cellUIView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 8, rightOffset: 8, bottomOffset: 8, leftOffset: 8, height: nil, width: nil)

        // The icon
        cellIcon.translatesAutoresizingMaskIntoConstraints = false
        cellIcon.heightAnchor.constraint(equalToConstant: 90).isActive = true
        cellIcon.widthAnchor.constraint(equalToConstant: 90).isActive = true
        cellIcon.centerXAnchor.constraint(equalTo: cellUIView.centerXAnchor).isActive = true
        cellIcon.centerYAnchor.constraint(equalTo: cellUIView.centerYAnchor).isActive = true

        // For the title label
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        tLabel.topAnchor.constraint(equalTo: cellIcon.bottomAnchor, constant: 4).isActive = true
        tLabel.centerXAnchor.constraint(equalTo: cellUIView.centerXAnchor).isActive = true

        // For the subtitle label
        sLabel.translatesAutoresizingMaskIntoConstraints = false
        sLabel.topAnchor.constraint(equalTo: tLabel.bottomAnchor).isActive = true
        sLabel.centerXAnchor.constraint(equalTo: cellUIView.centerXAnchor).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
