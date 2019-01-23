//
//  ContactsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
    
    let cellID = "cellid"
    let blankCellID = "blackcellid"
    
    let selectedFaculty = -1
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var faculties = [FacultyContactModel]()
    var filteredFaculties = [FacultyContactModel]()
    
    lazy var rControl: UIRefreshControl = {
        let r = UIRefreshControl()
        r.tintColor = .orange
        return r
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        
        // Set up the views
        setupViews()
    }
    
    fileprivate func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FacultyContactCell.self, forCellReuseIdentifier: cellID)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: blankCellID)
        self.navigationItem.searchController = searchController
        
        rControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.addSubview(rControl)
        
        if let facultyData = UserDefaults.standard.data(forKey: FACULTY_CONTACT_KEY) {
            // Try to decode the data
            let decodedData = try! JSONDecoder().decode([FacultyContactModel].self, from: facultyData)
            for f in decodedData {
                faculties.append(f)
            }
        }
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    @objc func handleRefresh() {
        // Create a new URLSession
        guard let url = URL(string: API_URL) else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {return}
            if let error = error {
                print("HTTP Error", error)
            }
            do {
                
                // Decode the data
                let decoder = JSONDecoder()
                let f = try decoder.decode([FacultyContactModel].self, from: data)
                
                DispatchQueue.main.async {
                    // Empty the array as we'll populate once again
                    self.faculties = []
                    
                    // Append the array
                    for faculty in f {
                        self.faculties.append(faculty)
                    }
                    
                    // Save the data upon serialization
                    let dataToSave = try! JSONEncoder().encode(self.faculties)
                    UserDefaults.standard.removeObject(forKey: FACULTY_CONTACT_KEY)
                    UserDefaults.standard.set(dataToSave, forKey: FACULTY_CONTACT_KEY)
                }
            }
            catch let err {
                print("JSON Error ", err)
            }
        }
        task.resume()
        
        perform(#selector(reloadTable), with: nil, afterDelay: 0.2)
        
    }
    
    @objc func reloadTable() {
        self.rControl.endRefreshing()
        reloadTableView(tableViewToReload: tableView)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching() && !isSearchTextEmpty() ? filteredFaculties.count : faculties.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fv = FacultyContactView()
        fv.currentFaculty = isSearching() && !isSearchTextEmpty() ? filteredFaculties[indexPath.row] : faculties[indexPath.row]
        self.navigationController?.pushViewController(fv, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FacultyContactCell
        let currentFaculty = isSearching() && !isSearchTextEmpty() ? filteredFaculties[indexPath.row] : faculties[indexPath.row]
        cell.currentFaculty = currentFaculty
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.isEmpty {
            filteredFaculties = []
        }
        else {
            filteredFaculties = faculties.filter({ (model) -> Bool in
                return model.name.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }
    
    func isSearching() -> Bool {
        return searchController.isActive
    }
    
    func isSearchTextEmpty() -> Bool {
        guard let text = searchController.searchBar.text else { return false }
        
        return text.isEmpty
    }
}
