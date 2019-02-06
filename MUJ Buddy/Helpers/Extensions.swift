//
//  Extensions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// Custom extensions for this project, makes my life much easier
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}

//MARK:- UIView Extensions
extension UIView {
    // Just adds the anchors
    func anchorToTop(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil) {
        
        _ = anchorWithConstantsToTop(top: top, right: right, bottom: bottom, left: left, topConstant: 0, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: nil, widthConstant: nil)
        
    }
    
    // Function to add anchor constants, it also returns an array containing the values for each constraint
    func anchorWithConstantsToTop(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, topConstant: CGFloat = 0, rightConstant: CGFloat = 0, bottomConstant: CGFloat = 0, leftConstant: CGFloat = 0, heightConstant: CGFloat? = nil, widthConstant: CGFloat? = nil) -> [NSLayoutConstraint] {
        
        // We generally forget this and then wonder why our view is not being rendered
        translatesAutoresizingMaskIntoConstraints = false
        
        // Array to return
        var anchors: [NSLayoutConstraint] = []
        
        // For the top constraint
        if let top = top {
            anchors.append(topAnchor.constraint(equalTo: top, constant: topConstant))
        }
        
        // For the right constraint
        if let right = right {
            anchors.append(rightAnchor.constraint(equalTo: right, constant: -rightConstant))
        }
        
        // For the bottom constraint
        if let bottom = bottom {
            anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -bottomConstant))
        }
        
        // For the left constraint
        if let left = left {
            anchors.append(leftAnchor.constraint(equalTo: left, constant: leftConstant))
        }
        
        // For the height
        if let height = heightConstant {
            anchors.append(heightAnchor.constraint(equalToConstant: height))
        }
        
        // For the width
        if let width = widthConstant {
            anchors.append(widthAnchor.constraint(equalToConstant: width))
        }
        
        anchors.forEach({$0.isActive = true})
        
        return anchors
    }
    
    func anchorWithConstraints(top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, topOffset: CGFloat = 0, rightOffset: CGFloat = 0, bottomOffset: CGFloat = 0, leftOffset: CGFloat = 0, height: CGFloat? = nil, width: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: topOffset).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -rightOffset).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -bottomOffset).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: leftOffset).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
    }
    
    // Functions to add a drop shadow
    // This adds a basic shadow
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // This can be initialized with configuration options
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

//MARK:- Date Extensions
extension Date {
    func monthsTillNow() -> Int {
        // This will return the months from the given date to current date
        let rawMonths = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
        return rawMonths
    }
    
    func hoursTillNow() -> Int {
        // Returns interval in hours from the input date to current
        let rawHours = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
        return rawHours
    }
}

//MARK:- UIImageView Extensions
extension UIImageView {
    func downloadFromURL(urlString: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let escapedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: escapedURL!) else { return }
        
        URLSession.shared.dataTask(with: url) {(data, status, error) in
            if let error = error {
                print(error)
                completion(nil, error)
                return
            }
            
            if let data = data {
                let image = UIImage(data: data)
                completion(image, nil)
                return
            }
            }.resume()
    }
}
