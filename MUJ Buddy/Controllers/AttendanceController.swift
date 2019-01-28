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
        c.backgroundColor = .lightGray
        return c
    }()
    
    // Indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.style = .whiteLarge
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        i.color = .orange
        return i
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
        
        // Constraints
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        indicator.startAnimating()
        
        collectionView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, topOffset: 0, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        // Get attendance details
        getAttendance(token: TOKEN) { (model, err) in
            if err != nil {
                self.indicator.stopAnimating()
                return
            }
            
            if let data = model {
                for d in data {
                    DispatchQueue.main.async {
                        self.attendanceDetails.append(d)
                        self.collectionView.reloadData()
                        self.indicator.stopAnimating()
                    }
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
    func getAttendance(token: String, completion: @escaping([AttendanceModel]?, Error?) -> Void) {
        let u = "https://restfuldms.herokuapp.com/attendance?token=\(token)"
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
    
}
