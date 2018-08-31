//
//  MacroDetailsTVC.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 4/11/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit

//protocol SuccessfullyDeletedMacroDelegate {
//    func refreshMacroVC()
//}

class MacroDetailsTVC: UITableViewController {
    
    var macroActions = [Macro_action]()
    var macro: Macro!
    
    //var macroDelegate: SuccessfullyDeletedMacroDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DatabaseMacrosController.sharedInstance.screenWidth = UIScreen.main.bounds.width
        DatabaseMacrosController.sharedInstance.screenHeight = UIScreen.main.bounds.height
        
        let btn = UIButton.init()
        btn.addTarget(self, action: #selector(deleteMacro(_:)), for: .touchUpInside)
        btn.setImage(#imageLiteral(resourceName: "delete_location"), for: .normal)
        btn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        let barButton = UIBarButtonItem(customView: btn)
        
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.title = macro.name
        
        tableView.register(MacroDetailsCell.self, forCellReuseIdentifier: "macroActionCell")
        tableView.backgroundView = UIImageView(image: #imageLiteral(resourceName: "Background"))
        tableView.separatorStyle = .none
        
        
    }
    
    @objc func deleteMacro(_ sender: UIButton) {
        showAlertView(sender, message: "Delete \(String(describing: macro.name!)) macro, and every action inside them?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                let result = DatabaseMacrosController.sharedInstance.removeFromCD(macro: self.macro)
                print(result)
                if result == true {
                    self.navigationController?.popViewController(animated: true)
                    //self.macroDelegate?.refreshMacroVC()
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macroActions.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(95)
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let result = DatabaseMacrosController.sharedInstance.removeFromCD(macroAction: macroActions[indexPath.row])
            if result == true {
                macroActions.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    
    
}
