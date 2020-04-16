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
            cellIcon.image = UIImage(named: item.image)
        }
    }

    // Parent controller
    let cellUIView: UIView = {
        let c = UIView()
        return c
    }()

    // Image that will contain the logo
    let cellIcon: UIImageView = {
        let c = UIImageView()
        c.clipsToBounds = true
        c.translatesAutoresizingMaskIntoConstraints = false
        c.heightAnchor.constraint(equalToConstant: 90).isActive = true
        c.widthAnchor.constraint(equalToConstant: 90).isActive = true
        c.contentMode = .scaleAspectFit
        return c
    }()

    // Title Label
    let tLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Poppins", size: 17)?.bold()
        l.textColor = .white
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 10
        dropShadow()

        addSubview(cellUIView)
        cellUIView.addSubview(cellIcon)
        cellUIView.addSubview(tLabel)

        // Root container
        cellUIView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 8, rightOffset: 8, bottomOffset: 8, leftOffset: 8)

        // The icon
        cellIcon.centerXAnchor.constraint(equalTo: cellUIView.centerXAnchor).isActive = true
        cellIcon.centerYAnchor.constraint(equalTo: cellUIView.centerYAnchor, constant: -5).isActive = true

        // For the title label
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        tLabel.topAnchor.constraint(equalTo: cellIcon.bottomAnchor, constant: 6).isActive = true
        tLabel.centerXAnchor.constraint(equalTo: cellUIView.centerXAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
