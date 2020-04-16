//
//  FacultyContactView.swift
//  MUJ Buddy
//
//  Created by Nick on 1/28/19.
//  Copyright © 2019 Nick. All rights reserved.
//

import Contacts
import UIKit

class FacultyContactViewController: UIViewController {
    var currentFaculty: FacultyContactModel? {
        didSet {
            guard let currF = currentFaculty else { return }
            nameLabel.text = currF.name
            designationLabel.text = currF.designation
            departmentLabel.text = currF.department
            phoneLabel.text = currF.phone.isEmpty ? "NA" : currF.phone
            emailLabel.text = currF.email.isEmpty ? "NA" : currF.email
            facultyImage.downloadFromURL(urlString: currF.image) { image, error in
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
        i.color = .red
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
        n.font = .titleFont
        return n
    }()

    // Designation label
    let designationLabel: UILabel = {
        let n = UILabel()
        n.textColor = .darkGray
        n.font = .titleFont
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
    let phoneLabel: UICopiableLabel = {
        let p = UICopiableLabel()
        p.text = "+91-123456789"
        p.font = .titleFont
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
    let emailLabel: UICopiableLabel = {
        let p = UICopiableLabel()
        p.text = "someone@extralongemailaddress.com"
        p.font = .titleFont
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
        p.font = .titleFont
        p.adjustsFontSizeToFitWidth = true
        return p
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(handleBiometricAuth), name: .isReauthRequired, object: nil)

        view.backgroundColor = UIColor(named: "primaryLighter")
        nameTitleView.backgroundColor = UIColor(named: "cardBackgroundColor")
        detailedView.backgroundColor = UIColor(named: "cardBackgroundColor")
        nameLabel.textColor = UIColor(named: "textPrimary")
        designationLabel.textColor = UIColor(named: "textPrimaryLighter")
        phoneLabel.textColor = UIColor(named: "textPrimary")
        emailLabel.textColor = UIColor(named: "textPrimary")
        departmentLabel.textColor = UIColor(named: "textPrimary")
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

        title = "Details"
        navigationItem.largeTitleDisplayMode = .never

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

        // MARK: - Gesture recognizers

        phoneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(callPhone)))
        phoneLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedNumber(_:))))
        emailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendEmail)))
        emailLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressedEmail(_:))))

        indicator.startAnimating()

        // MARK: - Constraints

        facultyImage.anchorWithConstraints(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, left: view.leftAnchor, height: view.frame.height / 2.5)
        indicator.centerXAnchor.constraint(equalTo: facultyImage.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: facultyImage.centerYAnchor).isActive = true

        nameTitleView.anchorWithConstraints(top: facultyImage.bottomAnchor, right: view.rightAnchor, left: view.leftAnchor)
        nameLabel.anchorWithConstraints(top: nameTitleView.topAnchor, left: nameTitleView.leftAnchor, topOffset: 14, leftOffset: 16)
        designationLabel.anchorWithConstraints(top: nameLabel.bottomAnchor, left: nameTitleView.leftAnchor, topOffset: 5, leftOffset: 16)
        designationLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 17).isActive = true

        detailedView.anchorWithConstraints(top: nameTitleView.bottomAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor, topOffset: 10)

        phoneIcon.anchorWithConstraints(top: detailedView.topAnchor, left: detailedView.leftAnchor, topOffset: 14, leftOffset: 16)
        phoneLabel.anchorWithConstraints(left: phoneIcon.rightAnchor, leftOffset: 16)
        phoneLabel.centerYAnchor.constraint(equalTo: phoneIcon.centerYAnchor).isActive = true

        emailIcon.anchorWithConstraints(top: phoneIcon.bottomAnchor, left: detailedView.leftAnchor, topOffset: 14, leftOffset: 16)
        emailLabel.anchorWithConstraints(left: emailIcon.rightAnchor, leftOffset: 16)
        emailLabel.centerYAnchor.constraint(equalTo: emailIcon.centerYAnchor).isActive = true
        emailLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 72).isActive = true

        departmentIcon.anchorWithConstraints(top: emailIcon.bottomAnchor, left: detailedView.leftAnchor, topOffset: 15, leftOffset: 16)
        departmentLabel.anchorWithConstraints(left: departmentIcon.rightAnchor, leftOffset: 16)
        departmentLabel.centerYAnchor.constraint(equalTo: departmentIcon.centerYAnchor).isActive = true
        departmentLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 72).isActive = true

        // Add the bar button item to share the contact
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ios_share"), style: .plain, target: self, action: #selector(handleContactShare))
    }

    // MARK: - OBJC Fuctions

    @objc fileprivate func callPhone() {
        if let phoneNumber = phoneLabel.text {
            if phoneNumber == "NA" {
                return
            } else {
                let phone = "tel://+91" + phoneNumber
                guard let url = URL(string: phone) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc fileprivate func longPressedNumber(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let controller = UIMenuController()
            controller.menuItems = [UIMenuItem(title: "Copy Number", action: #selector(copyNumber))]
            controller.setTargetRect(phoneLabel.bounds, in: phoneLabel)
            controller.setMenuVisible(true, animated: true)
        }
    }

    @objc fileprivate func copyNumber() {
        guard let phoneNumber = phoneLabel.text, phoneNumber != "NA" else { return }
        UIPasteboard.general.string = phoneNumber
    }

    @objc fileprivate func sendEmail() {
        if let emailAddress = emailLabel.text {
            if emailAddress == "NA" {
                return
            } else {
                let email = "mailto://" + emailAddress
                guard let url = URL(string: email) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    @objc fileprivate func longPressedEmail(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let controller = UIMenuController()
            controller.menuItems = [UIMenuItem(title: "Copy Email", action: #selector(copyEmail))]
            controller.setTargetRect(emailLabel.bounds, in: emailLabel)
            controller.setMenuVisible(true, animated: true)
        }
    }

    @objc fileprivate func copyEmail() {
        guard let email = emailLabel.text, email != "NA" else { return }
        UIPasteboard.general.string = email
    }

    // MARK: - Contacts share

    // Calls to the helper function
    @objc fileprivate func handleContactShare() {
        guard let faculty = currentFaculty else { return }
        generateVCFAndShare(faculty: faculty)
    }

    // Return a CN contact object from the passed faculty object
    fileprivate func generateCNContactFrom(faculty: FacultyContactModel) -> CNContact {
        let contact = CNMutableContact()
        contact.givenName = faculty.name
        contact.imageData = facultyImage.image?.pngData()
        contact.departmentName = faculty.department
        contact.jobTitle = faculty.designation

        // Only add the phone field if it is not empty
        if !faculty.phone.isEmpty {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: "+91-\(faculty.phone)"))]
        }

        // Only add the email field if it is not empty
        if !faculty.email.isEmpty {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: faculty.email as NSString)]
        }

        return contact
    }

    // Generats the VCF and shares the contact using UIACtivityView
    fileprivate func generateVCFAndShare(faculty: FacultyContactModel) {
        // Get the contact representation of the faculty
        let contact = generateCNContactFrom(faculty: faculty)

        // Get the cache directory URL
        guard let cahceDirectoryURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return }

        // Create the file name
        let fileName = contact.givenName.components(separatedBy: " ").joined(separator: "")

        // The URL to which we will be writing to
        let fileURL = cahceDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("vcf")

        // Create a VCF representation of the contact
        do {
            let data = try CNContactVCardSerialization.data(with: [contact])

            try data.write(to: fileURL, options: .atomicWrite)
        } catch let ex {
            print("Contact share init error: \(ex.localizedDescription)")
            return
        }

        // Now all we need to do is share the URL of the VCF file
        let shareSheet = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
}

class UICopiableLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        becomeFirstResponder()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        true
    }
}
