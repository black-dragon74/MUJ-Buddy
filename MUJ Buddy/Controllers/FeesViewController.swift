//
//  FeesViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 2/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class FeesViewController: UIViewController {

    // Cell reuse identifier
    let cellID = "cellID"
    
    let green = [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1),#colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)]
    let red = [#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1),#colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)]

    // Start value for animation
    let startValue: Double = 0

    // Indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.color = .red
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    // Refresh control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .red
        return r
    }()

    // Main scroll view
    let scrollView: UIScrollView = {
        let m = UIScrollView()
        m.alwaysBounceVertical = true
        m.backgroundColor = .primaryLighter
        return m
    }()

    // Paid fee details card
    let paidFeeView: UIView = {
        let p = UIView()
        p.translatesAutoresizingMaskIntoConstraints = false
        p.heightAnchor.constraint(equalToConstant: 100).isActive = true
        p.layer.cornerRadius = 17
        p.backgroundColor = .white
        return p
    }()
    
    let paidLabel: UILabel = {
        let p = UILabel()
        p.textColor = .textPrimary
        p.font = .scoreFontBolder
        p.text = "PAID"
        return p
    }()

    let paidTF: UILabel = {
        let l = UILabel()
        l.text = "₹ Loading..."
        l.font = .scoreFontBolder
        l.textAlignment = .center
        l.textColor = .textSuccess
        return l
    }()

    // Unpaid fee details card
    let unpaidFeeView: UIView = {
        let u = UIView()
        u.translatesAutoresizingMaskIntoConstraints = false
        u.layer.cornerRadius = 17
        u.backgroundColor = .white
        u.heightAnchor.constraint(equalToConstant: 100).isActive = true
        return u
    }()
    
    let unpaidLabel: UILabel = {
        let p = UILabel()
        p.textColor = .textPrimary
        p.font = .scoreFontBolder
        p.text = "UNPAID"
        return p
    }()

    let unpaidTF: UILabel = {
        let l = UILabel()
        l.text = "₹ Loading..."
        l.font = .scoreFontBolder
        l.textColor = .textDanger
        l.textAlignment = .center
        return l
    }()

    let startTime = Date()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        
        if UIApplication.shared.isInDarkMode {
            view.backgroundColor = .darkBackgroundColor
            scrollView.backgroundColor = .darkBackgroundColor
            paidFeeView.backgroundColor = .darkCardBackgroundColor
            unpaidFeeView.backgroundColor = .darkCardBackgroundColor
            
            paidLabel.textColor = .darkTextPrimary
            unpaidLabel.textColor = .darkTextPrimary
        }
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Fee Details"
        indicator.startAnimating()

        setupViews()
        rControl.addTarget(self, action: #selector(handleFeeRefresh), for: .valueChanged)

        // MARK: - Fetch fee from API
        Service.shared.fetchFeeDetails(sessionID: getSessionID()) { [weak self] (fee, reauth, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Error fetching fee details").show(on: self?.view)
                }
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        self?.present(LoginViewController(), animated: true, completion: {
                            NotificationCenter.default.post(name: .sessionExpired, object: nil, userInfo: [:])
                        })
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let fee = fee {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()

                    if let totalPaid = fee.paid?.total {
                        self?.paidTF.text = "₹ \(totalPaid)"
                    }

                    if let totalUnpaid = fee.unpaid?.total {
                        self?.unpaidTF.text = "₹ \(totalUnpaid)"
                    } else {
                        self?.unpaidTF.text = "₹ 0.0"
                    }
                }
            }
        }
    }

    // MARK: - Setup additional views
    fileprivate func setupViews() {

        // Add primary views
        view.addSubview(scrollView)
        scrollView.addSubview(indicator)

        // Add subviews
        scrollView.refreshControl = rControl
        scrollView.anchorWithConstraints(top: view.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        
        scrollView.addSubview(paidFeeView)
        
        scrollView.addSubview(unpaidFeeView)

        // Paid fee views
        paidFeeView.addSubview(paidLabel)
        paidFeeView.addSubview(paidTF)

        // Unaid fee views
        unpaidFeeView.addSubview(unpaidTF)
        unpaidFeeView.addSubview(unpaidLabel)

        // Add constraints
        paidFeeView.anchorWithConstraints(top: scrollView.topAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)
        paidLabel.anchorWithConstraints(top: paidFeeView.topAnchor, right: paidFeeView.rightAnchor, left: paidFeeView.leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        paidTF.anchorWithConstraints(right: paidFeeView.rightAnchor, bottom: paidFeeView.bottomAnchor, rightOffset: 12, bottomOffset: 12)
       

        unpaidFeeView.anchorWithConstraints(top: paidFeeView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 10, rightOffset: 10, leftOffset: 10)
        unpaidLabel.anchorWithConstraints(top: unpaidFeeView.topAnchor, right: unpaidFeeView.rightAnchor, left: unpaidFeeView.leftAnchor, topOffset: 12, rightOffset: 12, leftOffset: 12)
        unpaidTF.anchorWithConstraints(right: unpaidFeeView.rightAnchor, bottom: unpaidFeeView.bottomAnchor, rightOffset: 12, bottomOffset: 12)
       

        indicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        
        if UIApplication.shared.isInDarkMode {
            paidFeeView.darkDropShadow()
            unpaidFeeView.darkDropShadow()
        }
        else {
            paidFeeView.dropShadow()
            unpaidFeeView.dropShadow()
        }
    }

    // MARK: - Fee refresh
    @objc fileprivate func handleFeeRefresh() {
        Service.shared.fetchFeeDetails(sessionID: getSessionID(), isRefresh: true) { [weak self] (fee, reauth, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Error fetching fee details").show(on: self?.view)
                }
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        self?.present(LoginViewController(), animated: true, completion: {
                            NotificationCenter.default.post(name: .sessionExpired, object: nil, userInfo: [:])
                        })
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let fee = fee {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()

                    if let totalPaid = fee.paid?.total {
                        self?.paidTF.text = "₹ \(totalPaid)"
                    }

                    if let totalUnpaid = fee.unpaid?.total {
                        self?.unpaidTF.text = "₹ \(totalUnpaid)"
                    } else {
                        self?.unpaidTF.text = "₹ 0.0"
                    }
                }
            }
        }
    }

    @objc func animateLabel() {
        let now = Date()
        let animationDuration: Double = 1
        let endValue: Double = 10000
        let elapsed = now.timeIntervalSince(startTime)
        if elapsed > animationDuration {
            paidTF.text = "₹ \(Int(endValue))"
        } else {
            let percent = elapsed / animationDuration
            let value =  startValue + percent * (endValue - startValue)
            let roundValue = Int(value)
            paidTF.text = "₹ \(roundValue)"
        }
    }
}
