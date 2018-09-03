//
//  MacroDetailsTVC.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 4/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

class MacroDetailsTVC: UIViewController {
    
    var macroActions = [Macro_action]()
    var macro: Macro!
    lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DatabaseMacrosController.sharedInstance.screenWidth = UIScreen.main.bounds.width
        DatabaseMacrosController.sharedInstance.screenHeight = UIScreen.main.bounds.height
        
        setupNavigationBar()
        setupViews()
    }
    
    private func setupViews() {
        tableView.register(MacroDetailsCell.self, forCellReuseIdentifier: "macroActionCell")
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        tableView.separatorStyle = .none
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.addSubview(tableView)
    }
    
    private func setupNavigationBar() {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(deleteMacro(_:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "delete_location"), for: .normal)
        btn.sizeToFit()
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        let barButton = UIBarButtonItem(customView: btn)
        
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.title = macro.name
    }
    
    @objc func deleteMacro(_ sender: UIButton) {
        showAlertView(sender, message: "Delete \(String(describing: macro.name!)) macro, and every action inside them?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                let result = DatabaseMacrosController.sharedInstance.removeFromCD(macro: self.macro)
                print(result)
                if result == true {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
}
extension MacroDetailsTVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macroActions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "macroActionCell", for: indexPath) as? MacroDetailsCell {
            
            //Cell data
            let deviceChannel = macroActions[indexPath.row].deviceChannel as! Int
            
            cell.deviceChannel.text = "Channel \(deviceChannel)"
            cell.deviceType.text = macroActions[indexPath.row].control_type
            
            let command = Int(macroActions[indexPath.row].command!)
            switch command {
            case 0:
                cell.macroActionCommand.text = "Turn off"
            case 1:
                cell.macroActionCommand.text = "Turn on"
            default:
                cell.macroActionCommand.text = "Toggle"
            }
            
            //Cell design
            cell.backgroundColor = .clear
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.5
            cell.layer.cornerRadius = 12
            
            return cell
            
        } else {
            return UITableViewCell()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(95)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let result = DatabaseMacrosController.sharedInstance.removeFromCD(macroAction: macroActions[indexPath.row])
            if result == true {
                macroActions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    
}

