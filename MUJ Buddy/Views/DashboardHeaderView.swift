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
            nameTF.text = dash.admDetails.name.capitalized(with: nil)
        }
    }

    let poppins = UIFont(name: "Poppins", size: 30)
    let poppinsBold = UIFont(name: "Futura", size: 30)?.bold()

    // Name
    lazy var nameLabel: UILabel = {
        let n = UILabel()
        n.text = "Welcome,"
        n.textColor = .white
        n.font = self.poppins
        n.adjustsFontSizeToFitWidth = true
        n.textAlignment = .center
        n.translatesAutoresizingMaskIntoConstraints = false
        return n
    }()

    lazy var nameTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        n.font = self.poppinsBold
        n.adjustsFontSizeToFitWidth = true
        n.textAlignment = .center
        n.translatesAutoresizingMaskIntoConstraints = false
        return n
    }()

    let mujImgview: UIImageView = {
        let cView = UIImageView()
        cView.backgroundColor = .navyBlue
        cView.image = UIImage(named: "manipal")
        cView.layer.cornerRadius = 17
        cView.clipsToBounds = true
        cView.layer.masksToBounds = true
        cView.contentMode = .scaleAspectFit
        return cView
    }()

    let blackView: UIView = {
        let bView = UIView()
        bView.backgroundColor = .black
        bView.alpha = 0.7
        bView.layer.cornerRadius = 17
        bView.layer.masksToBounds = true
        bView.clipsToBounds = true
        return bView
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

        layer.cornerRadius = 17
        clipsToBounds = true
        layer.masksToBounds = true

        setupHeader()
    }

    fileprivate func setupHeader() {
        addSubview(mujImgview)
        addSubview(blackView)
        addSubview(nameLabel)
        addSubview(nameTF)
//        addSubview(rightChevron)

        mujImgview.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, rightOffset: 8, leftOffset: 8)

        blackView.anchorWithConstraints(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor, rightOffset: 8, leftOffset: 8)

        nameLabel.anchorWithConstraints(right: rightAnchor, left: leftAnchor, rightOffset: 12, leftOffset: 12)
        nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20).isActive = true

        nameTF.anchorWithConstraints(right: rightAnchor, left: leftAnchor, rightOffset: 12, leftOffset: 12)
        nameTF.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20).isActive = true

//        rightChevron.centerYAnchor.constraint(equalTo: mujImgview.centerYAnchor).isActive = true
//        rightChevron.rightAnchor.constraint(equalTo: mujImgview.rightAnchor, constant: -5).isActive = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
