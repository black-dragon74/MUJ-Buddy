//
//  LoginPageViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/19/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LoginDelegate {

    // Hold the keyboard state, in order to fix our view going out of bounds :P
    var isKbOpen: Bool = false
    
    // If view is being presented when session is expired, we work a bit differently
    var isSessionExpired: Bool = false

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
        let firstPage = LoginPage(title: "Almighty", image: "almighty", subtitle: "The only app you need for all your needs at MUJ")
        let secondPage = LoginPage(title: "Crafted with love", image: "crafted_with_love", subtitle: "Each element is designed with ease of use in mind")
        let thirdPage = LoginPage(title: "One and only", image: "one_and_only", subtitle: "The only iOS app for MUJ")
        let fourthPage = LoginPage(title: "Let's begin", image: "lets_begin", subtitle: "Swipe left and let's dive into this awesomeness together")

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionExpired), name: .sessionExpired, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(NSNotification.Name.sessionExpired)
    }

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

        // Add the targets to the buttons
        skipButton.addTarget(self, action: #selector(scrollToLogin), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(scrollToNextCell), for: .touchUpInside)

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
            }) { (_) in
                self.isKbOpen = true
            }
        }

    }

    // Handles event of pushing view back to normal on Y axis if the keyboard is going to hide
    @objc fileprivate func handleKeyboardHide() {
        if isKbOpen {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.frame = CGRect(x: 0, y: self.view.frame.minY + 100, width: self.view.frame.width, height: self.view.frame.height)
            }) {(_) in
                self.isKbOpen = false
            }
        }
    }

    // Ends the editing, hides the keyboard
    @objc fileprivate func endEditing() {
        view.endEditing(true)
    }

    // Move the controls off the screen
    fileprivate func moveControlsOffScreen() {
        pControlBottomAnchor?.constant = 40
        nButtonTopAnchor?.constant = -30
        sButtonTopAnchor?.constant = -30
    }

    // Function to skip to the next cell
    @objc fileprivate func scrollToNextCell() {
        if pControl.currentPage == pages.count {
            // On the last page, return
            return
        }

        if pControl.currentPage == pages.count - 1 {
            moveControlsOffScreen()

            // Animate the bitch
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }

        // Else, we will just keep on incrementing to the next page
        let currentCell = IndexPath(item: pControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: currentCell, at: .centeredHorizontally, animated: true)
        pControl.currentPage += 1
    }

    // Function to skip to the main login page
    @objc fileprivate func scrollToLogin() {
        // Set the current page to second last
        pControl.currentPage = pages.count - 1

        // Call next page from there, removes redundancy
        scrollToNextCell()

    }

    // Hide and show buttons, page control relative to the current page scroll event
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
        pControl.currentPage = currentPage

        // For removing the page control, next and skip buttons
        if (currentPage == pages.count) {
            // Off we go
            moveControlsOffScreen()
        } else {
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
            let loginCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.loginCell, for: indexPath) as! LoginCell
            loginCell.delegate = self
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

    func handleLogin(for client: String) {
        // Referene the cell
        let cell = collectionView.cellForItem(at: IndexPath(row: pages.count, section: 0)) as! LoginCell
        
        // Unwrap the value
        guard let userid = cell.userTextField.text else { return }
        
        if userid.isEmpty {
            Toast(with: "UserID cannot be empty").show(on: self.view)
            return
        }
        
        // Send the request
        disable(cell)
        
        Service.shared.sendOTPFor(userid: userid) {[weak self] (resp, error) in
            if let error = error {
                print("Error: ", error.localizedDescription)
                self?.enable(cell)
                return
            }
            
            if let resp = resp {
                // If sending the otp was not successful, show the message and return
                if (!resp.success) {
                    guard let errorMsg = resp.error else { return }
                    DispatchQueue.main.async {
                        Toast(with: errorMsg).show(on: self?.view)
                    }
                    self?.enable(cell)
                    return
                }
                
                
                // Else, extract the values from the response
                // Pass them to the OTP auth controller
                // Present the OTP auth controller
                let sid = resp.sid
                guard let vs = resp.vs else { return }
                guard let ev = resp.ev else { return }
                
                self?.enable(cell)
                
                // All the UIView items should must init on the main thread
                DispatchQueue.main.async {
                    let otpController = OTPAuthController()
                    otpController.ev = ev
                    otpController.vs = vs
                    otpController.userID = userid
                    otpController.sessionID = sid
                    otpController.isSessionExpired = self?.isSessionExpired
                    
                    self?.present(otpController, animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func enable(_ cell: LoginCell) {
        DispatchQueue.main.async {
            cell.progressBar.stopAnimating()
            cell.loginButton.isUserInteractionEnabled = true
        }
    }
    
    fileprivate func disable(_ cell: LoginCell) {
        DispatchQueue.main.async {
            cell.progressBar.startAnimating()
            cell.loginButton.isUserInteractionEnabled = false
        }
    }
    
    @objc fileprivate func sessionExpired() {
        scrollToLogin()
        perform(#selector(autoLogin), with: self, afterDelay: 0.5)
    }
    
    @objc fileprivate func autoLogin() {
        let cell = collectionView.cellForItem(at: IndexPath(row: pages.count, section: 0)) as! LoginCell
        Toast(with: "Session expired. Logging in again").show(on: view)
        isSessionExpired = true
        cell.userTextField.text = getUserID()
        handleLogin(for: "student")
    }

}
