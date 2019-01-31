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
        a.backgroundColor = .purple
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
        
        admView.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, bottom: nil, left: view.leftAnchor, topOffset: 8, rightOffset: 8, bottomOffset: 0, leftOffset: 8, height: view.frame.height * 0.14, width: nil)
        
        collectionView.anchorWithConstraints(top: admView.bottomAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, topOffset: 0, rightOffset: 0, bottomOffset: 0, leftOffset: 0, height: nil, width: nil)
        
        nameLabel.anchorWithConstraints(top: admView.topAnchor, right: nil, bottom: nil, left: admView.leftAnchor, topOffset: 12, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        nameTF.anchorWithConstraints(top: admView.topAnchor, right: nil, bottom: nil, left: nameLabel.rightAnchor, topOffset: 12, rightOffset: 0, bottomOffset: 0, leftOffset: 4, height: nil, width: nil)
        
        programLabel.anchorWithConstraints(top: nameLabel.bottomAnchor, right: nil, bottom: nil, left: admView.leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        programTF.anchorWithConstraints(top: nameLabel.bottomAnchor, right: nil, bottom: nil, left: programLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 4, height: nil, width: nil)
        
        acadLabel.anchorWithConstraints(top: programLabel.bottomAnchor, right: nil, bottom: nil, left: admView.leftAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 16, height: nil, width: nil)
        acadTF.anchorWithConstraints(top: programLabel.bottomAnchor, right: nil, bottom: nil, left: acadLabel.rightAnchor, topOffset: 4, rightOffset: 0, bottomOffset: 0, leftOffset: 4, height: nil, width: nil)
        
        //MARK:- Fetch details from the remote
        Service.shared.fetchDashDetails(token: getToken()) { (dash, err) in
            if err != nil {
                return
            }
            
            if let dash = dash {
                DispatchQueue.main.async {
                    self.nameTF.text = dash.admDetails.name
                    self.programTF.text = dash.admDetails.program.replacingOccurrences(of: "Bachelor of", with: "B.")
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
            print("Pushing Internals")
            break
        case "Results":
            print("Pushing Results")
            break
        case "GPA":
            self.navigationController?.pushViewController(GPAViewController(), animated: true)
            break
        case "Events":
            self.navigationController?.pushViewController(EventsViewController(collectionViewLayout: UICollectionViewLayout()), animated: true)
            break
        case "Announcements":
            let alert = showAlert(with: "Annnouncements are not available on the DMS as of now.")
            present(alert, animated: true, completion: nil)
            break
        case "Fee Details":
            print("Pushing Fee Details")
            break
        case "Faculty Contacts":
            print("Pushing Faculty Contacts")
            self.navigationController?.pushViewController(ContactsViewController(), animated: true)
            break
        default:
            break
        }
    }
    
    @objc fileprivate func handleLogout() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        present(LoginViewController(), animated: true, completion: nil)
    }
}

