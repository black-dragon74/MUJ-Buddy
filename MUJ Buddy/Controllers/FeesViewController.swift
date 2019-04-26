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

    // Start value for animation
    let startValue: Double = 0

    // Indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.color = .white
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()

    // Refresh control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .white
        r.addTarget(self, action: #selector(handleFeeRefresh), for: .valueChanged)
        return r
    }()

    // Main scroll view
    let scrollView: UIScrollView = {
        let m = UIScrollView()
        m.alwaysBounceVertical = true
        m.backgroundColor = DMSColors.kindOfPurple.value
        return m
    }()

    // Paid fee details card
    let paidFeeView: UIView = {
        let p = UIView()
        p.backgroundColor = .white
        p.translatesAutoresizingMaskIntoConstraints = false
        p.layer.masksToBounds = true
        p.dropShadow(scale: false)
        p.layer.cornerRadius = 8
        return p
    }()

    let paidLabel: UILabel = {
        let l = UILabel()
        l.text = "₹ Loading..."
        l.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    let paidImage: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "paid")
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.heightAnchor.constraint(equalToConstant: 100).isActive = true
        i.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return i
    }()

    // Unpaid fee details card
    let unpaidFeeView: UIView = {
        let u = UIView()
        u.backgroundColor = .white
        u.translatesAutoresizingMaskIntoConstraints = false
        u.layer.masksToBounds = true
        u.layer.cornerRadius = 8
        return u
    }()

    let unpaidLabel: UILabel = {
        let l = UILabel()
        l.text = "₹ Loading..."
        l.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        l.textAlignment = .center
        return l
    }()

    let unpaidImage: UIImageView = {
        let i = UIImageView()
        i.image = UIImage(named: "unpaid")
        i.contentMode = .scaleAspectFill
        i.translatesAutoresizingMaskIntoConstraints = false
        i.heightAnchor.constraint(equalToConstant: 100).isActive = true
        i.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return i
    }()

    let startTime = Date()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
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

        // MARK: - Fetch fee from API
        Service.shared.fetchFeeDetails(sessionID: getSessionID()) { [weak self] (fee, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Error fetching fee details").show(on: self?.view)
                }
            }

            if let fee = fee {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()

                    if let totalPaid = fee.paid?.total {
                        self?.paidLabel.text = "₹ \(totalPaid)"
                    }

                    if let totalUnpaid = fee.unpaid?.total {
                        self?.unpaidLabel.text = "₹ \(totalUnpaid)"
                    } else {
                        self?.unpaidLabel.text = "₹ 0.0"
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
        paidFeeView.addSubview(paidImage)

        // Unaid fee views
        unpaidFeeView.addSubview(unpaidLabel)
        unpaidFeeView.addSubview(unpaidImage)

        // Add constraints
        paidFeeView.anchorWithConstraints(top: scrollView.topAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 16, rightOffset: 16, leftOffset: 16, height: 160)
        paidLabel.anchorWithConstraints(top: paidFeeView.topAnchor, right: paidFeeView.rightAnchor, left: paidFeeView.leftAnchor, topOffset: 16, rightOffset: 16, leftOffset: 16)
        paidImage.centerXAnchor.constraint(equalTo: paidFeeView.centerXAnchor).isActive = true
        paidImage.centerYAnchor.constraint(equalTo: paidFeeView.centerYAnchor, constant: 25).isActive = true

        unpaidFeeView.anchorWithConstraints(top: paidFeeView.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 20, rightOffset: 16, leftOffset: 16, height: 160)
        unpaidLabel.anchorWithConstraints(top: unpaidFeeView.topAnchor, right: unpaidFeeView.rightAnchor, left: unpaidFeeView.leftAnchor, topOffset: 16, rightOffset: 16, leftOffset: 16)
        unpaidImage.centerXAnchor.constraint(equalTo: unpaidFeeView.centerXAnchor).isActive = true
        unpaidImage.centerYAnchor.constraint(equalTo: unpaidFeeView.centerYAnchor, constant: 25).isActive = true

        indicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
    }

    // MARK: - Fee refresh
    @objc fileprivate func handleFeeRefresh() {
        Service.shared.fetchFeeDetails(sessionID: getSessionID(), isRefresh: true) { [weak self] (fee, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Error fetching fee details").show(on: self?.view)
                }
            }

            if let fee = fee {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()

                    if let totalPaid = fee.paid?.total {
                        self?.paidLabel.text = "₹ \(totalPaid)"
                    }

                    if let totalUnpaid = fee.unpaid?.total {
                        self?.unpaidLabel.text = "₹ \(totalUnpaid)"
                    } else {
                        self?.unpaidLabel.text = "₹ 0.0"
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
            paidLabel.text = "₹ \(Int(endValue))"
        } else {
            let percent = elapsed / animationDuration
            let value =  startValue + percent * (endValue - startValue)
            let roundValue = Int(value)
            paidLabel.text = "₹ \(roundValue)"
        }
    }
}
