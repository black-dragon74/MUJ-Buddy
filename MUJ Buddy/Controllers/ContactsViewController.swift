//
//  ContactsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/20/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, UISearchBarDelegate {
    
    let cellID = "cellid"
    let blankCellID = "blackcellid"
    
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
        tableView.allowsSelection = false
        
        rControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.addSubview(rControl)
        
        setupSearchBar()
        
        if let facultyData = UserDefaults.standard.data(forKey: FACULTY_CONTACT_KEY) {
            // Try to decode the data
            let decodedData = try! JSONDecoder().decode([FacultyContactModel].self, from: facultyData)
            for f in decodedData {
                faculties.append(f)
            }
        }
    }
    
    func setupSearchBar() {
        let searchbar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        searchbar.delegate = self
        self.tableView.tableHeaderView = searchbar
    }
    
    @objc func handleRefresh() {
        // Create a new URLSession
        guard let url = URL(string: API_URL) else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {return}
            if let error = error {
                print("Error", error)
                self.rControl.endRefreshing()
            }
            do {
                
                // Decode the data
                let decoder = JSONDecoder()
                let f = try decoder.decode([FacultyContactModel].self, from: data)
                
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
            catch let err {
                print("Error ", err)
                self.rControl.endRefreshing()
            }
        }
        task.resume()
        
        rControl.endRefreshing()
        
        perform(#selector(reloadTable), with: nil, afterDelay: 0.01)
        
    }
    
    @objc func reloadTable() {
        reloadTableView(tableViewToReload: tableView)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredFaculties = faculties.filter({ (mod) -> Bool in
             mod.name.lowercased().contains(searchText.lowercased())
        })
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFaculties.count == 0 ? faculties.count : filteredFaculties.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! FacultyContactCell
        let currentFaculty = filteredFaculties.count == 0 ? faculties[indexPath.row] : filteredFaculties[indexPath.row]
        cell.currentFaculty = currentFaculty
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
