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
        let cell1 = MenuItems(image: "attendance_vector", title: "Attendance", subtitle: "Your Attendance")
        let cell2 = MenuItems(image: "assessment_vector", title: "Internals", subtitle: "Assessment Marks")
        let cell3 = MenuItems(image: "results_vector", title: "Results", subtitle: "Semester Results")
        let cell4 = MenuItems(image: "gpa_vector", title: "GPA", subtitle: "Your CGPA")
        let cell5 = MenuItems(image: "events_vector", title: "Events", subtitle: "At University")
        let cell6 = MenuItems(image: "announcements_vector", title: "Announcements", subtitle: "For Events")
        let cell7 = MenuItems(image: "fees_vector", title: "Fee Details", subtitle: "Paid / Unpaid")
        let cell8 = MenuItems(image: "contacts_vector", title: "Faculty Contacts", subtitle: "At University")
        return [cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8]
    }()

    // A collection view that will contain our cells with the images
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Dashboard"
        view.backgroundColor = .white
        view.snapshotView(afterScreenUpdates: true)

        // Logout button
        let btnImage = UIImage(named: "ios_more")
        let logoutButton = UIBarButtonItem(image: btnImage, style: .plain, target: self, action: #selector(handleSettingsShow))
        logoutButton.tintColor = .black
        self.navigationItem.rightBarButtonItem = logoutButton

        view.addSubview(collectionView)

        // Register the cell
        collectionView.register(DashCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView.register(DashboardHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)

        collectionView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)

        // If background service is disabled, prompt the user
        // But only once coz respect Apple Terms :P
        if UIApplication.shared.backgroundRefreshStatus == .denied && showRefreshDialog() {
            let alert = UIAlertController(title: "Auto update attendance?", message: "This app supports auto attendace updation every two hours. Please enable background app refresh to leverage that.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Sure", style: .default) { (_) in
                setShowRefreshDialog(as: false)
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alert.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Nah", style: .cancel) {(_) in
                setShowRefreshDialog(as: false)
            }
            alert.addAction(cancelAction)

            // Present the alert
            present(alert, animated: true, completion: nil)
        }
        
        if canUseBiometrics() && shouldUseBiometrics() {
            perform(#selector(handleReauth), with: self, afterDelay: 0.1)
        }
    }
    
    // Override view will disapper to remove the observer for the notification
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .didTapOnAttendanceNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .isReauthRequired, object: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DashCell
        cell.items = items[indexPath.item]
        return cell
    }
    
    //MARK:- Section header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID, for: indexPath) as! DashboardHeaderView
        
        // Add a tap recognizer
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
        
        // Get the details from remote
        Service.shared.fetchDashDetails(token: getToken()) {[unowned self] (dash, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let dash = dash {
                DispatchQueue.main.async {
                    self.dashToSend = dash
                    header.dashDetails = dash
                }
            }
        }
        
        // Finally return the header
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2
        let height = width // Maintains 1:1 ratio
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currItem = items[indexPath.item]
        let title = currItem.title
        selectAndPushViewController(using: title)
    }

    fileprivate func selectAndPushViewController(using viewControllerName: String) {
        switch viewControllerName {
        case "Attendance":
            self.navigationController?.pushViewController(AttendanceViewController(), animated: true)
            break
        case "Internals":
            self.navigationController?.pushViewController(InternalsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            break
        case "Results":
            self.navigationController?.pushViewController(ResultsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            break
        case "GPA":
            self.navigationController?.pushViewController(GPAViewController(), animated: true)
            break
        case "Events":
            self.navigationController?.pushViewController(EventsViewController(collectionViewLayout: UICollectionViewFlowLayout()), animated: true)
            break
        case "Announcements":
            let alert = showAlert(with: "Annnouncements are not available on the DMS as of now.")
            present(alert, animated: true, completion: nil)
            break
        case "Fee Details":
            self.navigationController?.pushViewController(FeesViewController(), animated: true)
            break
        case "Faculty Contacts":
            self.navigationController?.pushViewController(ContactsViewController(), animated: true)
            break
        case "StudentDetails":
            let detailedView = StudentDetailedView()
            detailedView.currentDash = dashToSend
            self.navigationController?.pushViewController(detailedView, animated: true)
            break
        default:
            break
        }
    }

    @objc fileprivate func handleLogout() {
        purgeUserDefaults()
        let dc = LoginViewController()
        dc.modalTransitionStyle = .flipHorizontal
        present(dc, animated: true, completion: nil)
    }

    @objc fileprivate func handleSettingsShow() {
        // Set the delegate and then show the settings
        // Rest everything is handled there!
        bottomSheetController.delegate = self
        bottomSheetController.showSettings()
    }

    func handleSemesterChange() {
        let alert = UIAlertController(title: "Change semester", message: "Current semester is set to: \(getSemester())", preferredStyle: .alert)
        alert.addTextField { (semTF) in
            semTF.placeholder = "Enter new semester"
            semTF.keyboardType = .numberPad
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            guard let tf = alert.textFields?.first else { return }
            let iText = Int(tf.text!) ?? -1
            if iText > 8 || iText <= 0 {
                DispatchQueue.main.async {
                    let alert = showAlert(with: "Invalid semester entered.")
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                setSemester(as: iText)
                DispatchQueue.main.async {
                    let alert = showAlert(with: "Semester updated as: \(iText). Refresh to fetch new details.")
                    self.present(alert, animated: true, completion: nil)
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
            handleLogout()
        case "Change Semester":
            handleSemesterChange()
        case "Use TouchID/FaceID Login":
            if canUseBiometrics() {
                setBiometricsState(to: !shouldUseBiometrics())
            }
            else {
                print("Unable to use biometrics: \(authError!.localizedDescription)")
                break
            }
            print("Biometric auth set to: \(shouldUseBiometrics())")
        default:
            break
        }
    }
    
    @objc fileprivate func attendanceDidTap() {
        selectAndPushViewController(using: "Attendance")
    }
    
    @objc fileprivate func handleReauth() {
        navigationController?.present(BiometricAuthController(), animated: true, completion: nil)
    }
    
    @objc fileprivate func didTapHeader() {
        selectAndPushViewController(using: "StudentDetails")
    }
}
