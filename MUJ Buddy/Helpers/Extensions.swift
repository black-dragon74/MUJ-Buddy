//
//  Extensions.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

// Used by download image from URL method to save to the local disk
let fileManager = FileManager.default
let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

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
        // For storing the downloaded image locally
        let tempURL = url.replacingOccurrences(of: "/", with: "")
        let imageNameForStorage = docURL.appendingPathComponent(tempURL)
        
        // If the image is already present in the local directory, use that and stop the network request
//        guard (FileManager.default.contents(atPath: imageNameForStorage.path) != nil),
//            let imageData = try? Data(contentsOf: imageNameForStorage),
//            let image = UIImage(data: imageData) else {
//                return
//        }
        if FileManager.default.contents(atPath: imageNameForStorage.path) != nil {
            let imageData = try? Data(contentsOf: imageNameForStorage)
            if let data = imageData {
                self.image = UIImage(data: data)
                print("Data was loaded from the local storage")
                return
            }
        }
        else {
            guard let u = URL(string: url) else { return }
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
                    // Now we will store the image locally and fetch it before the next call
                    do {
                        if let pngImageData = image.pngData() {
                            print(tempURL)
                            try pngImageData.write(to: imageNameForStorage, options: .atomic)
                            print("Stored image locally.")
                        }
                    }
                    catch let err {
                        print("Error: ",err)
                    }
                }
                }.resume()
        }
    }
}
