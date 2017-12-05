//
//  ContactsListViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/22/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import Contacts

class ContactsListViewController: CommonXIBTransitionVC, UITableViewDataSource, UITableViewDelegate {
    
    let cellId = "contactCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tapBG: UIView!
    
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewConstraints), name: .UIDeviceOrientationDidChange, object: nil)

        setupViews()
        updateViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }

    func callContact(number: String) {
        var formattedNumber = ""
        for c in number.characters {
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(c) {
                formattedNumber += String(describing: c)
            }
        }
        if let num = URL(string: "tel:\(formattedNumber)") {
            UIApplication.shared.open(num, options: [:], completionHandler: { (bool) in
                if bool {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
}

// MARK: - Table View Data Source
extension ContactsListViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ContactCell {
            
            cell.contact = contacts[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Table View Delegate
extension ContactsListViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let number = contacts[indexPath.row].phoneNumbers.first?.value.stringValue {
            self.callContact(number: number)
        }
    }
}

// MARK: - Setup views
extension ContactsListViewController {
    func dismissOnTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupViews() {
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: ContactCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        
        tapBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissOnTap)))
    }
    
    fileprivate func updateViews() {
        tapBG.backgroundColor = .clear
        
        let header           = UILabel()
        header.frame.size    = CGSize(width: tableView.frame.width, height: 60)
        header.text          = "    Contacts"
        header.font          = UIFont(name: "Tahoma", size: 25)
        header.textColor     = .white
        
        view.backgroundColor = .clear
        
        updateTableViewConstraints()
        
        tableView.separatorInset     = .zero
        tableView.backgroundColor    = Colors.AndroidGrayColor
        tableView.separatorColor     = .clear
        tableView.layer.cornerRadius = 3
        tableView.tableHeaderView    = header
        contacts = contacts.sorted(by: { ( $0.givenName < $1.givenName) })
        tableView.reloadData()
    }
    
    @objc fileprivate func updateTableViewConstraints() {
        
        var height        = CGFloat((contacts.count + 1) * 60)
        let availableRows = round((view.frame.height - 60) / 60) - 1
        
        if height > view.frame.height - 60 { height = CGFloat(availableRows * 60) }
        
        tableViewHeightConstraint.constant = height
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            tableViewWidthConstraint.constant = (UIScreen.main.bounds.width / 3) * 2.5
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            tableViewWidthConstraint.constant = (UIScreen.main.bounds.width / 3) * 1.5
        }
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.layoutIfNeeded()
    }
}

extension UIViewController {
    func showContactList(contacts: [CNContact]) {
        let vc = ContactsListViewController()
        vc.contacts = contacts
        self.present(vc, animated: true, completion: nil)
    }
}
