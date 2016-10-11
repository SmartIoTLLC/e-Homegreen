//
//  AddMacroActionXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class AddMacroActionXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var hoursTextField: EditTextField!
    @IBOutlet weak var minutesTextField: EditTextField!
    @IBOutlet weak var secondsTextField: EditTextField!
    
    @IBOutlet weak var macrosTableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var macros:[Macro] = []
    
    var device:Device!
    
    init(device: Device){
        super.init(nibName: "AddMacroActionXIB", bundle: nil)
        self.device = device
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.macrosTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        macros = DatabaseMacrosController.shared.getMacrosByLocation(location: device.gateway.location)
        
        if macros.count < 10{
            tableViewHeight.constant = CGFloat(macros.count * 44)
        }else{
          tableViewHeight.constant = 440
        }
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }

    @IBAction func addAction(_ sender: AnyObject) {
        
    }
}

extension AddMacroActionXIB: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.text = macros[indexPath.row].name
        cell.textLabel?.textColor = UIColor.white
        cell.accessoryType = macros[indexPath.row].isSelected ? .checkmark : .none
        cell.tintColor = UIColor.white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macros.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            macros[indexPath.row].isSelected = !macros[indexPath.row].isSelected
            if macros[indexPath.row].isSelected{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }
    }
}

extension UIViewController {
    func showAddMacroAction(device: Device){
        let addAction = AddMacroActionXIB(device: device)
        self.present(addAction, animated: true, completion: nil)
    }
}
