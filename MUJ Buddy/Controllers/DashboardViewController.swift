//
//  DashboardViewController.swift
//  MUJ Buddy
//
//  Created by Nick on 1/22/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    
    let cellId = "cellID"
    
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
    
    // Create a view to contain the
    let admView: UIView = {
        let a = UIView()
        a.backgroundColor = DMSColors.kindOfPurple.value
        return a
    }()
    
    // Name
    let nameLabel: UILabel = {
        let n = UILabel()
        n.text = "Name: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let nameTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        return  n
    }()
    
    // Program
    let programLabel: UILabel = {
        let n = UILabel()
        n.text = "Program: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let programTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        n.lineBreakMode = .byTruncatingTail
        return  n
    }()
    
    // Acad Year
    let acadLabel: UILabel = {
        let n = UILabel()
        n.text = "Acad Year: "
        n.textColor = .white
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return  n
    }()
    
    let acadTF: UILabel = {
        let n = UILabel()
        n.text = "Loading..."
        n.textColor = .white
        return  n
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Dashboard"
        view.backgroundColor = .white
        
        // Logout button
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.rightBarButtonItem = logoutButton
        
        view.addSubview(admView)
        view.addSubview(collectionView)
        
        admView.addSubview(nameLabel)
        admView.addSubview(nameTF)
        admView.addSubview(programLabel)
        admView.addSubview(programTF)
        admView.addSubview(acadLabel)
        admView.addSubview(acadTF)
        
        
        // Register the cell
        collectionView.register(DashCell.self, forCellWithReuseIdentifier: cellId)
        
        admView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, topOffset: 8, rightOffset: 8, leftOffset: 8, height: 90)
        
        collectionView.anchorWithConstraints(top: admView.bottomAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor)
        
        nameLabel.anchorWithConstraints(top: admView.topAnchor, left: admView.leftAnchor, topOffset: 12, leftOffset: 10)
        nameTF.anchorWithConstraints(top: admView.topAnchor, left: nameLabel.rightAnchor, topOffset: 12, leftOffset: 4)
        
        programLabel.anchorWithConstraints(top: nameLabel.bottomAnchor, left: admView.leftAnchor, topOffset: 4, leftOffset: 10)
        programTF.anchorWithConstraints(top: nameLabel.bottomAnchor, left: programLabel.rightAnchor, topOffset: 4, leftOffset: 4)
        
        acadLabel.anchorWithConstraints(top: programLabel.bottomAnchor, left: admView.leftAnchor, topOffset: 4, leftOffset: 10)
        acadTF.anchorWithConstraints(top: programLabel.bottomAnchor, left: acadLabel.rightAnchor, topOffset: 4, leftOffset: 4)
        
        //MARK:- Fetch details from the remote
        Service.shared.fetchDashDetails(token: getToken()) { (dash, err) in
            if err != nil {
                return
            }
            
            if let dash = dash {
                DispatchQueue.main.async {
                    self.nameTF.text = dash.admDetails.name
                    self.programTF.text = dash.admDetails.program.replacingOccurrences(of: "Bachelor of", with: "B.").replacingOccurrences(of: "Applications", with: "App.")
                    self.acadTF.text = dash.admDetails.acadYear
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DashCell
        cell.items = items[indexPath.item]
        return cell
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
}

