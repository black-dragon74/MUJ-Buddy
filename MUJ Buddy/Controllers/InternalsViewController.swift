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
    
    // Override viewDidLoad and handle rest of the operations
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Internals Marks"
        collectionView.backgroundColor = DMSColors.primaryLighter.value
        collectionView.refreshControl = rControl
        indicator.startAnimating()
        
        // Additional setups are handled separately
        setupViews()
        
        //MARK:- Fetch data from the API, hardcoded semester
        Service.shared.fetchInternals(token: getToken(), semester: 1) { [unowned self] (data, err) in
            if let err = err {
                print("Error: ",err)
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let alert = showAlert(with: "Error fetching internals marks")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            if let data = data {
                for d in data {
                    self.internalsArray.append(d)
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK:- Setup additional views
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
    }
    
    //MARK:- Required Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Collection view delegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return internalsArray.count
    }
    
    //MARK:- Delegate flow layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    //MARK:- Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! InternalsCell
        cell.internalData = internalsArray[indexPath.item]
        return cell
    }
    
    //MARK:- OBJC Refresh func
    @objc fileprivate func handleRefreshForInternals() {
        Service.shared.fetchInternals(token: getToken(), semester: 1, isRefresh: true) { [unowned self] (data, err) in
            if let err = err {
                print("Error: ",err)
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    let alert = showAlert(with: "Error fetching internals marks")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            if let data = data {
                for d in data {
                    self.internalsArray.append(d)
                    DispatchQueue.main.async {
                        self.rControl.endRefreshing()
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}
