//
//  ContactsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // Cell indentifier
    let cellID = "cellID"
    
    // Faculty details that will be fetched
    var facultyDetails = [FacultyContactModel]()
    var filteredFacultyDetails = [FacultyContactModel]()
    
    // Search controller
    let searchController = UISearchController(searchResultsController: nil)
    
    // Refresh Control
    let rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .red
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register the cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        // Setup the views
        setupViews()
    }
    
    func setupViews() {
        self.title = "Faculty Contacts"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        rControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.refreshControl = rControl
        
        self.indicator.startAnimating()
        
        view.addSubview(indicator)
        
        indicator.anchorWithConstraints(top: view.centerYAnchor, left: view.centerXAnchor, topOffset: -100, leftOffset: -20)
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        // Get faculty details
        getFacultyDetails(token: getToken()) { (faculties, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    let alert = showAlert(with: "Unable to get faculty details.")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let facultie = faculties {
                for f in facultie {
                    self.facultyDetails.append(f)
                }
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("Memory warning received.")
    }
    
    //MARK:- Refresh Control OBJC method
    @objc fileprivate func handleRefresh() {
        // Refresh
        getFacultyDetails(token: getToken(), isRefresh: true) { (faculties, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    let alert = showAlert(with: "Unable to get faculty details.")
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            if let facultie = faculties {
                self.facultyDetails = []
                for f in facultie {
                    self.facultyDetails.append(f)
                }
                DispatchQueue.main.async {
                    self.rControl.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK:- Table view delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFacultyDetails.count == 0 ? facultyDetails.count : filteredFacultyDetails.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredFacultyDetails.count == 0 ? facultyDetails[indexPath.row] : filteredFacultyDetails[indexPath.row]
        let fView = FacultyContactViewController()
        fView.currentFaculty = selectedItem
        self.navigationController?.pushViewController(fView, animated: true)
    }
    
    // MARK:- Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        cell.textLabel?.text = filteredFacultyDetails.count == 0 ? facultyDetails[indexPath.row].name : filteredFacultyDetails[indexPath.row].name
        return cell
    }
    
    //MARK:- Search Controller delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            // Null the array
            filteredFacultyDetails = []
        }
        else {
            filteredFacultyDetails = facultyDetails.filter({ (model) -> Bool in
                return model.name.lowercased().contains(text.lowercased())
            })
        }
        
        perform(#selector(refreshTableView), with: self, afterDelay: 0.02)
    }
    
    @objc func refreshTableView() {
        tableView.reloadData()
    }
    
    func isSearching() -> Bool {
        return self.searchController.isActive
    }
    
    func isSearchTextEmpty() -> Bool {
        guard let text = self.searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    func getFacultyDetails(token: String, isRefresh: Bool = false, uponFinishing: @escaping ([FacultyContactModel]?, Error?) -> ()) {
        // We hate empty tokens, right?
        if token == "nil" {
            return
        }
        
        let tURL = API_URL + "faculties?token=\(token)"
        
        guard let url = URL(string: tURL) else { return }
        
        if !isRefresh {
            // Check if the data is there in userdefaults
            if let data = UserDefaults.standard.object(forKey: FACULTY_CONTACT_KEY) as? Data {
                print("Processing User Defaults data")
                do {
                    let decoder = JSONDecoder()
                    let json =  try decoder.decode([FacultyContactModel].self, from: data)
                    print("Got data as JSON from user defaults")
                    uponFinishing(json, nil)
                    return
                }
                catch let err {
                    print("JSON ERROR in user defaults, ",err)
                    uponFinishing(nil, err)
                    return
                }
            }
        }
        
        // Send the request, if the datat is not saved in user defaults
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                print("HTTP error: ", error)
                uponFinishing(nil, error)
                return
            }
            
            if let data = data {
                // Try to decode
                do {
                    let decoder = JSONDecoder()
                    let json =  try decoder.decode([FacultyContactModel].self, from: data)
                    print("Got data as JSON from the web")
                    // Encode and save
                    let encoder = JSONEncoder()
                    let encodedData = try! encoder.encode(json)
                    UserDefaults.standard.removeObject(forKey: FACULTY_CONTACT_KEY)
                    UserDefaults.standard.set(encodedData, forKey: FACULTY_CONTACT_KEY)
                    uponFinishing(json, nil)
                }
                catch let err {
                    print("JSON ERROR, ",err)
                    uponFinishing(nil, err)
                    return
                }
            }
            
            }.resume()
    }
    
}
