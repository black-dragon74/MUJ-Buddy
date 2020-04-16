//
//  EventsCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/30/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class EventsCell: UICollectionViewCell {
    // Handle the updation of the cell's values
    var currentEvent: EventsModel? {
        didSet {
            guard let event = currentEvent else { return }
            dateLabel.text = "  " + event.date + "  "
            eventNameLabel.text = event.name
        }
    }

    // Label to show the dates
    let dateLabel: UILabel = {
        let d = UILabel()
        d.backgroundColor = .textDanger
        d.text = "  30 Jul 2019  "
        d.textColor = .white
        d.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        d.heightAnchor.constraint(equalToConstant: 25).isActive = true
        d.layer.cornerRadius = 6
        d.layer.masksToBounds = true
        return d
    }()

    // Event name comes here
    let eventNameLabel: UILabel = {
        let e = UILabel()
        e.numberOfLines = 3
        e.font = .titleFont
        e.text = "Branch Change Application for 1st Year B.Tech Starts"
        return e
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "cardBackgroundColor")
        dropShadow()
        eventNameLabel.textColor = UIColor(named: "textPrimary")
        layer.cornerRadius = 17

        // Setup additional views
        setupViews()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupViews() {
        // Add subviews
        addSubview(dateLabel)
        addSubview(eventNameLabel)

        // Add constraints
        dateLabel.anchorWithConstraints(top: topAnchor, left: leftAnchor, topOffset: 16, leftOffset: 16)
        eventNameLabel.anchorWithConstraints(top: dateLabel.bottomAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 5, rightOffset: 8, bottomOffset: 16, leftOffset: 16)
    }
}
