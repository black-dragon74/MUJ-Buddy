//
//  InternalsCell.swift
//  MUJ Buddy
//
//  Created by Nick on 2/1/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class InternalsCell: UICollectionViewCell {
    
    // Var to handle this cell's operations
    var internalData: InternalsModel? {
        didSet{
            guard let internals = internalData else { return }
            subjectLabel.text = internals.subject == "" ? "NA" : internals.subject
            mte1Text.text = internals.mte_1 == "" ? "NA" : internals.mte_1
            mte2Text.text = internals.mte_2 == "" ? "NA" : internals.mte_2
            cwsText.text = internals.cws == "" ? "NA" : internals.cws
            prsText.text = internals.prs == "" ? "NA" : internals.prs
            totalLabel.text = internals.total == "" ? "NA" : "Total: \(internals.total)"
        }
    }
    
    // Subject Label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        s.adjustsFontSizeToFitWidth = true
        s.textColor = .white
        s.text = "I am a subject"
        return s
    }()
    
    //Left view
    let leftView: UIView = {
        let l = UIView()
        l.backgroundColor = .lightGray
        return l
    }()
    
    // MTE 1 Label
    let mte1Label: UILabel = {
        let m = UILabel()
        m.text = "MTE 1:"
        m.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return m
    }()
    
    // MTE1 Text
    let mte1Text: UILabel = {
        let m = UILabel()
        m.text = "10.0"
        return m
    }()
    
    // MTE 2 Label
    let mte2Label: UILabel = {
        let m = UILabel()
        m.text = "MTE 2:"
        m.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return m
    }()
    
    // MTE1 Text
    let mte2Text: UILabel = {
        let m = UILabel()
        m.text = "10.0"
        return m
    }()
    
    //Right view
    let rightView: UIView = {
        let l = UIView()
        l.backgroundColor = .lightGray
        return l
    }()
    
    // CWS label
    let cwsLabel: UILabel = {
        let m = UILabel()
        m.text = "CWS:"
        m.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return m
    }()
    
    // CWS Text
    let cwsText: UILabel = {
        let c = UILabel()
        c.text = "10.00"
        return c
    }()
    
    // PRS Label
    let prsLabel: UILabel = {
        let m = UILabel()
        m.text = "PRS:  "
        m.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return m
    }()
    
    // PRS Text
    let prsText: UILabel = {
        let c = UILabel()
        c.text = "10.00"
        return c
    }()
    
    // Total label
    let totalLabel: UILabel = {
        let t = UILabel()
        t.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        t.text = "Total: 500"
        t.textAlignment = .center
        t.textColor = .white
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .gray
        dropShadow()
        
        // Handle additional views
        setupViews()
    }
    
    //MARK:- Handle additional views setup
    fileprivate func setupViews() {
        // Add subviews
        addSubview(subjectLabel)
        addSubview(leftView)
        leftView.addSubview(mte1Label)
        leftView.addSubview(mte2Label)
        leftView.addSubview(mte1Text)
        leftView.addSubview(mte2Text)
        addSubview(rightView)
        rightView.addSubview(cwsLabel)
        rightView.addSubview(prsLabel)
        rightView.addSubview(cwsText)
        rightView.addSubview(prsText)
        addSubview(totalLabel)
        
        // Add constraints
        subjectLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)
        
        leftView.anchorWithConstraints(top: topAnchor, right: centerXAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 40, bottomOffset: 40)
        mte1Label.anchorWithConstraints(top: leftView.topAnchor, left: leftView.leftAnchor, topOffset: 10, leftOffset: 10)
        mte1Text.anchorWithConstraints(top: leftView.topAnchor, left: mte1Label.rightAnchor, topOffset: 10, leftOffset: 10)
        mte2Label.anchorWithConstraints(top: mte1Label.bottomAnchor, left: leftView.leftAnchor, topOffset: 10, leftOffset: 10)
        mte2Text.anchorWithConstraints(top: mte1Label.bottomAnchor, left: mte2Label.rightAnchor, topOffset: 10, leftOffset: 10)
        
        rightView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: centerXAnchor, topOffset: 40, bottomOffset: 40)
        cwsLabel.anchorWithConstraints(top: rightView.topAnchor, left: rightView.leftAnchor, topOffset: 10, leftOffset: 10)
        cwsText.anchorWithConstraints(top: rightView.topAnchor, left: cwsLabel.rightAnchor, topOffset: 10, leftOffset: 10)
        prsLabel.anchorWithConstraints(top: cwsLabel.bottomAnchor, left: rightView.leftAnchor, topOffset: 10, leftOffset: 10)
        prsText.anchorWithConstraints(top: cwsLabel.bottomAnchor, left: prsLabel.rightAnchor, topOffset: 10, leftOffset: 10)
        
        totalLabel.anchorWithConstraints(top: leftView.bottomAnchor, right: rightAnchor, left: leftAnchor, topOffset: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
