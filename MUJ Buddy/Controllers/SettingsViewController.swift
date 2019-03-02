//
//  SettingsViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 3/2/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var currentSemLabel: UILabel!
    @IBOutlet weak var refreshIntervalLabel: UILabel!
    @IBOutlet weak var lowAttendanceSwitch: UISwitch!
    @IBOutlet weak var biometrySwitch: UISwitch!
    
    // Array of the whitelisted cells that should show the selection indicator
    let whitelistedCells: [IndexPath] = [
        IndexPath(row: 0, section: 2)
    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)
    }
    
    @objc fileprivate func handleBiometricAuth() {
        self.navigationController?.present(BiometricAuthController(), animated: true, completion: nil)
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
        refreshIntervalLabel.text = "\(getRefreshInterval()) Hours"
        
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
                        guard let val = tf.text, Int(val)! <= 8 && Int(val)! > 0 else { return }
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
                    refreshTF.placeholder = "Max allowed value is 24 hours"
                }
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    if let tf = alertController.textFields?.first {
                        guard let val = tf.text, Int(val)! <= 24 && Int(val)! > 0 else { return }
                        setRefreshInterval(as: Int(val)!)
                        self.refreshIntervalLabel.text = "\(val) Hours"
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
            case 2:
                let cell = tableView.cellForRow(at: indexPath)
                cell?.selectionStyle = .none
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
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 1) {
            if !canUseBiometrics() {
                return "Biometrics is unavailable on this device"
            }
            else {
                return "Require biometrics to use MUJ Buddy"
            }
        }
        
        if section == 2 {
            return "The app and it's developer"
        }
        
        return nil
    }
    
    //MARK:- Switch targets
    @objc fileprivate func handleAttendance() {
        // Set the state
        let state = lowAttendanceSwitch.isOn
        userHasAllowedNotification(value: state)
    }
    
    @objc fileprivate func handleBiometry() {
        let state = biometrySwitch.isOn
        setBiometricsState(to: state)
    }
}
