//
//  ContactsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {

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

        // Setup the views
        setupViews()
        
        // Register for 3D touch
        registerForPreviewing(with: self, sourceView: tableView)
        
        self.tableView.rowHeight = 50
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
        Service.shared.getFacultyDetails(token: getToken()) {[weak self] (faculties, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Unable to get faculty details.").show(on: self?.view)
                }
                return
            }

            if let facultie = faculties {
                for f in facultie {
                    self?.facultyDetails.append(f)
                }
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    self?.tableView.reloadData()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        print("Memory warning received.")
    }

    // MARK: - Refresh Control OBJC method
    @objc fileprivate func handleRefresh() {
        // Refresh
        Service.shared.getFacultyDetails(token: getToken(), isRefresh: true) {[weak self] (faculties, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Unable to get faculty details.").show(on: self?.view)
                }
                return
            }

            if let facultie = faculties {
                self?.facultyDetails = []
                for f in facultie {
                    self?.facultyDetails.append(f)
                }
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    self?.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching() && !isSearchTextEmpty() ? filteredFacultyDetails.count : facultyDetails.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredFacultyDetails.count == 0 ? facultyDetails[indexPath.row] : filteredFacultyDetails[indexPath.row]
        let fView = FacultyContactViewController()
        fView.currentFaculty = selectedItem
        self.navigationController?.pushViewController(fView, animated: true)
    }
    
    // For leading swipe action
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let callAction = callPhone(at: indexPath)
        return UISwipeActionsConfiguration(actions: [callAction])
    }
    
    // For trailing swipe action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let mailAction = sendMail(at: indexPath)
        return UISwipeActionsConfiguration(actions: [mailAction])
    }
    
    //MARK:- Swipe function and configs
    // I send emails
    fileprivate func sendMail(at indexpath: IndexPath) -> UIContextualAction {
        let mailAction = UIContextualAction(style: .normal, title: "E-Mail") { (action, view, completion) in
            let mailAddress = self.isSearching() && !self.isSearchTextEmpty() ? self.filteredFacultyDetails[indexpath.row].email : self.facultyDetails[indexpath.row].email
            if mailAddress.isEmpty || mailAddress == "NA" {
                Toast(with: "Email not available!", color: DMSColors.kindOfPurple.value).show(on: self.view)
                completion(true)
                return
            }
            else {
                let mailURL = URL(string: "mailto://\(mailAddress)")
                UIApplication.shared.open(mailURL!, options: [:], completionHandler: nil)
                completion(true)
            }
            completion(true)
        }
        mailAction.backgroundColor = DMSColors.kindOfPurple.value
        mailAction.image = UIImage(named: "ios_mail")
        return mailAction
    }
    
    // I make calls
    fileprivate func callPhone(at indexPath: IndexPath) -> UIContextualAction {
        let callAction = UIContextualAction(style: .normal, title: "Call") { (action, view, completion) in
            let phoneNumber = self.isSearching() && !self.isSearchTextEmpty() ? self.filteredFacultyDetails[indexPath.row].phone : self.facultyDetails[indexPath.row].phone
            if phoneNumber.isEmpty || phoneNumber == "NA" {
                Toast(with: "Phone not available!", color: DMSColors.parrotGreen.value).show(on: self.view)
                completion(true)
                return
            }
            else {
                let mailURL = URL(string: "tel://+91\(phoneNumber)")
                UIApplication.shared.open(mailURL!, options: [:], completionHandler: nil)
                completion(true)
            }
            completion(true)
        }
        callAction.backgroundColor = DMSColors.parrotGreen.value
        callAction.image = UIImage(named: "ios_phone")
        return callAction
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
        cell.textLabel?.text = isSearching() && !isSearchTextEmpty() ? filteredFacultyDetails[indexPath.row].name : facultyDetails[indexPath.row].name
        cell.detailTextLabel?.text = isSearching() && !isSearchTextEmpty() ? filteredFacultyDetails[indexPath.row].department : facultyDetails[indexPath.row].department
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - Search Controller delegate
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.isEmpty {
            // Null the array
            filteredFacultyDetails = []
        } else {
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
    
    //MARK:- Preview delegates
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        let selectedItem = filteredFacultyDetails.count == 0 ? facultyDetails[indexPath.row] : filteredFacultyDetails[indexPath.row]
        let fView = FacultyContactViewController()
        fView.currentFaculty = selectedItem
        return fView
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

}
