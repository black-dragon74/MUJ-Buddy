//
//  FacultyContactView.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import UIKit

class FacultyContactView: UIViewController {
    
    var currentFaculty: FacultyContactModel? {
        didSet {
            guard let currF = currentFaculty else { return }
            nameLabel.text = currF.name
            designationLabel.text = currF.designation
            departmentLabel.text = currF.department
            phoneLabel.text = currF.phone.isEmpty ? "NA" : currF.phone
            emailLabel.text = currF.email.isEmpty ? "NA" : currF.email
            facultyImage.downloadFromURL(urlString: currF.image) { (image, error) in
                if let error = error {
                    self.indicator.stopAnimating()
                    print("Error in getting Image: ", error)
                    return
                }
                
                if let image = image {
                    DispatchQueue.main.async {
                        self.facultyImage.image = image
                        self.indicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    // Activity Indicator
    let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView()
        i.hidesWhenStopped = true
        i.translatesAutoresizingMaskIntoConstraints = false
        i.style = .whiteLarge
        i.color = .orange
        return i
    }()
    
    // Faculty Image
    let facultyImage: UIImageView = {
        let f = UIImageView()
        f.contentMode = .scaleAspectFill
        f.clipsToBounds = true
        f.backgroundColor = .clear
        return f
    }()
    
    // View that contains name and title
    let nameTitleView: UIView = {
        let d = UIView()
        d.backgroundColor = .white
        d.heightAnchor.constraint(equalToConstant: 70).isActive = true
        return d
    }()
    
    // Name label
    let nameLabel: UILabel = {
        let n = UILabel()
        n.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return n
    }()
    
    // Designation label
    let designationLabel: UILabel = {
        let n = UILabel()
        n.textColor = .darkGray
        n.adjustsFontSizeToFitWidth = true
        return n
    }()
    
    // View that contains rest of the things
    let detailedView: UIView = {
        let d = UIView()
        d.backgroundColor = .white
        return d
    }()
    
    // Phone Icon
    let phoneIcon: UIImageView = {
        let p = UIImageView()
        p.contentMode = .scaleAspectFill
        p.clipsToBounds = true
        p.heightAnchor.constraint(equalToConstant: 40).isActive = true
        p.widthAnchor.constraint(equalToConstant: 40).isActive = true
        p.image = UIImage(named: "phone")
        return p
    }()
    
    // Phone Label
    let phoneLabel: UILabel = {
        let p = UILabel()
        p.text = "+91-123456789"
        p.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        p.isUserInteractionEnabled = true
        return p
    }()
    
    // Email Icon
    let emailIcon: UIImageView = {
        let p = UIImageView()
        p.contentMode = .scaleAspectFill
        p.clipsToBounds = true
        p.heightAnchor.constraint(equalToConstant: 40).isActive = true
        p.widthAnchor.constraint(equalToConstant: 40).isActive = true
        p.image = UIImage(named: "email")
        return p
    }()
    
    // Email Label
    let emailLabel: UILabel = {
        let p = UILabel()
        p.text = "someone@extralongemailaddress.com"
        p.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        p.adjustsFontSizeToFitWidth = true
        p.isUserInteractionEnabled = true
        return p
    }()
    
    // Department Icon
    let departmentIcon: UIImageView = {
        let p = UIImageView()
        p.contentMode = .scaleAspectFill
        p.clipsToBounds = true
        p.heightAnchor.constraint(equalToConstant: 40).isActive = true
        p.widthAnchor.constraint(equalToConstant: 40).isActive = true
        p.image = UIImage(named: "work")
        return p
    }()
    
    // Department Label
    let departmentLabel: UILabel = {
        let p = UILabel()
        p.text = "Dept. of science and what not"
        p.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        p.adjustsFontSizeToFitWidth = true
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 243/255, alpha: 1)
        self.title = "Details"
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        view.addSubview(facultyImage)
        facultyImage.addSubview(indicator)
        
        
        view.addSubview(nameTitleView)
        nameTitleView.addSubview(nameLabel)
        nameTitleView.addSubview(designationLabel)
        
        
        view.addSubview(detailedView)
        detailedView.addSubview(phoneIcon)
        detailedView.addSubview(phoneLabel)
        detailedView.addSubview(emailIcon)
        detailedView.addSubview(emailLabel)
        detailedView.addSubview(departmentIcon)
        detailedView.addSubview(departmentLabel)
        
        //MARK:- Gesture recognizers
        phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callPhone)))
        emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendEmail)))
        
        
        indicator.startAnimating()
        
        //MARK:- Constraints
        facultyImage.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, height: view.frame.height / 2.5)
        indicator.centerXAnchor.constraint(equalTo: facultyImage.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: facultyImage.centerYAnchor).isActive = true
        
        nameTitleView.anchorWithConstraints(top: facultyImage.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor)
        nameLabel.anchorWithConstraints(top: nameTitleView.topAnchor, left: nameTitleView.leftAnchor, topOffset: 14, leftOffset: 16)
        designationLabel.anchorWithConstraints(top: nameLabel.bottomAnchor, left: nameTitleView.leftAnchor, topOffset: 5, leftOffset: 16)
        designationLabel.widthAnchor.constraint(equalToConstant: (view.frame.width - 17)).isActive = true
        
        detailedView.anchorWithConstraints(top: nameTitleView.bottomAnchor, right: view.rightAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, topOffset: 10)
        
        phoneIcon.anchorWithConstraints(top: detailedView.topAnchor, left: detailedView.leftAnchor, topOffset: 14, leftOffset: 16)
        phoneLabel.anchorWithConstraints(left: phoneIcon.rightAnchor, leftOffset: 16)
        phoneLabel.centerYAnchor.constraint(equalTo: phoneIcon.centerYAnchor).isActive = true
        
        emailIcon.anchorWithConstraints(top: phoneIcon.bottomAnchor, left: detailedView.leftAnchor, topOffset: 14, leftOffset: 16)
        emailLabel.anchorWithConstraints(left: emailIcon.rightAnchor, leftOffset: 16)
        emailLabel.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: (view.frame.width - 72)).isActive = true
        
        departmentIcon.anchorWithConstraints(top: emailIcon.bottomAnchor, left: detailedView.leftAnchor, topOffset: 15, leftOffset: 16)
        departmentLabel.anchorWithConstraints(left: departmentIcon.rightAnchor, leftOffset: 16)
        departmentLabel.centerYAnchor.constraint(equalTo: departmentIcon.centerYAnchor).isActive = true
        departmentLabel.widthAnchor.constraint(equalToConstant: (view.frame.width - 72)).isActive = true
        
    }
    
    //MARK:- OBJC Fuctions
    @objc func callPhone() {
        if let phoneNumber = phoneLabel.text {
            if phoneNumber == "NA"{
                return
            }
            else {
                let phone = "tel://+91" + phoneNumber
                guard let url = URL(string: phone) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func sendEmail() {
        if let emailAddress = emailLabel.text {
            if emailAddress == "NA"{
                return
            }
            else {
                let email = "mailto://" + emailAddress
                guard let url = URL(string: email) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

//MARK:- Extensions for Image View
extension UIImageView {
    func downloadFromURL(urlString: String, completion: @escaping(UIImage?, Error?) -> Void) {
        let escapedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: escapedURL!) else { return }
        
        URLSession.shared.dataTask(with: url) {(data, status, error) in
            if let error = error {
                print(error)
                completion(nil, error)
                return
            }
            
            if let data = data {
                let image = UIImage(data: data)
                completion(image, nil)
                return
            }
            }.resume()
    }
}
