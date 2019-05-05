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
        didSet {
            guard let internals = internalData else { return }
            subjectLabel.text = internals.subject_codes == "" ? "00.00" : internals.subject_codes
            mte1Text.text = internals.mte_1 == "" ? "00.00" : internals.mte_1  ?? "00.00"
            mte2Text.text = internals.mte_2 == "" ? "00.00" : internals.mte_2  ?? "00.00"
            cwsText.text = internals.cws == "" ? "00.00" : internals.cws  ?? "00.00"
            prsText.text = internals.prs == "" ? "00.00" : internals.prs  ?? "00.00"
            totalText.text = internals.total == "" ? "00.00" : "\(internals.total ?? "00.00")"
            resessText.text = internals.resession == "" ? "00.00" : "\(internals.resession ?? "00.00")"
        }
    }
    
    // Colors for gradient
    private let separatorColor = [UIColor(r: 234, g: 12, b: 12), UIColor(r: 73, g: 46, b: 202)]

    // Subject Label
    let subjectLabel: UILabel = {
        let s = UILabel()
        s.font = .titleFont
        s.adjustsFontSizeToFitWidth = true
        s.textColor = .textPrimary
        s.text = "I am a subject"
        return s
    }()

    // MTE 1 Label
    let mte1Label: UILabel = {
        let m = UILabel()
        m.text = "MTE - 1"
        m.font = .subtitleFont
        m.textColor = .textPrimaryLighter
        m.textAlignment = .center
        return m
    }()

    // MTE1 Text
    let mte1Text: UILabel = {
        let m = UILabel()
        m.text = "10.00"
        m.font = .scoreFontBolder
        m.textColor = .textPrimaryDarker
        return m
    }()

    // MTE 2 Label
    let mte2Label: UILabel = {
        let m = UILabel()
        m.text = "MTE - 2"
        m.font = .subtitleFont
        m.textColor = .textPrimaryLighter
        m.textAlignment = .center
        return m
    }()

    // MTE2 Text
    let mte2Text: UILabel = {
        let m = UILabel()
        m.text = "10.00"
        m.translatesAutoresizingMaskIntoConstraints = false
        m.font = .scoreFontBolder
        m.textColor = .textPrimaryDarker
        return m
    }()

    // CWS label
    let cwsLabel: UILabel = {
        let m = UILabel()
        m.text = "CWS"
        m.font = .subtitleFont
        m.textColor = .textPrimaryLighter
        m.textAlignment = .center
        return m
    }()

    // CWS Text
    let cwsText: UILabel = {
        let c = UILabel()
        c.text = "10.00"
        c.font = .scoreFontBolder
        c.textColor = .textPrimaryDarker
        return c
    }()

    // PRS Label
    let prsLabel: UILabel = {
        let m = UILabel()
        m.text = "PRS"
        m.font = .subtitleFont
        m.textColor = .textPrimaryLighter
        m.textAlignment = .center
        return m
    }()

    // PRS Text
    let prsText: UILabel = {
        let c = UILabel()
        c.text = "10.00"
        c.font = .scoreFontBolder
        c.textColor = .textInfo
        return c
    }()
    
    // ReSessional text
    let resessText: UILabel = {
        let rsLabel = UILabel()
        rsLabel.font = .scoreFontBolder
        rsLabel.text = "00.00"
        rsLabel.textColor = .textDanger
        rsLabel.translatesAutoresizingMaskIntoConstraints = false
        return rsLabel
    }()
    
    let resessLabel: UILabel = {
        let m = UILabel()
        m.text = "Re Exam"
        m.font = .subtitleFont
        m.textAlignment = .center
        m.textColor = .textPrimaryLighter
        return m
    }()

    // Total text
    let totalText: UILabel = {
        let t = UILabel()
        t.font = .scoreFontBolder
        t.text = "99.00"
        t.textColor = .textSuccess
        return t
    }()
    
    let totalLabel: UILabel = {
        let m = UILabel()
        m.text = "Total"
        m.font = .subtitleFont
        m.textAlignment = .center
        m.textColor = .textPrimaryLighter
        return m
    }()
    
    lazy var separatorView: UIView = {
        let sView = UIView()
        sView.translatesAutoresizingMaskIntoConstraints = false
        return sView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 17
        dropShadow()

        // Handle additional views
        setupViews()
    }

    // MARK: - Handle additional views setup
    fileprivate func setupViews() {
        addSubview(separatorView)
        addSubview(subjectLabel)
        
        // First row add to view
        addSubview(mte1Text)
        addSubview(mte2Text)
        addSubview(cwsText)
        addSubview(mte1Label)
        addSubview(mte2Label)
        addSubview(cwsLabel)
        
        // Second row add to view
        addSubview(prsText)
        addSubview(resessText)
        addSubview(totalText)
        addSubview(prsLabel)
        addSubview(resessLabel)
        addSubview(totalLabel)
        
        subjectLabel.anchorWithConstraints(top: topAnchor, right: rightAnchor, left: leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        
        // First row constraints
        mte1Text.anchorWithConstraints(top: subjectLabel.bottomAnchor, left: leftAnchor, topOffset: 10, leftOffset: 12)
        mte1Label.anchorWithConstraints(top: mte1Text.bottomAnchor, right: mte1Text.rightAnchor, left: mte1Text.leftAnchor)
        
        mte2Text.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mte2Text.centerYAnchor.constraint(equalTo: mte1Text.centerYAnchor).isActive = true
        mte2Label.anchorWithConstraints(top: mte2Text.bottomAnchor, right: mte2Text.rightAnchor, left: mte2Text.leftAnchor)
        
        cwsText.anchorWithConstraints(top: subjectLabel.bottomAnchor, right: rightAnchor, topOffset: 10, rightOffset: 12)
        cwsLabel.anchorWithConstraints(top: cwsText.bottomAnchor, right: cwsText.rightAnchor, left: cwsText.leftAnchor)
        
        // Separator is 4px from both rows
        separatorView.anchorWithConstraints(top: mte1Label.bottomAnchor, right: rightAnchor, left: leftAnchor, topOffset: 4, rightOffset: 12, leftOffset: 12, height: 1)
        
        // Second row constraints
        prsText.anchorWithConstraints(top: separatorView.bottomAnchor, left: leftAnchor, topOffset: 4, leftOffset: 12)
        prsLabel.anchorWithConstraints(top: prsText.bottomAnchor, right: prsText.rightAnchor, left: prsText.leftAnchor)
        
        resessText.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        resessText.centerYAnchor.constraint(equalTo: prsText.centerYAnchor).isActive = true
        resessLabel.anchorWithConstraints(top: resessText.bottomAnchor, right: resessText.rightAnchor, left: resessText.leftAnchor)
        
        totalText.anchorWithConstraints(top: separatorView.bottomAnchor, right: rightAnchor, topOffset: 4, rightOffset: 12)
        totalLabel.anchorWithConstraints(top: totalText.bottomAnchor, right: totalText.rightAnchor, left: totalText.leftAnchor)
        
        
        // Force layout and add gradient
        layoutIfNeeded()
        
        // Easter egg, gradient changes it's colors
        let gradient = CAGradientLayer()
        gradient.colors = [separatorColor[0].cgColor, separatorColor[1].cgColor]
        gradient.startPoint = .init(x: 0, y: 0)
        gradient.endPoint = .init(x: 1, y: 1)
        gradient.locations = [0.0, 1.0]
        gradient.frame = separatorView.bounds
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 1.0]
        animation.toValue = [1.0, 0.0]
        animation.duration = 3
        animation.repeatCount = .infinity
        animation.autoreverses = true
        gradient.add(animation, forKey: nil)
        separatorView.layer.insertSublayer(gradient, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
