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

// MARK: - UIView Extensions
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
        layer.shadowColor = UIColor(named: "dropShadow")!.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowRadius = self.layer.cornerRadius
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
    
    // Function that animates the view's background color to the given value
    func animateBGColorTo(color: UIColor) {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.backgroundColor = color
        }, completion: nil)
    }
    
    // Function to add a diagonal gradient that starts from the bottom center and ends at top center
    func linearGradient(from: UIColor, to: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [from.cgColor, to.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UIImageView Extensions
extension UIImageView {
    func downloadFromURL(urlString: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let escapedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: escapedURL!) else { return }

        URLSession.shared.dataTask(with: url) {(data, _, error) in
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

extension Notification.Name {
    // This notification is posted whenever user taps on the Attendance Notification
    static let didTapOnAttendanceNotification = NSNotification.Name("didTapOnAttendanceNotification")
    
    // This notification is posted whenever a reauth is needed. It is catched in the appropriate VCs
    static let isReauthRequired = NSNotification.Name("isReauthRequired")
    
    // This notification is observed in the login view controller and is shown on session expiry
    static let sessionExpired = NSNotification.Name("MUJsessionExpired")
    
    // This notification is observed in the login view controller and is fired when login is cancelled
    static let loginCancelled = NSNotification.Name(rawValue: "MUJLoginCancelled")
    
    // This notification is observed in the login view controller and is fired when login is successful
    static let loginSuccessful = NSNotification.Name(rawValue: "MUJLoginSuccess")
    
    // This notification is observed in each VC where the session might expire and a reauth is required
    static let triggerRefresh = NSNotification.Name(rawValue: "MUJReloadTBCV")
}

// Extension on string
extension String {
    func capitalizeFirstLetter() -> String {
        return self.capitalized(with: nil)
    }
}

// Extension on a UINavigationItem to set the title and the subtitle for the NavItem
extension UINavigationItem {
    
    func setHeader(title: String, subtitle: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textAlignment = .center
        subtitleLabel.sizeToFit()
        
        // Stack view to hold these
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        
        // Set the frame for the stack view
        let width = max(titleLabel.frame.size.width, subtitleLabel.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        self.titleView = stackView
    }
}

// Extensions to customize fonts
extension UIFont {
    // Bold Font
    func bold() -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(.traitBold) else { return UIFont.boldSystemFont(ofSize: 17) }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

// Extension on Equatable array types to remove duplicates
extension Array where Element: Equatable {
    /// Returns the same object after removing duplicate values from it.
    mutating func removeDuplicates() {
        var temp = [Element]()
        for s in self {
            if !temp.contains(s) {
                temp.append(s)
            }
        }
        self = temp
    }
    
    /// Returns a new instance of the object with duplicate values removed.
    func removingDuplicates() -> [Element] {
        var temp = [Element]()
        for s in self {
            if !temp.contains(s) {
                temp.append(s)
            }
        }
        return temp
    }
}
