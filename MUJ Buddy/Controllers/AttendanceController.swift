//
//  AttendanceController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class AttendanceController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // This view is also a collection view controller with elems for each subject
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.backgroundColor = DMSColors.primaryLighter.value
        return c
    }()
    
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
        r.addTarget(self, action: #selector(handleAttendanceRefresh), for: .valueChanged)
        r.tintColor = .red
        return r
    }()
    
    var attendanceDetails = [AttendanceModel]()
    
    let cellID = "cellID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Attendance"
        view.backgroundColor = .lightGray
        
        setupViews()
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
        
        collectionView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, topOffset: 0, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        // Get attendance details
        getAttendance(token: getToken()) { (model, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let alert = showAlert(with: "Your attendance is not available on the DMS")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let data = model {
                for d in data {
                    self.attendanceDetails.append(d)
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.indicator.stopAnimating()
                }
            }
        }
    }
    
    //MARK:- CV Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attendanceDetails.count
    }
    
    //MARK:- CV Data Source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! AttendanceCell
        cell.attendance = attendanceDetails[indexPath.row]
        return cell
    }
    
    //MARK:- CV Delegate Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    //MARK:- Custom functions
    func getAttendance(token: String, isRefresh: Bool = false, completion: @escaping([AttendanceModel]?, Error?) -> Void) {
        // We hate empty tokens, right?
        if token == "nil" {
            return
        }
        
        // Check if attendance is there in the DB, saves an extra call, but only when it is not a refresh request
        if !isRefresh {
            if let attendanceInDB = getAttendanceFromDB() {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode([AttendanceModel].self, from: attendanceInDB)
                    completion(json, nil)
                    return
                }
                catch let err {
                    completion(nil, err)
                    return
                }
            }
        }
        
        let u = API_URL + "attendance?token=\(token)"
        guard let url = URL(string: u) else { return }
        
        // Start a URL session
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([AttendanceModel].self, from: data)
                    // Save to user defaults
                    let encoder = JSONEncoder()
                    let attendanceData = try? encoder.encode(json) // If it is empty, nil value will be returned from the utility function
                    updateAttendanceInDB(attendance: attendanceData)
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("JSON ERROR, ", err)
                    completion(nil, err)
                    return
                }
            }
            }.resume()
    }
    
    @objc func handleAttendanceRefresh() {
        // Get attendance details
        getAttendance(token: getToken(), isRefresh: true) { (model, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    let alert = showAlert(with: "Your attendance is not available on the DMS")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let data = model {
                self.attendanceDetails = [] // Coz we will append to it now
                for d in data {
                    self.attendanceDetails.append(d)
                }
                
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}
