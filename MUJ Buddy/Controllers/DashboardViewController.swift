//
//  DashboardViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, BottomSheetDelegate {
    let cellId = "cellID"
    let headerID = "headerID"
    var dashToSend: DashboardModel?

    let items: [MenuItems] = {
        let cell1 = MenuItems(image: "attendance_vector", title: "Attendance")
        let cell2 = MenuItems(image: "assessment_vector", title: "Internals")
        let cell3 = MenuItems(image: "results_vector", title: "Results")
        let cell4 = MenuItems(image: "gpa_vector", title: "GPA")
        let cell5 = MenuItems(image: "events_vector", title: "Events")
        let cell6 = MenuItems(image: "announcements_vector", title: "Notifications")
        let cell7 = MenuItems(image: "fees_vector", title: "Fee Details")
        let cell8 = MenuItems(image: "contacts_vector", title: "Contacts")
        return [cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8]
    }()

    let colors: [[UIColor]] = {
        [
            [#colorLiteral(red: 0.9654200673, green: 0.1590853035, blue: 0.2688751221, alpha: 1), #colorLiteral(red: 0.7559037805, green: 0.1139892414, blue: 0.1577021778, alpha: 1)],
            [#colorLiteral(red: 0.9338900447, green: 0.4315618277, blue: 0.2564975619, alpha: 1), #colorLiteral(red: 0.8518816233, green: 0.1738803983, blue: 0.01849062555, alpha: 1)],
            [#colorLiteral(red: 0.9953531623, green: 0.54947716, blue: 0.1281470656, alpha: 1), #colorLiteral(red: 0.9409626126, green: 0.7209432721, blue: 0.1315650344, alpha: 1)],
            [#colorLiteral(red: 0.3796315193, green: 0.7958304286, blue: 0.2592983842, alpha: 1), #colorLiteral(red: 0.2060100436, green: 0.6006633639, blue: 0.09944178909, alpha: 1)],
            [#colorLiteral(red: 0.2761503458, green: 0.824685812, blue: 0.7065336704, alpha: 1), #colorLiteral(red: 0, green: 0.6422213912, blue: 0.568986237, alpha: 1)],
            [#colorLiteral(red: 0.4613699913, green: 0.3118675947, blue: 0.8906354308, alpha: 1), #colorLiteral(red: 0.3018293083, green: 0.1458326578, blue: 0.7334778905, alpha: 1)],
            [#colorLiteral(red: 0.7080290914, green: 0.3073516488, blue: 0.8653779626, alpha: 1), #colorLiteral(red: 0.5031493902, green: 0.1100070402, blue: 0.6790940762, alpha: 1)],
            [#colorLiteral(red: 0.9495453238, green: 0.4185881019, blue: 0.6859942079, alpha: 1), #colorLiteral(red: 0.8123683333, green: 0.1657164991, blue: 0.5003474355, alpha: 1)],
        ]
    }()

    // A collection view that will contain our cells with the images
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(named: "primaryLighter")
        cv.dataSource = self
        cv.delegate = self
        cv.showsVerticalScrollIndicator = false // Gande ho ji tum
        return cv
    }()

    // Settings collection view
    let bottomSheetController = BottomMenuSheetController()

    // Override view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Add observer for notification tap
        NotificationCenter.default.addObserver(self, selector: #selector(attendanceDidTap), name: .didTapOnAttendanceNotification, object: nil)

        // Add observer for biometry
        NotificationCenter.default.addObserver(self, selector: #selector(handleReauth), name: .isReauthRequired, object: nil)

        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "textPrimary")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(named: "primaryLighter")
        view.snapshotView(afterScreenUpdates: true)
        setNeedsStatusBarAppearanceUpdate()

        // Logout button
        let btnImage = UIImage(named: "ios_more")
        let logoutButton = UIBarButtonItem(image: btnImage, style: .plain, target: self, action: #selector(handleSettingsShow))
        navigationItem.rightBarButtonItem = logoutButton

        view.addSubview(collectionView)

        // Register the cell
        collectionView.register(DashCell.self, forCellWithReuseIdentifier: cellId)

        collectionView.register(DashboardHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)

        collectionView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, topOffset: 10)

        // If background service is disabled, prompt the user
        // But only once coz respect Apple Terms :P
        if UIApplication.shared.backgroundRefreshStatus == .denied, showRefreshDialog() {
            let alert = UIAlertController(title: "Auto update attendance?", message: "This app supports auto attendace updation every two hours. Please enable background app refresh to leverage that.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure", style: .default) { _ in
                setShowRefreshDialog(as: false)
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Nah", style: .cancel) { _ in
                setShowRefreshDialog(as: false)
            }
            alert.addAction(cancelAction)

            // Present the alert
            present(alert, animated: true, completion: nil)
        }

        if canUseBiometrics(), shouldUseBiometrics() {
            perform(#selector(handleReauth), with: self, afterDelay: 0.1)
        }
    }

    // Override view will disapper to remove the observer for the notification
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: .didTapOnAttendanceNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DashCell
        cell.items = items[indexPath.item]
        let gradientColor = indexPath.row > colors.count - 1 ? colors[0] : colors[indexPath.row]
        cell.linearGradient(from: gradientColor[0], to: gradientColor[1])
        return cell
    }

    // MARK: - Section header

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind _: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID, for: indexPath) as! DashboardHeaderView

        // Add a tap recognizer
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))

        // Get the details from remote
        Service.shared.fetchDashDetails(sessionID: getSessionID()) { [weak self] dash, reauth, err in
            if let err = err {
                print(err)
                return
            }

            if let eMsg = reauth {
                if eMsg.error == LOGIN_FAILED {
                    // Time to present the OTP controller for the reauth
                    DispatchQueue.main.async {
                        self?.present(LoginViewController(), animated: true, completion: {
                            NotificationCenter.default.post(name: .sessionExpired, object: nil, userInfo: [:])
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        Toast(with: eMsg.error).show(on: self?.view)
                    }
                }
            }

            if let dash = dash {
                DispatchQueue.main.async {
                    self?.dashToSend = dash
                    header.dashDetails = dash
                }
            }
        }

        // Finally return the header
        return header
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection _: Int) -> CGSize {
        CGSize(width: view.frame.width, height: view.frame.height * 0.18)
    }

    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width / 2) - 16
        let height = width // Maintains 1:1 ratio
        return CGSize(width: width, height: height)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        0
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        10
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currItem = items[indexPath.item]
        let title = currItem.title
        selectAndPushViewController(using: title)
    }

    fileprivate func selectAndPushViewController(using viewControllerName: String) {
        switch viewControllerName {
        case "Attendance":
            navigationController?.pushViewController(AttendanceViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        case "Internals":
            navigationController?.pushViewController(InternalsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        case "Results":
            navigationController?.pushViewController(ResultsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        case "GPA":
            navigationController?.pushViewController(GPAViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        case "Events":
            navigationController?.pushViewController(EventsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
        case "Notifications":
            Toast(with: "Notifications not available").show(on: view)
        case "Fee Details":
            navigationController?.pushViewController(FeesViewController(), animated: true)
        case "Contacts":
            navigationController?.pushViewController(ContactsViewController(), animated: true)
        case "StudentDetails":
            let detailedView = StudentDetailedView()
            detailedView.currentDash = dashToSend
            navigationController?.pushViewController(detailedView, animated: true)
        default:
            break
        }
    }

    @objc fileprivate func handleLogout() {
        purgeUserDefaults()
        let dc = LoginViewController()
        dc.modalTransitionStyle = .flipHorizontal
        dc.modalPresentationStyle = .fullScreen
        present(dc, animated: true) {
            self.removeFromParent()
        }
    }

    @objc fileprivate func handleSettingsShow() {
        // Set the delegate and then show the settings
        // Rest everything is handled there!
        bottomSheetController.delegate = self
        bottomSheetController.showSettings()
    }

    func handleSemesterChange() {
        let alert = UIAlertController(title: "Change semester", message: "Current semester is set to: \(getSemester())", preferredStyle: .alert)
        alert.addTextField { semTF in
            semTF.placeholder = "Enter new semester"
            semTF.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let tf = alert.textFields?.first else { return }
            let iText = Int(tf.text!) ?? -1
            if iText > 8 || iText <= 0 {
                DispatchQueue.main.async {
                    Toast(with: "Invalid semester entered.").show(on: self?.view)
                }
            } else {
                setSemester(as: iText)
                DispatchQueue.main.async {
                    Toast(with: "Semester updated", color: .parrotGreen).show(on: self?.view)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Delegate method

    func handleMenuSelect(forItem: String) {
        switch forItem {
        case "Logout":
            // Ask the user if he/she really wants to logout
            let confirmAlert = UIAlertController(title: "Are you sure?", message: "Logging out will clear all user data.", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.handleLogout()
            }
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            confirmAlert.addAction(okAction)
            confirmAlert.addAction(cancelAction)
            navigationController?.present(confirmAlert, animated: true, completion: nil)
        case "Change Semester":
            handleSemesterChange()
        case "Use TouchID/FaceID Login":
            if canUseBiometrics() {
                setBiometricsState(to: !shouldUseBiometrics())
            } else {
                print("Unable to use biometrics: \(authError!.localizedDescription)")
                break
            }
            print("Biometric auth set to: \(shouldUseBiometrics())")
        case "Settings":
            let vc = UIStoryboard(name: "Settings", bundle: nil)
            let svc = vc.instantiateViewController(withIdentifier: "settingsSB")
            navigationController?.pushViewController(svc, animated: true)
        default:
            break
        }
    }

    @objc fileprivate func attendanceDidTap() {
        selectAndPushViewController(using: "Attendance")
    }

    @objc fileprivate func handleReauth() {
        takeBiometricAction(navController: navigationController ?? UINavigationController(rootViewController: self))
    }

    @objc fileprivate func didTapHeader() {
        selectAndPushViewController(using: "StudentDetails")
    }
}
