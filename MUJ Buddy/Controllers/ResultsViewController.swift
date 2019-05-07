//
//  ResultsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 2/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ResultsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var resultsArray = [ResultsModel]()

    // Cell reuse identifier
    let cellID = "cellID"

    // Activity Indicator
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        
        if UIApplication.shared.isInDarkMode {
            view.backgroundColor = .darkBackgroundColor
            collectionView.backgroundColor = .darkBackgroundColor
        }
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)

        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.refreshControl = rControl
        indicator.startAnimating()

        setupViews()
        rControl.addTarget(self, action: #selector(handleResultsRefresh), for: .valueChanged)
    }

    fileprivate func setupViews() {
        view.addSubview(indicator)

        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // MARK: - Get results from API
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                Toast(with: "Predicted semester as: \(semester)", color: .parrotGreen).show(on: self.view)
                setShowSemesterDialog(as: false)
            }
        }

        Service.shared.fetchResults(sessionID: getSessionID(), semester: semester) { [weak self] (results, reauth, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Error fetching marks").show(on: self?.view)
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
                }
                else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = results {
                for d in data {
                    self?.resultsArray.append(d)
                }
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .primaryLighter
        navigationItem.title = "Results"
        collectionView.register(ResultsCell.self, forCellWithReuseIdentifier: cellID)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleSemesterChange))
    }

    // MARK: - Collection view delegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resultsArray.count
    }

    // MARK: - Collection view delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 20, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ResultsCell
        cell.currentSubjectForResult = resultsArray[indexPath.item]
        cell.isDark = UIApplication.shared.isInDarkMode
        return cell
    }

    // MARK: - OBJC Refresh function
    @objc fileprivate func handleResultsRefresh() {
        let semester = getSemester()  // Will contain the predicted semester

        Service.shared.fetchResults(sessionID: getSessionID(), semester: semester, isRefresh: true) { [weak self] (results, reauth, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Error fetching results").show(on: self?.view)
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
                }
                else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = results {
                self?.resultsArray = []
                for d in data {
                    self?.resultsArray.append(d)
                }
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    self?.collectionView.reloadData()
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
