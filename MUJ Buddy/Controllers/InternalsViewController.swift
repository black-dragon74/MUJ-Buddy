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
        r.addTarget(self, action: #selector(handleRefreshForInternals), for: .valueChanged)
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
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    // Override viewDidLoad and handle rest of the operations
    override func viewDidLoad() {

        super.viewDidLoad()

        navigationItem.title = "Internals Marks"
        collectionView.backgroundColor = DMSColors.primaryLighter.value
        collectionView.refreshControl = rControl
        indicator.startAnimating()

        // Additional setups are handled separately
        setupViews()

        // MARK: - Fetch data from the API
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                let alert = showAlert(with: "Your predicted semester is: \(semester)\n Edit it by tapping the button on top")
                self.present(alert, animated: true) {
                    setShowSemesterDialog(as: false)
                }
            }
        }

        // Send the actual request
        Service.shared.fetchInternals(token: getToken(), semester: semester) { [weak self] (data, err) in
            if let err = err {
                print("Error: ", err)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    let alert = showAlert(with: "Error fetching marks for semester: \(getSemester())")
                    self?.present(alert, animated: true, completion: nil)
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
        return CGSize(width: view.frame.width - 32, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! InternalsCell
        cell.internalData = internalsArray[indexPath.item]
        return cell
    }

    // MARK: - OBJC Refresh func
    @objc fileprivate func handleRefreshForInternals() {
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                let alert = showAlert(with: "Your predicted semester is: \(semester)\n Edit it by tapping the button on top")
                self.present(alert, animated: true) {
                    setShowSemesterDialog(as: false)
                }
            }
        }

        Service.shared.fetchInternals(token: getToken(), semester: semester, isRefresh: true) { [weak self] (data, err) in
            if let err = err {
                print("Error: ", err)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    let alert = showAlert(with: "Error fetching marks for semester: \(getSemester())")
                    self?.present(alert, animated: true, completion: nil)
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
                    let alert = showAlert(with: "Invalid semester entered.")
                    self?.present(alert, animated: true, completion: nil)
                }
            } else {
                setSemester(as: iText)
                DispatchQueue.main.async {
                    let alert = showAlert(with: "Semester updated as: \(iText). Refresh to fetch new details.")
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
