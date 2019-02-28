//
//  TodayViewController.swift
//  Attendance Widget
//
//  Created by Nick on 2/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First off we need to check if the user is logged in
        if !isLoggedIn() {
            statusLabel.text = "Have a nice day"
            statusImage.image = UIImage(named: "mu_logo")
            return
        }
        
        // Else, we will update the views
        updateWidget { (_) in }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        if isLoggedIn() {
            updateWidget { (result) in
                completionHandler(result)
            }
        }
    }
    
    fileprivate func updateWidget(withCompletionHandler: ((NCUpdateResult) -> Void)) {
        // If user is logged in but attendance is not fetched from the API, return
        if getAttendanceFromDB() == nil {
            withCompletionHandler(.noData)
            return
        }
        
        // Else, get the low attendance count
        let attendanceCount = getLowAttendanceCount()
        
        // If attendance is low, we need to set the values accordingly
        if attendanceCount > 0 {
            statusLabel.text = "Attendance low in \(attendanceCount) sub(s)"
            statusImage.image = UIImage(named: "sad")?.withRenderingMode(.alwaysTemplate)
            statusImage.tintColor = .red
            withCompletionHandler  (.newData)
        }
        else {
            statusLabel.text = "No worries for attendance"
            statusImage.image = UIImage(named: "happy")?.withRenderingMode(.alwaysTemplate)
            statusImage.tintColor = UIColor(r: 0, g: 100, b: 0)
            withCompletionHandler(.newData)
        }
    }
    
}
