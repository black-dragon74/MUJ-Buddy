//
//  DashboardHeaderView.swift
//  MUJ Buddy
//
//  Created by Nick on 2/11/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class DashboardHeaderView: UICollectionReusableView {
    
    // This will be set while dequeuing header for the collection view
    var dashDetails: DashboardModel? {
        didSet {
            guard let dash = dashDetails else { return }
            nameTF.text = dash.admDetails.name
            acadTF.text = dash.admDetails.acadYear
            programTF.text = dash.admDetails.program.replacingOccurrences(of: "Bachelor of", with: "B.").replacingOccurrences(of: "Applications", with: "App.")
        }
    }
    
    // Name
    let nameLabel: UILabel = {
        let n = UILabel()
        n.text = "Name: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let nameTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        return  n
    }()
    
    // Program
    let programLabel: UILabel = {
        let n = UILabel()
        n.text = "Program: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let programTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        n.lineBreakMode = .byTruncatingTail
        return  n
    }()
    
    // Acad Year
    let acadLabel: UILabel = {
        let n = UILabel()
        n.text = "Acad Year: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let acadTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        return  n
    }()
    
    let containerView: UIView = {
        let cView = UIView()
        cView.backgroundColor = DMSColors.kindOfPurple.value
        return cView
    }()
    
    let rightChevron: UIImageView = {
       let rCv = UIImageView()
        rCv.image = UIImage(named: "ios_chevron_right")?.withRenderingMode(.alwaysTemplate)
        rCv.tintColor = .white
        rCv.translatesAutoresizingMaskIntoConstraints = false
        rCv.heightAnchor.constraint(equalToConstant: 20).isActive = true
        rCv.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return rCv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setupHeader()
    }
    
    fileprivate func setupHeader() {
        addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(nameTF)
        containerView.addSubview(programLabel)
        containerView.addSubview(programTF)
        containerView.addSubview(acadLabel)
        containerView.addSubview(acadTF)
        containerView.addSubview(rightChevron)
        
        containerView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, topOffset: 0, rightOffset: 8, bottomOffset: 0, leftOffset: 8, height: nil, width: nil)
        
        nameLabel.anchorWithConstraints(top: containerView.topAnchor, left: containerView.leftAnchor, topOffset: 12, leftOffset: 10)
        nameTF.anchorWithConstraints(top: containerView.topAnchor, left: nameLabel.rightAnchor, topOffset: 12, leftOffset: 4)
        
        programLabel.anchorWithConstraints(top: nameLabel.bottomAnchor, left: containerView.leftAnchor, topOffset: 4, leftOffset: 10)
        programTF.anchorWithConstraints(top: nameLabel.bottomAnchor, left: programLabel.rightAnchor, topOffset: 4, leftOffset: 4)
        
        acadLabel.anchorWithConstraints(top: programLabel.bottomAnchor, left: containerView.leftAnchor, topOffset: 4, leftOffset: 10)
        acadTF.anchorWithConstraints(top: programLabel.bottomAnchor, left: acadLabel.rightAnchor, topOffset: 4, leftOffset: 4)
        
        rightChevron.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        rightChevron.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
