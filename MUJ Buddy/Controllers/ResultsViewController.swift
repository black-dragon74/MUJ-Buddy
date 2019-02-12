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
        r.addTarget(self, action: #selector(handleResultsRefresh), for: .valueChanged)
        return r
    }()
    
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

    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)

        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.refreshControl = rControl
        indicator.startAnimating()

        setupViews()
    }

    fileprivate func setupViews() {
        view.addSubview(indicator)

        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        // MARK: - Get results from API
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                let alert = showAlert(with: "Your predicted semester is: \(semester)\n Edit it by tapping the button on top")
                self.present(alert, animated: true) {
                    setShowSemesterDialog(as: false)
                }
            }
        }

        Service.shared.fetchResults(token: getToken(), semester: semester) { [unowned self] (results, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let alert = showAlert(with: "Error fetching results for semester: \(getSemester())")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            if let data = results {
                for d in data {
                    self.resultsArray.append(d)
                }
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = DMSColors.primaryLighter.value
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
        return CGSize(width: view.frame.width - 32, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    // MARK: - Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ResultsCell
        cell.currentSubjectForResult = resultsArray[indexPath.item]
        return cell
    }

    // MARK: - OBJC Refresh function
    @objc fileprivate func handleResultsRefresh() {
        let semester = getSemester()  // Will contain the predicted semester

        if showSemesterDialog() {
            DispatchQueue.main.async {
                let alert = showAlert(with: "Your predicted semester is: \(semester)\n Edit it by tapping the button on top")
                self.present(alert, animated: true) {
                    setShowSemesterDialog(as: false)
                }
            }
        }

        Service.shared.fetchResults(token: getToken(), semester: semester, isRefresh: true) { [unowned self] (results, error) in
            if let error = error {
                print("Error: ", error)
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    let alert = showAlert(with: "Error fetching results for semester: \(getSemester())")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }

            if let data = results {
                self.resultsArray = []
                for d in data {
                    self.resultsArray.append(d)
                }
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    self.collectionView.reloadData()
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
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            guard let tf = alert.textFields?.first else { return }
            let iText = Int(tf.text!) ?? -1
            if iText > 8 || iText <= 0 {
                DispatchQueue.main.async {
                    let alert = showAlert(with: "Invalid semester entered.")
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                setSemester(as: iText)
                DispatchQueue.main.async {
                    let alert = showAlert(with: "Semester updated as: \(iText). Refresh to fetch new details.")
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}
