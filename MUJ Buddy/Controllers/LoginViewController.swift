//
//  LoginPageViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // TODO: Change the status bar to be light
//    override var preferredStatusBarStyle: UIStatusBarStyle = .lightContent
    
    // Hold the keyboard state, in order to fix our view going out of bounds :P
    var isKbOpen: Bool = false
    
    // Collection view that hold the pages
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .white
        return cv
    }()
    
    // The cells
    let cellID = "cellid"
    let loginCell = "logincellid"
    
    // Create the arrays for pages
    let pages: [LoginPage] = {
        // Create the pages
        let firstPage = LoginPage(title: "Almighty", image: "page_1", subtitle: "The only app you need for all your needs at MUJ")
        let secondPage = LoginPage(title: "Crafted with love", image: "page_2", subtitle: "Each element is designed with ease of use in mind")
        let thirdPage = LoginPage(title: "One and only", image: "page_1", subtitle: "The only iOS app for MUJ")
        let fourthPage = LoginPage(title: "Let's begin", image: "page_3", subtitle: "Swipe left and let's dive into this awesomeness together")
        
        // Return the pages array
        return [firstPage, secondPage, thirdPage, fourthPage]
    }()
    
    // The page controller
    lazy var pControl: UIPageControl = {
        let p = UIPageControl()
        p.pageIndicatorTintColor = .lightGray
        p.currentPageIndicatorTintColor = UIColor(r: 247, g: 154, b: 27)
        p.numberOfPages = self.pages.count + 1
        return p
    }()
    
    // Skip button to skip the intro
    let skipButton: UIButton = {
        let s = UIButton()
        s.setTitle("Skip", for: .normal)
        s.setTitleColor(UIColor(r: 247, g: 154, b: 27), for: .normal)
        return s
    }()
    
    // Next button to skip the intro
    let nextButton: UIButton = {
        let n = UIButton()
        n.setTitle("Next", for: .normal)
        n.setTitleColor(UIColor(r: 247, g: 154, b: 27), for: .normal)
        return n
    }()
    
    // Variables to store anchor offsets
    var pControlBottomAnchor: NSLayoutConstraint?
    var sButtonTopAnchor: NSLayoutConstraint?
    var nButtonTopAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the cells
        collectionView.register(LoginPageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.register(LoginCell.self, forCellWithReuseIdentifier: loginCell)
        
        // Add subviews to the main View
        view.addSubview(collectionView)
        view.addSubview(pControl)
        view.addSubview(skipButton)
        view.addSubview(nextButton)
        
        // Add the constraints
        collectionView.anchorToTop(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        
        pControlBottomAnchor = pControl.anchorWithConstantsToTop(top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, topConstant: 0, rightConstant: 0, bottomConstant: 25, leftConstant: 0, heightConstant: 30)[1]
        
        sButtonTopAnchor = skipButton.anchorWithConstantsToTop(top: view.topAnchor, right: nil, bottom: nil, left: view.leftAnchor, topConstant: 16, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: 40, widthConstant: 60)[0]
        
        nButtonTopAnchor = nextButton.anchorWithConstantsToTop(top: view.topAnchor, right: view.rightAnchor, bottom: nil, left: nil, topConstant: 16, rightConstant: 0, bottomConstant: 0, leftConstant: 0, heightConstant: 40, widthConstant: 60)[0]
        
        // Listen for keyboard events
        listenForKeyboard()
        
        // In case someone taps outside the keyboard, end editing and close the keyboard
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
        
    }
    
    // Listens for keyboard hide and show events to push the view up and down
    fileprivate func listenForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Handles event of pushing view up on Y axis if the keyboard is going to show
    @objc fileprivate func handleKeyboardShow() {
        
        if !isKbOpen {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = CGRect(x: 0, y: self.view.frame.minY - 100, width: self.view.frame.width, height: self.view.frame.height)
            }) { (nil) in
                self.isKbOpen = true
            }
        }
        
    }
    
    // Handles event of pushing view back to normal on Y axis if the keyboard is going to hide
    @objc fileprivate func handleKeyboardHide() {
        if isKbOpen {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = CGRect(x: 0, y: self.view.frame.minY + 100, width: self.view.frame.width, height: self.view.frame.height)
            }) {(nil) in
                self.isKbOpen = false
            }
        }
    }
    
    // Ends the editing, hides the keyboard
    @objc fileprivate func endEditing() {
        view.endEditing(true)
    }
    
    // Function to skip to the next cell
    @objc fileprivate func scrollToNextCell() {
        
    }
    
    // Function to skip to the main login page
    @objc fileprivate func scrollToLogin() {
        
    }
    
    // Hide and show buttons, page control relative to the current page scroll event
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
        pControl.currentPage = currentPage
        
        // For removing the page control, next and skip buttons
        if (currentPage == pages.count) {
            // Change the constant
            pControlBottomAnchor?.constant = 40
            nButtonTopAnchor?.constant = -30
            sButtonTopAnchor?.constant = -30
        }
        else {
            // Change the constant
            pControlBottomAnchor?.constant = -25
            nButtonTopAnchor?.constant = 16
            sButtonTopAnchor?.constant = 16
        }
        
        // Animate the constraint changes
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // If user scrolls, end editing
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        endEditing()
    }
    
    // Number of sections to render
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count + 1  // +1 coz we have an extra login page at the end of the intro cells
    }
    
    // Cell for item at the index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.item == pages.count) {
            let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.loginCell, for: indexPath)
            return loginCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! LoginPageCell
        let currentPage = pages[indexPath.item]
        cell.page = currentPage
        return cell
    }
    
    // Size of an individual cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }

}

