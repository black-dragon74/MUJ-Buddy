//
//  GPAController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/31/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class GPAViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var GPADetails: GpaModel? {
        didSet {
            guard let gpa = GPADetails else { return }

            // Empty the dict first and then append, just to be safe coz I'm dealing with idiots
            gpaArray = []

            // Semester 1
            if let s1 = gpa.semester_1 {
                gpaArray.append(valueAsDict(withKey: "Semester 1", value: s1))
            }

            // Semester 2
            if let s2 = gpa.semester_2 {
                gpaArray.append(valueAsDict(withKey: "Semester 2", value: s2))
            }

            // Semester 3
            if let s3 = gpa.semester_3 {
                gpaArray.append(valueAsDict(withKey: "Semester 3", value: s3))
            }

            // Semester 4
            if let s4 = gpa.semester_4 {
                gpaArray.append(valueAsDict(withKey: "Semester 4", value: s4))
            }

            // Semester 5
            if let s5 = gpa.semester_5 {
                gpaArray.append(valueAsDict(withKey: "Semester 5", value: s5))
            }

            // Semester 6
            if let s6 = gpa.semester_6 {
                gpaArray.append(valueAsDict(withKey: "Semester 6", value: s6))
            }

            // Semester 7
            if let s7 = gpa.semester_7 {
                gpaArray.append(valueAsDict(withKey: "Semester 7", value: s7))
            }

            // Semester 8
            if let s8 = gpa.semester_8 {
                gpaArray.append(valueAsDict(withKey: "Semester 8", value: s8))
            }
        }
    }

    var gpaArray = [[String: String]]() // Dictionary that will contain the results

    // Cell reuse identifier
    let cellID = "cellID"

    // Collection View to contain our cards
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.delegate = self
        c.dataSource = self
        c.backgroundColor = DMSColors.primaryLighter.value
        return c
    }()

    // Refresh control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.addTarget(self, action: #selector(handleGPARefresh), for: .valueChanged)
        r.tintColor = .red
        return r
    }()

    // Activity indicator
    let indicator: UIActivityIndicatorView = {
       let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.color = .red
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "GPA Details"
        view.backgroundColor = DMSColors.primaryLighter.value

        // Setup additional views
        setupViews()

        // Test the functionality
        Service.shared.fetchGPA(sessionID: getSessionID()) { [weak self] (gpa, reauth,  error) in
            if let error = error {
                // Alert and return
                print("GPA Error: ", error)
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast.init(with: "Unable to fetch GPA details.").show(on: self?.view)
                }
                return
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
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

            if let gpa = gpa {
                self?.GPADetails = gpa

                // Now we assume that the dict is appended and ready with values
                // Reload the collection view
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.collectionView.reloadData()
                }
                return
            }
        }
    }

    // MARK: - Setup Views function
    fileprivate func setupViews() {
        collectionView.register(GPACell.self, forCellWithReuseIdentifier: cellID)
        collectionView.refreshControl = rControl

        // Add subviews
        view.addSubview(collectionView)
        view.addSubview(indicator)

        // Add constraints
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.startAnimating()

        collectionView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
    }

    // MARK: - Collection view delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gpaArray.count
    }

    // MARK: - Collection view flow delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 80)
    }

    // MARK: - Collection view data source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GPACell
        cell.currentGPA = gpaArray[indexPath.item]
        return cell
    }

    // MARK: - Function to handle refresh
    @objc fileprivate func handleGPARefresh() {
        Service.shared.fetchGPA(sessionID: getSessionID(), isRefresh: true) { [weak self] (gpa, reauth, error) in
            if let error = error {
                // Alert and return
                print("GPA Error: ", error)
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast.init(with: "Unable to fetch GPA details.").show(on: self?.view)
                }
                return
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
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

            if let gpa = gpa {
                self?.GPADetails = gpa

                // Now we assume that the dict is appended and ready with values
                // Reload the collection view
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    self?.collectionView.reloadData()
                }
                return
            }
        }
    }
}
