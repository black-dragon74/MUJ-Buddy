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
            if !UIApplication.shared.isInDarkMode {
                backgroundColor = isHighlighted ? .lightGray : .white
                cellImage.tintColor = isHighlighted ? .white : .black
                title.textColor = isHighlighted ? .white : .black
            }
            else {
                backgroundColor = isHighlighted ? .darkCardBackgroundColor : .darkBackgroundColor
            }
        }
    }

    var currentCell: BottomMenuSheetModel? {
        didSet {
            guard let c = currentCell else { return }
            cellImage.image = UIImage(named: c.image)?.withRenderingMode(.alwaysTemplate)
            title.text = c.title
        }
    }
    
    var isDark: Bool? {
        didSet {
            guard let isDark = isDark else { return }
            
            if isDark {
                cellImage.tintColor = .white
                title.textColor = .white
            }
        }
    }

    let cellImage: UIImageView = {
        let c = UIImageView()
        c.contentMode = .scaleAspectFill
        c.tintColor = .black
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
