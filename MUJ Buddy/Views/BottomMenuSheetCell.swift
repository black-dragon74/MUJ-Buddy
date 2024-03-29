//
//  BottomMenuSheetCell.swift
//  MUJ Buddy
//
//  Created by Nick on 2/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class BottomMenuSheetCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(named: "textPrimaryLighter") : nil
        }
    }

    var currentCell: BottomMenuSheetModel? {
        didSet {
            guard let c = currentCell else { return }
            cellImage.image = UIImage(named: c.image)?.withRenderingMode(.alwaysTemplate)
            title.text = c.title
        }
    }

    let cellImage: UIImageView = {
        let c = UIImageView()
        c.contentMode = .scaleAspectFill
        c.tintColor = UIColor(named: "textPrimary")
        c.translatesAutoresizingMaskIntoConstraints = false
        return c
    }()

    let title: UILabel = {
        let t = UILabel()
        t.font = .titleFont
        return t
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(cellImage)
        addSubview(title)

        cellImage.anchorWithConstraints(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 5, bottomOffset: 5, leftOffset: 16, width: 40)
        title.anchorWithConstraints(left: cellImage.rightAnchor, leftOffset: 8)
        title.centerYAnchor.constraint(equalTo: cellImage.centerYAnchor).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
