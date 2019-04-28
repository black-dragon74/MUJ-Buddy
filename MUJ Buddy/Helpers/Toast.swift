//
//  Toast.swift
//  MUJ Buddy
//
//  Created by Nick on 3/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//
//  This is my own implementation of the Android's handy toast messages.
//  Will develop it into a framework sometime in the future
//

import UIKit

class Toast {
    
    // Will contain the toast message
    var message: String
    
    // Will contain the background color of the toast
    var color: UIColor
    
    // The anchor that will contain the top constant
    private var topConstant = [NSLayoutConstraint]()
    
    // The view that will contain the toast
    private lazy var toastView: UIView = {
        let tView = UIView()
        tView.backgroundColor = self.color
        tView.translatesAutoresizingMaskIntoConstraints = false
        tView.layer.masksToBounds = true
        tView.layer.cornerRadius = 10
        return tView
    }()
    
    // The label that will contain the message
    let label: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = UIFont.boldSystemFont(ofSize: 17)
        l.adjustsFontSizeToFitWidth = true
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .center
        return l
    }()
    
    // The initializer
    init(with message: String, color: UIColor = .red) {
        self.message = message
        self.color = color
    }
    
    // Will document whenever :P
    func show(on view: UIView?) -> Void {
        guard let view = view else { return }
        view.addSubview(toastView)
        toastView.addSubview(label)
        label.text = message
        
        toastView.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
        topConstant = toastView.anchorWithConstantsToTop(top: view.safeAreaLayoutGuide.topAnchor, topConstant: -250)
        toastView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        toastView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: toastView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: toastView.centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: view.frame.width - 40).isActive = true
        
        view.layoutIfNeeded()
        
        handleAnimation(view: view)
    }
    
    @objc fileprivate func handleAnimation(view: UIView) {
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.topConstant[0].constant = 20
            view.layoutIfNeeded()
        }) { (_) in
            UIView.animate(withDuration: 1, delay: 1.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.topConstant[0].constant = -250
                view.layoutIfNeeded()
            }) {(_) in
                // Safety measure, prevents constraints from killing each other
                self.toastView.removeFromSuperview()
            }
        }
    }
}
