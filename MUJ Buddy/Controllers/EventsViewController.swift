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

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleEventsRefresh), name: .triggerRefresh, object: nil)

        view.backgroundColor = UIColor(named: "primaryLighter")
        collectionView.backgroundColor = UIColor(named: "primaryLighter")
        searchController.searchBar.tintColor = UIColor(named: "barTintColor")
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

        // Basic config
        navigationItem.title = "Events"
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = rControl
//        collectionView.addSubview(rControl) // This somehow works

        navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true

        // Handle rest of the config separately
        setupViews()
        rControl.addTarget(self, action: #selector(handleEventsRefresh), for: .valueChanged)
    }

    fileprivate func setupViews() {
        collectionView.register(EventsCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(indicator)

        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        indicator.startAnimating()

        // MARK: - Fetch the data

        Service.shared.fetchEvents(sessionID: getSessionID()) { [weak self] data, reauth, error in
            if error != nil {
                DispatchQueue.main.async {
                    self?.indicator.stopAnimating()
                    Toast(with: "Unable to fetch events.").show(on: self?.view)
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
                } else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = data {
                DispatchQueue.main.async {
                    for d in data {
                        self?.eventsArray.append(d)
                    }
                    self?.eventsArray.reverse() // Reverse to show events in ascending order
                    self?.indicator.stopAnimating()
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    // MARK: - Collection view delegate

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        isSearching() && !isSearchTextEmpty() ? filteredEventsArray.count : eventsArray.count
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: view.frame.width - 20, height: 100)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    // MARK: - Collection view data source

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! EventsCell
        cell.currentEvent = isSearching() && !isSearchTextEmpty() ? filteredEventsArray[indexPath.item] : eventsArray[indexPath.item]
        return cell
    }

    // MARK: - Search controller functions

    fileprivate func isSearching() -> Bool {
        searchController.isActive
    }

    fileprivate func isSearchTextEmpty() -> Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }

        if searchText.isEmpty {
            filteredEventsArray = []
        } else {
            filteredEventsArray = eventsArray.filter { (model) -> Bool in
                model.name.lowercased().contains(searchText.lowercased())
            }
        }

        perform(#selector(refreshCollectionView), with: self, afterDelay: 0.02)
    }

    // MARK: - OBJC Functions

    @objc func refreshCollectionView() {
        collectionView.reloadData()
    }

    @objc fileprivate func handleEventsRefresh() {
        // Will be used after a trigger refresh notification is fired
        rControl.beginRefreshing()

        Service.shared.fetchEvents(sessionID: getSessionID(), isRefresh: true) { [weak self] data, reauth, error in
            if error != nil {
                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    Toast(with: "Unable to fetch events.").show(on: self?.view)
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
                } else {
                    DispatchQueue.main.async {
                        self?.rControl.endRefreshing()
                        self?.indicator.stopAnimating()
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let data = data {
                self?.eventsArray = []

                for d in data {
                    self?.eventsArray.append(d)
                }

                self?.eventsArray.reverse() // Reverse to show events in ascending order

                DispatchQueue.main.async {
                    self?.rControl.endRefreshing()
                    self?.collectionView.reloadData()
                }
                return
            }
        }
    }
}
