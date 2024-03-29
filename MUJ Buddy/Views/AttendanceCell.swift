//
//  AttendanceCell.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class AttendanceCell: UICollectionViewCell {
    var attendance: AttendanceModel? {
        didSet {
            guard let att = attendance else { return }
            subjectLabel.text = att.course.isEmpty ? "Not Available" : att.course
            presentTF.text = att.present.isEmpty ? "00" : att.present
            absentTF.text = att.absent.isEmpty ? "00" : att.absent
            totalTF.text = att.total.isEmpty ? "Total: 00" : "Total: " + att.total
            percentTF.text = att.percentage.isEmpty ? "00" : att.percentage
        }
    }

    // Subject label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.text = "Subject Name"
        s.font = .titleFont
        s.textColor = UIColor(named: "textPrimary")
        s.adjustsFontSizeToFitWidth = true
        return s
    }()

    // Present label
    let presentLabel: UILabel = {
        let s = UILabel()
        s.text = "Present"
        s.font = .subtitleFont
        s.textColor = UIColor(named: "textPrimaryLighter")
        s.textAlignment = .center
        return s
    }()

    // Present tf
    let presentTF: UILabel = {
        let s = UILabel()
        s.text = "00"
        s.textAlignment = .center
        s.font = .scoreFont
        s.textColor = .textDanger
        return s
    }()

    // Absent label
    let absentLabel: UILabel = {
        let s = UILabel()
        s.text = "Absent"
        s.font = .subtitleFont
        s.textColor = UIColor(named: "textPrimaryLighter")
        s.textAlignment = .center
        return s
    }()

    // Absent tf
    let absentTF: UILabel = {
        let s = UILabel()
        s.text = "00"
        s.font = .scoreFont
        s.textColor = UIColor(named: "textPrimaryDarker")
        s.textAlignment = .center
        return s
    }()

    // Total tf
    let totalTF: UILabel = {
        let s = UILabel()
        s.font = .subtitleFont
        s.textColor = UIColor(named: "textPrimaryLighter")
        s.text = "00"
        return s
    }()

    // Percent Label
    let percentLabel: UILabel = {
        let p = UILabel()
        p.font = .subtitleFont
        p.textColor = UIColor(named: "textPrimaryLighter")
        p.text = "Percent"
        p.textAlignment = .center
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()

    let percentTF: UILabel = {
        let s = UILabel()
        s.text = "00"
        s.font = .scoreFont
        s.textColor = .textSuccess
        s.textAlignment = .center
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "cardBackgroundColor")
        layer.cornerRadius = 17

        dropShadow()

        setupViews()
    }

    func setupViews() {
        // Add the views
        addSubview(subjectLabel)
        addSubview(totalTF)

        addSubview(presentLabel)
        addSubview(absentLabel)
        addSubview(percentLabel)

        addSubview(presentTF)
        addSubview(absentTF)
        addSubview(percentTF)

        subjectLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        totalTF.anchorWithConstraints(top: subjectLabel.bottomAnchor, left: leftAnchor, topOffset: 2, leftOffset: 12)

        percentLabel.anchorWithConstraints(right: rightAnchor, bottom: bottomAnchor, rightOffset: 12, bottomOffset: 12)
        absentLabel.anchorWithConstraints(right: percentLabel.leftAnchor, bottom: bottomAnchor, rightOffset: 20, bottomOffset: 12)
        presentLabel.anchorWithConstraints(right: absentLabel.leftAnchor, bottom: bottomAnchor, rightOffset: 20, bottomOffset: 12)

        presentTF.anchorWithConstraints(right: presentLabel.rightAnchor, bottom: presentLabel.topAnchor, left: presentLabel.leftAnchor)
        absentTF.anchorWithConstraints(right: absentLabel.rightAnchor, bottom: absentLabel.topAnchor, left: absentLabel.leftAnchor)
        percentTF.anchorWithConstraints(right: percentLabel.rightAnchor, bottom: percentLabel.topAnchor, left: percentLabel.leftAnchor)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
