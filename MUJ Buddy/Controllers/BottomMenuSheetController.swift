//
//  BottomMenuSheetController.swift
//  MUJ Buddy
//
//  Created by Nick on 2/5/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class BottomMenuSheetController: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var delegate: BottomSheetDelegate?

    // Black view that overlays on the whole window
    let blackView: UIView = {
        let b = UIView()
        b.backgroundColor = .black
        b.alpha = 0
        return b
    }()

    // Collection view that will contain the settings objects
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.dataSource = self
        c.isScrollEnabled = false
        c.delegate = self
        return c
    }()

    // Cell reuse identifier
    let cellID = "cellID"
    let cellHeight: CGFloat = 50

    // Array to contain menu items
    let menuItems: [BottomMenuSheetModel] = {
        let item1 = BottomMenuSheetModel(image: "ios_settings", title: "Settings")
        let item2 = BottomMenuSheetModel(image: "ios_logout", title: "Logout")
        return [item1, item2]
    }()

    override init() {
        super.init()

        collectionView.register(BottomMenuSheetCell.self, forCellWithReuseIdentifier: cellID)
        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSettingsHide)))
    }

    // Function to show settings
    func showSettings() {
        collectionView.backgroundColor = UIColor(named: "primaryLighter")
        collectionView.reloadData()
        if let window = UIApplication.shared.keyWindow {
            let height: CGFloat = cellHeight * CGFloat(menuItems.count) + 40
            let y = window.frame.height - height

            window.addSubview(blackView)
            window.addSubview(collectionView)

            blackView.frame = window.frame
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)

            // Animate
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
                self?.blackView.alpha = 0.5
                self?.collectionView.frame = CGRect(x: 0, y: y, width: window.frame.width, height: height)
            }, completion: nil)
        }
    }

    @objc fileprivate func handleSettingsHide() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let height: CGFloat = cellHeight * CGFloat(menuItems.count) + 40
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.blackView.alpha = 0
            self?.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            }, completion: nil)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        menuItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! BottomMenuSheetCell
        cell.currentCell = menuItems[indexPath.item]
        cell.backgroundColor = UIColor(named: "primaryLighter")
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Hide the menu first
        guard let window = UIApplication.shared.keyWindow else { return }
        let height: CGFloat = cellHeight * CGFloat(menuItems.count) + 40
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.blackView.alpha = 0
            self?.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
        }, completion: { [weak self] _ in
            let cell = collectionView.cellForItem(at: indexPath) as! BottomMenuSheetCell
            let str = cell.title.text ?? "nil"

            // We'll call the delegate and ask it to perform the required actions
            if let delegate = self?.delegate {
                delegate.handleMenuSelect(forItem: str)
            }
        })
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        4
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }
}
