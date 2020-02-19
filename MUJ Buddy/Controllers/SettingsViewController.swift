//
//  SettingsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 3/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var currentSemLabel: UILabel!
    @IBOutlet weak var refreshIntervalLabel: UILabel!
    @IBOutlet weak var lowAttendanceSwitch: UISwitch!
    @IBOutlet weak var biometrySwitch: UISwitch!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var apiStatusView: UIView!
    @IBOutlet weak var dmsStatusView: UIView!
    @IBOutlet weak var notificationThreshold: UILabel!
    
    // Static custom cell weak outlets
    @IBOutlet weak var l1: UILabel!
    @IBOutlet weak var l2: UILabel!
    @IBOutlet weak var l3: UILabel!
    @IBOutlet weak var l4: UILabel!
    @IBOutlet weak var l5: UILabel!
    
    // Array of the whitelisted cells that should show the selection indicator
    let whitelistedCells: [IndexPath] = [
        IndexPath(row: 1, section: 3)
    ]
    
    var cellColor: UIColor = UIApplication.shared.isInDarkMode ? .darkCardBackgroundColor : .white
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
        
        view.backgroundColor = UIApplication.shared.isInDarkMode ? .darkBackgroundColor : .primaryLighter
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
        
        // Set the current semester from the DB
        currentSemLabel.text = "\(getSemester())"
        
        // Set the current refresh interval from the DB
        refreshIntervalLabel.text = "\(getRefreshInterval()) " + minOrMins(from: getRefreshInterval())
        
        // Set the current notification threshold from the DB
        notificationThreshold.text = "\(getNotificationThresholdFromDB()) " + hrOrHrs(from: getNotificationThresholdFromDB())
        
        // If can't use biometrics, disable the switch with an off state
        if !canUseBiometrics() {
            biometrySwitch.isOn = false
            biometrySwitch.isEnabled = false
            biometrySwitch.isUserInteractionEnabled = false
        }
        else {
            // Set the status from the prefs
            biometrySwitch.isOn = shouldUseBiometrics()
            biometrySwitch.isEnabled = true
            biometrySwitch.isUserInteractionEnabled = true
        }
        
        // Set the state of the notification switch
        lowAttendanceSwitch.isOn = userHasAllowedNotification()
        
        // Add targets to the switches
        lowAttendanceSwitch.addTarget(self, action: #selector(handleAttendance), for: .valueChanged)
        biometrySwitch.addTarget(self, action: #selector(handleBiometry), for: .valueChanged)
        
        // Configure the view
        apiStatusView.layer.cornerRadius = apiStatusView.frame.width / 2
        apiStatusView.layer.masksToBounds = true
        
        dmsStatusView.layer.cornerRadius = dmsStatusView.frame.width / 2
        dmsStatusView.layer.masksToBounds = true
        
        setupStatusIndicators()
        
        // Hide that pesky warning related to ambiguous height
        // Could have also been done by using heightForRowAtIndexPath but hey! it works :P
        self.tableView.rowHeight = 44
        
        // Set dark theme switch status based on preference
        themeSwitch.isOn = UIApplication.shared.isInDarkMode
        themeSwitch.addTarget(self, action: #selector(handleThemeSwitch), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Set the selection style as none only if the cell is not whitelisted
        if !whitelistedCells.contains(indexPath) {
            tableView.cellForRow(at: indexPath)?.selectionStyle = .none
        }
        
        // Switch the section to handle the taps as this is a static table view
        switch indexPath.section {
        // Section 0
        case 0:
            switch indexPath.row {
            case 0:
                // Show an alert controller asking for the current semester
                let alertController = UIAlertController(title: "Change Semester", message: "Please enter the new semester", preferredStyle: .alert)
                alertController.addTextField { (semTF) in
                    semTF.keyboardType = .numberPad
                    semTF.placeholder = "Max allowed value is 8"
                }
                let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
                    if let tf = alertController.textFields?.first {
                        guard tf.text != "", Int(tf.text!)! <= 8 && Int(tf.text!)! > 0 else { return }
                        let val = tf.text!
                        setSemester(as: Int(val)!)
                        self.currentSemLabel.text = val
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                navigationController?.present(alertController, animated: true, completion: {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.isSelected = false
                })
                
                break
            case 1:
                // Show an alert controller asking for the time interval
                let alertController = UIAlertController(title: "Change refresh interval", message: "Please enter the new interval value", preferredStyle: .alert)
                alertController.addTextField { (refreshTF) in
                    refreshTF.keyboardType = .numberPad
                    refreshTF.placeholder = "Max allowed value is 15 minutes"
                }
                let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] (action) in
                    if let tf = alertController.textFields?.first {
                        guard tf.text != "", Int(tf.text!)! <= 15 && Int(tf.text!)! > 0 else { return }
                        let val = tf.text!
                        setRefreshInterval(as: Int(val)!)
                        self?.refreshIntervalLabel.text = "\(val) " + (self?.minOrMins(from: Int(val)!))!
                        UIApplication.shared.setMinimumBackgroundFetchInterval(Double(val)! * 60)
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                navigationController?.present(alertController, animated: true, completion: {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.isSelected = false
                })
                
                break
            case 3:
                let tAlert = UIAlertController(title: "Set Notification Threshold", message: "Please enter the new value", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                tAlert.addAction(cancelAction)
                tAlert.addTextField { (valTF) in
                    valTF.placeholder = "Enter the value in hours"
                    valTF.keyboardType = .numberPad
                }
                let okAction = UIAlertAction(title: "OK", style: .default) {[weak self] (_) in
                    if let tf = tAlert.textFields?.first {
                        
                        guard tf.text != "", Int(tf.text!)! > 0  else { return }
                        
                        // Should not be more than a week
                        var newVal = Int(tf.text!)!
                        if (newVal > 24 * 7) {
                            newVal = 24 * 7
                        }
                        
                        setNotificationThreshold(to: newVal)
                        self?.notificationThreshold.text = "\(newVal) " + (self?.hrOrHrs(from: newVal))!
                    }
                }
                tAlert.addAction(okAction)
                present(tAlert, animated: true, completion: nil)
                
                break
            default:
                break
            }
        default:
            break
        }
        
        if indexPath == whitelistedCells[0] {
            self.navigationController?.pushViewController(AppInfoViewController(), animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = cellColor
        let color: UIColor = UIApplication.shared.isInDarkMode ? .white : .black
        cell.textLabel?.textColor = color
        cell.detailTextLabel?.textColor = color
        l1.textColor = color
        l2.textColor = color
        l3.textColor = color
        l4.textColor = color
        l5.textColor = color
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if (section == 0) {
            return "Notification threshold determines the minimum interval at which the low attendance notification should reappear."
        }
        
        if (section == 1) {
            if !canUseBiometrics() {
                return "Biometrics is unavailable on this device"
            }
            else {
                return "Require biometrics to use MUJ Buddy"
            }
        }
        
        if section == 2 {
            return "Red: Service is unavailable.\nGreen: Service is working normally.\nYellow: Checking status of the service."
        }
        
        return tableView.footerView(forSection: section)?.textLabel?.text
    }
    
    //MARK:- Switch targets
    @objc fileprivate func handleAttendance() {
        // Set the state
        let state = lowAttendanceSwitch.isOn
        userHasAllowedNotification(value: state)
    }
    
    @objc fileprivate func handleBiometry() {
        // If user is turning on the biometry for the first time ask for the re-auth
        let authContext = LAContext()
        if canUseBiometrics() {
            // Let's try the auth
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Please verify biometrics") {[weak self] (success, error) in
                if !success {
                    DispatchQueue.main.async {
                        self?.biometrySwitch.isOn = false
                    }
                    return
                }
                else {
                    DispatchQueue.main.async {
                        if let state = self?.biometrySwitch.isOn {
                            setBiometricsState(to: state)
                        }
                    }
                }
                
                if let error = error {
                    print("Biometry error: ", error.localizedDescription)
                }
            }
        }
    }
    
    //MARK:- Switch status indicator updater
    fileprivate func setupStatusIndicators() {
        
        // Send a URL request to the API and see if the service is working normally.
        getStatusFor(url: API_URL) {[weak self] (respCode) in
            DispatchQueue.main.async {
                if respCode == 200 {
                    self?.apiStatusView.animateBGColorTo(color: .green)
                }
                else {
                    self?.apiStatusView.animateBGColorTo(color: .red)
                }
            }
        }
        
        // Send a URL request to the DMS and see if the service is working normally.
        getStatusFor(url: DMS_URL) {[weak self] (respCode) in
            DispatchQueue.main.async {
                if respCode == 200 {
                    self?.dmsStatusView.animateBGColorTo(color: .green)
                }
                else {
                    self?.dmsStatusView.animateBGColorTo(color: .red)
                }
            }
        }
    }
    
    fileprivate func getStatusFor(url: String, completion: @escaping (Int) -> Void) {
        // Send a URL request and then call the completion handler closure
        URLSession.shared.dataTask(with: URL(string: url)!) { (_, response, _) in
            if let resp = response as? HTTPURLResponse {
                completion(resp.statusCode)
                return
            }
            else {
                completion(-1)
            }
        }.resume()
    }
    
    fileprivate func hrOrHrs(from value: Int) -> String {
        return value == 1 ? "Hour" : "Hours"
    }
    
    fileprivate func minOrMins(from value: Int) -> String {
        return value == 1 ? "Minute" : "Minutes"
    }
    
    @objc fileprivate func handleThemeSwitch() {
        // Theme state
        let themeState = themeSwitch.isOn
        
        // Set the state in the DB
        setDarkMode(to: themeState)
        
        // Set the theme state in UIApplication runtime variable
        UIApplication.shared.isInDarkMode = themeState
        
        if (themeState) {
            enableDarkMode()
        }
        else {
            disableDarkMode()
        }
    }
    
    fileprivate func enableDarkMode() {
        self.tableView.backgroundColor = .darkBackgroundColor
        navigationController?.navigationBar.tintColor = .darkBarTintColor
        navigationController?.navigationBar.barTintColor = .darkBarColor
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.rightBarButtonItem?.tintColor = .white
        self.navigationController?.navigationBar.barStyle = .black
        self.view.backgroundColor = .darkBackgroundColor
        self.cellColor = .darkCardBackgroundColor
        tableView.reloadData()
    }
    
    fileprivate func disableDarkMode() {
        self.tableView.backgroundColor = .primaryLighter
        navigationController?.navigationBar.tintColor = .systemTintColor
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        self.navigationController?.navigationBar.barStyle = .default
        self.view.backgroundColor = .primaryLighter
        self.cellColor = .white
        tableView.reloadData()
    }
}

extension UITableViewCell {
    static var label: UILabel?
}
