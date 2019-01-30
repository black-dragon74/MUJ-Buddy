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
            subjectLabel.text = att.course.isEmpty ? "NA" : att.course
            presentTF.text = att.present.isEmpty ? "0" : att.present
            absentTF.text = att.absent.isEmpty ? "0" : att.absent
            totalTF.text = att.total.isEmpty ? "0" : att.total
            sectionTF.text = att.section.isEmpty ? "NA" : att.section
            batchTF.text = att.batch.isEmpty ? "NA" : att.batch
            percentLabel.text = att.percentage.isEmpty ? "0%" : att.percentage + "%"
            animatePercentage(percentage: att.percentage)
        }
    }
    
    // Parent view
    let attendanceView: UIView = {
        let a = UIView()
        a.backgroundColor = .white
        return a
    }()
    
    // Subject label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.text = "Subject Name"
        s.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        s.adjustsFontSizeToFitWidth = true
        return s
    }()
    
    // Separator
    let separator: UIView = {
        let s = UIView()
        s.backgroundColor = .darkGray
        s.translatesAutoresizingMaskIntoConstraints = false
        s.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return s
    }()
    
    // Present label
    let presentLabel: UILabel = {
        let s = UILabel()
        s.text = "Present: "
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()
    
    // Present tf
    let presentTF: UILabel = {
        let s = UILabel()
        s.text = "0"
        return s
    }()
    
    // Absent label
    let absentLabel: UILabel = {
        let s = UILabel()
        s.text = "Absent: "
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()
    
    // Absent tf
    let absentTF: UILabel = {
        let s = UILabel()
        s.text = "0"
        return s
    }()
    
    // Total label
    let totalLabel: UILabel = {
        let s = UILabel()
        s.text = "Total: "
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()
    
    // Total tf
    let totalTF: UILabel = {
        let s = UILabel()
        s.text = "0"
        return s
    }()
    
    // Section label
    let sectionLabel: UILabel = {
        let s = UILabel()
        s.text = "Section: "
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()
    
    // Section tf
    let sectionTF: UILabel = {
        let s = UILabel()
        s.text = "NA"
        return s
    }()
    
    // Batch label
    let batchLabel: UILabel = {
        let s = UILabel()
        s.text = "Batch: "
        s.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return s
    }()
    
    // Batch tf
    let batchTF: UILabel = {
        let s = UILabel()
        s.text = "NA"
        return s
    }()
    
    // Percent Label
    let percentLabel: UILabel = {
        let p = UILabel()
        p.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        p.text = "100%"
        p.translatesAutoresizingMaskIntoConstraints = false
        return p
    }()
    
    
    let circle = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.dropShadow()
        
        setupViews()
    }
    
    func setupViews() {
        //MARK:- Percentage thingies
        // View to contain that damned circle
        let circleContainer: UIView = {
            let c = UIView()
            c.translatesAutoresizingMaskIntoConstraints = false
            c.widthAnchor.constraint(equalToConstant: 100).isActive = true
            c.heightAnchor.constraint(equalToConstant: 100).isActive = true
            return c
        }()
        
        // The damned circle
        let c = CGPoint(x: 50, y: 50)
        let path = UIBezierPath(arcCenter: c, radius: 50, startAngle: -0.5 * CGFloat.pi, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.red.cgColor
        circle.lineWidth = 10
        circle.strokeEnd = 0
        circle.lineCap = .round
        circle.path = path.cgPath
        
        // Path outline
        let outline = CAShapeLayer()
        outline.fillColor = UIColor.clear.cgColor
        outline.strokeColor = UIColor.lightGray.cgColor
        outline.lineWidth = 10
        outline.path = path.cgPath
        
        
        // Add subviews
        addSubview(attendanceView)
        
        // Add child views
        attendanceView.addSubview(circleContainer)
        circleContainer.layer.addSublayer(outline)
        circleContainer.layer.addSublayer(circle)
        circleContainer.addSubview(percentLabel)
        attendanceView.addSubview(subjectLabel)
        attendanceView.addSubview(separator)
        attendanceView.addSubview(sectionLabel)
        attendanceView.addSubview(sectionTF)
        attendanceView.addSubview(batchLabel)
        attendanceView.addSubview(batchTF)
        attendanceView.addSubview(presentLabel)
        attendanceView.addSubview(presentTF)
        attendanceView.addSubview(absentLabel)
        attendanceView.addSubview(absentTF)
        attendanceView.addSubview(totalLabel)
        attendanceView.addSubview(totalTF)
        
        // Add constraints
        circleContainer.anchorWithConstraints(top: separator.bottomAnchor, right: attendanceView.rightAnchor, bottom: nil, left: nil, topOffset: 16, rightOffset: 16, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        percentLabel.centerXAnchor.constraint(equalTo: circleContainer.centerXAnchor).isActive = true
        percentLabel.centerYAnchor.constraint(equalTo: circleContainer.centerYAnchor).isActive = true
        
        attendanceView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 0, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        subjectLabel.anchorWithConstraints(top: topAnchor, right: nil, bottom: nil, left: leftAnchor, topOffset: 12, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        subjectLabel.widthAnchor.constraint(equalToConstant: (frame.width - 18)).isActive = true
        
        separator.anchorWithConstraints(top: subjectLabel.bottomAnchor, right: rightAnchor, bottom: nil, left: leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        sectionLabel.anchorWithConstraints(top: separator.bottomAnchor, left: leftAnchor, topOffset: 6, leftOffset: 16)
        sectionTF.anchorWithConstraints(top: separator.bottomAnchor, left: sectionLabel.rightAnchor, topOffset: 6)
        
        batchLabel.anchorWithConstraints(top: sectionLabel.bottomAnchor, right: nil, bottom: nil, left: leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        batchTF.anchorWithConstraints(top: sectionLabel.bottomAnchor, right: nil, bottom: nil, left: batchLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        presentLabel.anchorWithConstraints(top: batchLabel.bottomAnchor, right: nil, bottom: nil, left: leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        presentTF.anchorWithConstraints(top: batchLabel.bottomAnchor, right: nil, bottom: nil, left: presentLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        absentLabel.anchorWithConstraints(top: presentLabel.bottomAnchor, right: nil, bottom: nil, left: leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        absentTF.anchorWithConstraints(top: presentLabel.bottomAnchor, right: nil, bottom: nil, left: absentLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        totalLabel.anchorWithConstraints(top: absentLabel.bottomAnchor, right: nil, bottom: nil, left: leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        totalTF.anchorWithConstraints(top: absentLabel.bottomAnchor, right: nil, bottom: nil, left: totalLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
    }
    
    fileprivate func animatePercentage(percentage: String) {
        let p = Float(percentage)
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.toValue = arcPercent(percent: p ?? 0)
        anim.duration = 1
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        circle.add(anim, forKey: "animS")
    }
    
    fileprivate func arcPercent(percent: Float) -> Float {
        return percent / 100
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
