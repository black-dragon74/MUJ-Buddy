//
//  Extensions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit


// Init the cache
let imageCache = NSCache<NSString, UIImage>()

// Custom extensions for this project, makes my life much easier
extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}

// Extension to UIView to set anchors for elements
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
}

// To load the image form an URL
extension UIImageView {
    func downloadImage(from url:String) {
        // Start a new session
        guard let u = URL(string: url) else { return }
        
        // Check if the image is there in the cache
        print(imageCache.object(forKey: url as NSString) ?? "Empty cache")
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            // Set the image
            self.image = cachedImage
            print("Set image from cache")
        } else {
            URLSession.shared.dataTask(with: u) {(data, response, error) in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else { return }
                // Set the image in the cache
                DispatchQueue.main.async {
                    self.image = image
                    
                    imageCache.setObject(image, forKey: url as NSString)
                    print("Set the image to the cache")
                }
                }.resume()
        }
        
    }
}
