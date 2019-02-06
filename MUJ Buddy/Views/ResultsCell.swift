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
            sessionTF.text = curr.academicSession
            creditsTF.text = curr.credits
            setValueAndColorTo(grade: curr.grade)
        }
    }

    // Subject label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.text = "NA"
        s.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        s.adjustsFontSizeToFitWidth = true
        return s
    }()

    // Grade View
    let gradeView: UIView = {
        let g = UIView()
        g.backgroundColor = .clear
        g.translatesAutoresizingMaskIntoConstraints = false
        g.heightAnchor.constraint(equalToConstant: 100).isActive = true
        g.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return g
    }()

    // Grade Label
    let gradeLabel: UILabel = {
        let g = UILabel()
        g.font = UIFont.systemFont(ofSize: 50, weight: .heavy)
        g.textAlignment = .center
        g.textColor = .green
        g.text = "NA"
        return g
    }()

    // Course Code
    let courseCodeLabel: UILabel = {
        let a = UILabel()
        a.text = "Course Code:"
        a.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return a
    }()

    let courseCodeTF: UILabel = {
        let a = UILabel()
        a.text = "NA"
        return a
    }()

    // Academic Session
    let sessionLabel: UILabel = {
       let a = UILabel()
        a.text = "Session:"
        a.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return a
    }()

    let sessionTF: UILabel = {
        let a = UILabel()
        a.text = "NA"
        return a
    }()

    //Credits
    let creditsLabel: UILabel = {
        let a = UILabel()
        a.text = "Credits:"
        a.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return a
    }()

    let creditsTF: UILabel = {
        let a = UILabel()
        a.text = "NA"
        return a
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        dropShadow()

        setupViews()
    }

    fileprivate func setupViews() {
        addSubview(subjectLabel)

        addSubview(courseCodeLabel)
        addSubview(courseCodeTF)

        addSubview(sessionLabel)
        addSubview(sessionTF)

        addSubview(creditsLabel)
        addSubview(creditsTF)

        addSubview(gradeView)
        gradeView.addSubview(gradeLabel)

        subjectLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)

        courseCodeLabel.anchorWithConstraints(top: subjectLabel.bottomAnchor, left: leftAnchor, topOffset: 14, leftOffset: 10)
        courseCodeTF.anchorWithConstraints(top: subjectLabel.bottomAnchor, left: courseCodeLabel.rightAnchor, topOffset: 14, leftOffset: 5)

        sessionLabel.anchorWithConstraints(top: courseCodeLabel.bottomAnchor, left: leftAnchor, topOffset: 10, leftOffset: 10)
        sessionTF.anchorWithConstraints(top: courseCodeLabel.bottomAnchor, left: sessionLabel.rightAnchor, topOffset: 10, leftOffset: 5)

        creditsLabel.anchorWithConstraints(top: sessionLabel.bottomAnchor, left: leftAnchor, topOffset: 10, leftOffset: 10)
        creditsTF.anchorWithConstraints(top: sessionLabel.bottomAnchor, left: creditsLabel.rightAnchor, topOffset: 10, leftOffset: 5)

        gradeView.anchorWithConstraints(top: subjectLabel.bottomAnchor, right: rightAnchor, topOffset: 5, rightOffset: 5)
        gradeLabel.anchorWithConstraints(top: gradeView.topAnchor, right: gradeView.rightAnchor, bottom: gradeView.bottomAnchor, left: gradeView.leftAnchor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setValueAndColorTo(grade: String) {
        switch grade {
        case "":
            gradeLabel.textColor = .black
            gradeLabel.text = "NA"
        case "A+":
            gradeLabel.textColor = .green
            gradeLabel.text = grade
        case "A":
            gradeLabel.textColor = .green
            gradeLabel.text = grade
        case "B+":
            gradeLabel.textColor = .green
            gradeLabel.text = grade
        case "B":
            gradeLabel.textColor = .green
            gradeLabel.text = grade
        case "C+":
            gradeLabel.textColor = .yellow
            gradeLabel.text = grade
        case "C":
            gradeLabel.textColor = .yellow
            gradeLabel.text = grade
        case "D+":
            gradeLabel.textColor = .yellow
            gradeLabel.text = grade
        case "D":
            gradeLabel.textColor = .yellow
            gradeLabel.text = grade
        case "E+":
            gradeLabel.textColor = .red
            gradeLabel.text = grade
        case "E":
            gradeLabel.textColor = .red
            gradeLabel.text = grade
        case "F+":
            gradeLabel.textColor = .red
            gradeLabel.text = grade
        case "F":
            gradeLabel.textColor = .red
            gradeLabel.text = grade
        default:
            gradeLabel.text = grade
        }
    }
}
