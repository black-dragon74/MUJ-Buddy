//
//  ResultsCell.swift
//  MUJ Buddy
//
//  Created by Nick on 2/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ResultsCell: UICollectionViewCell {

    var currentSubjectForResult: ResultsModel? {
        didSet {
            guard let curr = currentSubjectForResult else { return }
            subjectLabel.text = curr.courseName
            courseCodeTF.text = curr.courseCode
            creditsTF.text = curr.credits
            setValueAndColorTo(grade: curr.grade)
        }
    }

    // Subject label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.text = "Not Available"
        s.font = .titleFont
        s.textColor = UIColor(named: "textPrimary")
        s.adjustsFontSizeToFitWidth = true
        return s
    }()

    // Grade Label
    let gradeLabel: UILabel = {
        let g = UILabel()
        g.font = .subtitleFont
        g.textColor = UIColor(named: "textPrimaryLighter")
        g.text = "Grade"
        return g
    }()
    
    let gradeTF: UILabel = {
        let a = UILabel()
        a.text = "00"
        a.textAlignment = .center
        a.font = .scoreFontBolder
        return a
    }()

    // Course Code
    let courseCodeTF: UILabel = {
        let a = UILabel()
        a.text = "Unknown"
        a.textColor = UIColor(named: "textPrimaryLighter")
        a.font = .subtitleFont
        return a
    }()

    //Credits
    let creditsLabel: UILabel = {
        let a = UILabel()
        a.text = "Credits"
        a.font = .subtitleFont
        a.textColor = UIColor(named: "textPrimaryLighter")
        return a
    }()

    let creditsTF: UILabel = {
        let a = UILabel()
        a.text = "00"
        a.textAlignment = .center
        a.textColor = UIColor(named: "textPrimaryDarker")
        a.font = .scoreFontBolder
        return a
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(named: "cardBackgroundColor")
        layer.cornerRadius = 17
        dropShadow()

        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(subjectLabel)
        addSubview(courseCodeTF)
        
        addSubview(gradeLabel)
        addSubview(gradeTF)
        
        addSubview(creditsLabel)
        addSubview(creditsTF)
        
        subjectLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        courseCodeTF.anchorWithConstraints(top: subjectLabel.bottomAnchor, left: leftAnchor, topOffset: 2, leftOffset: 12)
        
        gradeLabel.anchorWithConstraints(right: rightAnchor, bottom: bottomAnchor, rightOffset: 12, bottomOffset: 12)
        gradeTF.anchorWithConstraints(right: gradeLabel.rightAnchor, bottom: gradeLabel.topAnchor, left: gradeLabel.leftAnchor)
        
        creditsLabel.anchorWithConstraints(right: gradeLabel.leftAnchor, bottom: bottomAnchor, rightOffset: 20, bottomOffset: 12)
        creditsTF.anchorWithConstraints(right: creditsLabel.rightAnchor, bottom: creditsLabel.topAnchor, left: creditsLabel.leftAnchor)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setValueAndColorTo(grade: String) {
        switch grade {
        case "":
            gradeTF.textColor = UIColor(named: "textPrimaryDarker")
            gradeTF.text = "NA"
        case "A+":
            gradeTF.textColor = .textSuccess
            gradeTF.text = grade
        case "A":
            gradeTF.textColor = .textSuccess
            gradeTF.text = grade
        case "B+":
            gradeTF.textColor = .textSuccess
            gradeTF.text = grade
        case "B":
            gradeTF.textColor = .textSuccess
            gradeTF.text = grade
        case "C+":
            gradeTF.textColor = .textWarning
            gradeTF.text = grade
        case "C":
            gradeTF.textColor = .textWarning
            gradeTF.text = grade
        case "D+":
            gradeTF.textColor = .textWarning
            gradeTF.text = grade
        case "D":
            gradeTF.textColor = .textWarning
            gradeTF.text = grade
        case "E+":
            gradeTF.textColor = .textDanger
            gradeTF.text = grade
        case "E":
            gradeTF.textColor = .textDanger
            gradeTF.text = grade
        case "F+":
            gradeTF.textColor = .textDanger
            gradeTF.text = grade
        case "F":
            gradeTF.textColor = .textDanger
            gradeTF.text = grade
        default:
            gradeTF.text = grade
        }
    }
}
