//
//  ContactsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class ContactsViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {

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
        NotificationCenter.default.addObserver(self, selector: #selector(triggerRefresh), name: .triggerRefresh, object: nil)
        
        let isDarkMode = UIApplication.shared.isInDarkMode
        
        searchController.searchBar.keyboardAppearance = isDarkMode ? .dark : .light
        searchController.searchBar.tintColor = isDarkMode ? .darkBarTintColor : .systemTintColor
        view.backgroundColor = isDarkMode ? .darkBackgroundColor : .primaryLighter
        tableView.backgroundColor = isDarkMode ? .darkBackgroundColor : .primaryLighter
    }
    
    @objc fileprivate func handleBiometricAuth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
        NotificationCenter.default.removeObserver(self, name: .triggerRefresh, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the views
        setupViews()
        
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
        Service.shared.getFacultyDetails(sessionID: getSessionID()) {[weak self] (faculties, reauth, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Unable to get faculty details.").show(on: self?.view)
                }
                return
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
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
        // Will be used after a trigger refresh notification is fired
        rControl.beginRefreshing()
        
        // Refresh
        Service.shared.getFacultyDetails(sessionID: getSessionID(), isRefresh: true) {[weak self] (faculties, reauth, err) in
            if err != nil {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Unable to get faculty details.").show(on: self?.view)
                }
                return
            }
            
            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
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
    
    @objc fileprivate func triggerRefresh() {
        handleRefresh()
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = UIApplication.shared.isInDarkMode ? .white : .black
        cell.detailTextLabel?.textColor = UIApplication.shared.isInDarkMode ? .darkTextPrimaryLighter : .black
        cell.backgroundColor = UIApplication.shared.isInDarkMode ? .darkBarColor : .white
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
                Toast(with: "Email not available!", color: .navyBlue).show(on: self.view)
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
        mailAction.backgroundColor = .navyBlue
        mailAction.image = UIImage(named: "ios_mail")
        return mailAction
    }
    
    // I make calls
    fileprivate func callPhone(at indexPath: IndexPath) -> UIContextualAction {
        let callAction = UIContextualAction(style: .normal, title: "Call") { (action, view, completion) in
            let phoneNumber = self.isSearching() && !self.isSearchTextEmpty() ? self.filteredFacultyDetails[indexPath.row].phone : self.facultyDetails[indexPath.row].phone
            if phoneNumber.isEmpty || phoneNumber == "NA" {
                Toast(with: "Phone not available!", color: .parrotGreen).show(on: self.view)
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
        callAction.backgroundColor = .parrotGreen
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
    
    //MARK:- Context menu interaction delegate
    @available (iOS 13.0, *)
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let identifier = NSString(string: "\(indexPath.row)")
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [unowned self] in
            let preview = FacultyContactViewController()
            preview.currentFaculty = self.facultyDetails[indexPath.row]
            return preview
        }) { (action) -> UIMenu? in
            // TODO:- Implement calling and emailing as context menu actions
            return nil
        }
    }
    
    @available (iOS 13.0, *)
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion { [unowned self] in
            guard let identifier = configuration.identifier as? String else { return }
            let currentFaculty = self.facultyDetails[Int(identifier) ?? 0]
            let destination = FacultyContactViewController()
            destination.currentFaculty = currentFaculty
            self.show(destination, sender: self)
        }
    }
}
