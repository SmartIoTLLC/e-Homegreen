//
//  ContactsListViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/22/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import Contacts

private struct LocalConstants {
    static let cellHeight: CGFloat = 60
}

class ContactsListViewController: CommonXIBTransitionVC {
    
    private let tableView: UITableView = UITableView()
    private let dismissArea: UIView = UIView()
    
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupConstraints), name: UIDevice.orientationDidChangeNotification, object: nil)

        addDismissArea()
        addTableView()
        
        setupConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func addDismissArea() {
        dismissArea.addTap {
            self.dismiss(animated: true, completion: nil)
        }
        
        view.addSubview(dismissArea)
    }
    
    private func addTableView() {
        let header           = UILabel()
        header.frame.size    = CGSize(width: tableView.frame.width, height: 60)
        header.text          = "    Contacts"
        header.font          = UIFont(name: "Tahoma", size: 25)
        header.textColor     = .white
        
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier)
        tableView.separatorInset     = .zero
        tableView.backgroundColor    = Colors.AndroidGrayColor
        tableView.separatorColor     = .clear
        tableView.layer.cornerRadius = 3
        tableView.tableHeaderView    = header
        
        view.addSubview(tableView)
    }
    
    @objc private func setupConstraints() {
        dismissArea.snp.remakeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        var height        = CGFloat(contacts.count + 1) * LocalConstants.cellHeight
        let width: CGFloat = (GlobalConstants.screenSize.width / 3) * ((UIDevice.current.userInterfaceIdiom == .phone) ? 2.5 : 1.5)
        let availableRows = round((GlobalConstants.screenSize.height - (2 * LocalConstants.cellHeight)) / LocalConstants.cellHeight )
        
        if height > (GlobalConstants.screenSize.height - (2 * LocalConstants.cellHeight)) { height = CGFloat(availableRows * 60) }
        
        tableView.snp.remakeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
    }
    
    private func updateViews() {
        contacts.sort(by: { ( $0.givenName < $1.givenName ) })
    }
    
    // MARK: - Logic
    func callContact(number: String) {
        var formattedNumber = ""
        for c in number {
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

// MARK: - Table View Data Source & Delegate
extension ContactsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier, for: indexPath) as? ContactTableViewCell {
            cell.setCell(with: contacts[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LocalConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let number = contacts[indexPath.row].phoneNumbers.first?.value.stringValue {
            self.callContact(number: number)
        }
    }
}

extension UIViewController {
    func showContactList(contacts: [CNContact]) {
        let vc = ContactsListViewController()
        vc.contacts = contacts
        self.present(vc, animated: true, completion: nil)
    }
}
