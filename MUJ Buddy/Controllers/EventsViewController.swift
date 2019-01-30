//
//  EventsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/30/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class EventsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Cell reuse identifier
    let cellID = "cellID"
    
    // Container for the events array
    var eventsArray = [EventsModel]()
    var filteredEventsArray = [EventsModel]()
    
    // Collection view refresh control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .red
        r.addTarget(self, action: #selector(handleEventsRefresh), for: .valueChanged)
        return r
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
    
    // Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        let newLayout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = newLayout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic config
        collectionView.backgroundColor = DMSColors.primaryLighter.value
        self.navigationItem.title = "Events"
        collectionView.delegate = self
        collectionView.dataSource = self
        // collectionView.refreshControl = rControl doesn't work when the controller is UICollectionViewController
        collectionView.addSubview(rControl) // This somehow works
        
        self.navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        // Handle rest of the config separately
        setupViews()
    }
    
    fileprivate func setupViews() {
        collectionView.register(EventsCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        indicator.startAnimating()
        
        //MARK:- Fetch the data
        fetchEvents(token: getToken()) { (data, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let alert = showAlert(with: "Unable to fetch events.")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    for d in data {
                        self.eventsArray.append(d)
                    }
                    self.eventsArray.reverse() // Reverse to show events in ascending order
                    self.indicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK:- Collection view delegate
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching() && !isSearchTextEmpty() ? filteredEventsArray.count : eventsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 32, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    //MARK:- Collection view data source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EventsCell
        cell.currentEvent = isSearching() && !isSearchTextEmpty() ? filteredEventsArray[indexPath.item] : eventsArray[indexPath.item]
        return cell
    }
    
    //MARK:- Function to fetch the events from the API
    fileprivate func fetchEvents(token: String, isRefresh: Bool = false, completion: @escaping([EventsModel]?, Error?) -> Void) {
        // We hate empty tokens
        if (token == "nil") {
            return
        }
        
        // Form the URL
        let tURL = API_URL + "events?token=\(token)"
        guard let url = URL(string: tURL) else { return }
        
        // If not refresh, means we have to return data from the DB. Check and return
        if !isRefresh {
            // Check if the data is in DB
            if let dataFromDB = getEventsFromDB() {
                print("Data from DB")
                let decoder = JSONDecoder()
                do {
                    let json = try decoder.decode([EventsModel].self, from: dataFromDB)
                    // Return the data
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("Json error: ", err)
                    completion(nil, err)
                    return
                }
            }
        }
        
        // Send a URL session
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("HTTP error: ", error)
                completion(nil, error)
                return
            }
            
            if let data = data {
                // Decode
                let decoder = JSONDecoder()
                print("Data from URL")
                do {
                    let json = try decoder.decode([EventsModel].self, from: data)
                    // Save it
                    let encoder = JSONEncoder()
                    let dataToSave = try? encoder.encode(json)
                    updateEventsInDB(events: dataToSave)
                    // Return with completion
                    completion(json, nil)
                    return
                }
                catch let err {
                    print("Json parse error: ", err)
                    completion(nil, err)
                    return
                }
            }
        }.resume()
    }
    
    //MARK:- Search controller functions
    fileprivate func isSearching() -> Bool {
        return self.searchController.isActive
    }
    
    fileprivate func isSearchTextEmpty() -> Bool {
        guard let text = self.searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            filteredEventsArray = []
        }
        else {
            filteredEventsArray = eventsArray.filter({ (model) -> Bool in
                return model.name.lowercased().contains(searchText.lowercased())
            })
        }
        
        perform(#selector(refreshCollectionView), with: self, afterDelay: 0.02)
    }
    
    
    //MARK:- OBJC Functions
    @objc func refreshCollectionView() {
        collectionView.reloadData()
    }
    
    @objc fileprivate func handleEventsRefresh() {
        print("Refresh called")
        fetchEvents(token: getToken(), isRefresh: true) { (data, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    let alert = showAlert(with: "Unable to fetch events.")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let data = data {
                
                self.eventsArray = []
                
                for d in data {
                    self.eventsArray.append(d)
                }
                
                self.eventsArray.reverse() // Reverse to show events in ascending order
                
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    self.collectionView.reloadData()
                }
                return
            }
        }
    }
}