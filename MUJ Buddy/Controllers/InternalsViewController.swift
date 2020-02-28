//
//  InternalsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 2/1/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class InternalsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // Cell ID
    let cellID = "cellID"

    // Internals array
    var internalsArray = [InternalsModel]()

    // Refresh Control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .red
        return r
    }()

    // Activity indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.translatesAutoresizingMaskIntoConstraints = false
        i.color = .red
        return i
    }()

    // Coz initializing a collection view with nil layout is not allowed
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)

        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshForInternals), name: .triggerRefresh, object: nil)
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
        NotificationCenter.default.removeObserver(self, name: .triggerRefresh, object: nil)
    }

    // Override viewDidLoad and handle rest of the operations
    override func viewDidLoad() {

        super.viewDidLoad()

        navigationItem.title = "Internals Marks"
        collectionView.backgroundColor = UIColor(named: "primaryLighter")
        collectionView.refreshControl = rControl
        indicator.startAnimating()

        // Additional setups are handled separately
        setupViews()
        rControl.addTarget(self, action: #selector(handleRefreshForInternals), for: .valueChanged)

        // MARK: - Fetch data from the API
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                Toast(with: "Predicted semester as: \(semester)", color: .parrotGreen).show(on: self.view)
                setShowSemesterDialog(as: false)
            }
        }

        // Send the actual request
        Service.shared.fetchInternals(sessionID: getSessionID(), semester: semester) { [weak self] (data, reauth, err) in
            if let err = err {
                print("Error: ", err)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Error fetching marks").show(on: self?.view)
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

            if let data = data {
                for d in data {
                    self?.internalsArray.append(d)
                    DispatchQueue.main.async {
                        self?.indicator.stopAnimating()
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Setup additional views
    fileprivate func setupViews() {
        // Register the cell
        collectionView.register(InternalsCell.self, forCellWithReuseIdentifier: cellID)

        // Configure the collectionview
        collectionView.dataSource = self
        collectionView.delegate = self

        // Add additional views
        view.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleSemesterChange))
    }

    // MARK: - Required Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Collection view delegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return internalsArray.count
    }

    // MARK: - Delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 180)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! InternalsCell
        cell.internalData = internalsArray[indexPath.item]
        return cell
    }

    // MARK: - OBJC Refresh func
    @objc fileprivate func handleRefreshForInternals() {
        // Will be used after a trigger refresh notification is fired
        rControl.beginRefreshing()
        
        let semester = getSemester()
        
        Service.shared.fetchInternals(sessionID: getSessionID(), semester: semester, isRefresh: true) { [weak self] (data, reauth, err) in
            if let err = err {
                print("Error: ", err)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Error fetching marks").show(on: self?.view)
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

            if let data = data {
                self?.internalsArray = []
                for d in data {
                    self?.internalsArray.append(d)
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Semester change
    @objc fileprivate func handleSemesterChange() {
        let alert = UIAlertController(title: "Change semester", message: "Current semester is set to: \(getSemester())", preferredStyle: .alert)
        alert.addTextField { (semTF) in
            semTF.placeholder = "Enter new semester"
            semTF.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] (_) in
            guard let tf = alert.textFields?.first else { return }
            let iText = Int(tf.text!) ?? -1
            if iText > 8 || iText <= 0 {
                DispatchQueue.main.async {
                    Toast(with: "Invalid semester entered").show(on: self?.view)
                }
            } else {
                setSemester(as: iText)
                DispatchQueue.main.async {
                    Toast(with: "Semester updated. Refresh now.", color: .parrotGreen).show(on: self?.view)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
