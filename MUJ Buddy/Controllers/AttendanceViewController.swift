//
//  AttendanceController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class AttendanceViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // Indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        i.color = .red
        return i
    }()

    // Refresh control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .red
        return r
    }()

    var attendanceDetails = [AttendanceModel]()

    let cellID = "cellID"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAttendanceRefresh), name: .triggerRefresh, object: nil)

        view.backgroundColor = UIColor(named: "primaryLighter")
        collectionView.backgroundColor = UIColor(named: "primaryLighter")
    }

    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
        NotificationCenter.default.removeObserver(self, name: .triggerRefresh, object: nil)
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)

        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Attendance"
        collectionView.backgroundColor = UIColor(named: "primaryLighter")

        setupViews()

        rControl.addTarget(self, action: #selector(handleAttendanceRefresh), for: .valueChanged)
    }

    func setupViews() {
        // Add the subviews to the main views
        view.addSubview(collectionView)
        view.addSubview(indicator)

        // Collection view config
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AttendanceCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.refreshControl = rControl

        // Constraints
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.startAnimating()

        // Get attendance details
        Service.shared.getAttendance(sessionID: getSessionID()) { [weak self] model, reauth, err in
            if err != nil {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Attendance not available").show(on: self?.view)
                }
                return
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
                } else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = model {
                for d in data {
                    self?.attendanceDetails.append(d)
                }

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.indicator.stopAnimating()
                }
            }
        }
    }

    // MARK: - CV Delegate

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        attendanceDetails.count
    }

    // MARK: - CV Data Source

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AttendanceCell
        cell.attendance = attendanceDetails[indexPath.row]
        return cell
    }

    // MARK: - CV Delegate Flow Layout

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 20, height: 100)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        10
    }

    @objc func handleAttendanceRefresh() {
        // Will be used after a trigger refresh notification is fired
        rControl.beginRefreshing()

        // Get attendance details
        Service.shared.getAttendance(sessionID: getSessionID(), isRefresh: true) { [weak self] model, reauth, err in
            if err != nil {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Attendance not available").show(on: self?.view)
                }
                return
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
                } else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = model {
                self?.attendanceDetails = [] // Coz we will append to it now
                for d in data {
                    self?.attendanceDetails.append(d)
                }

                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
