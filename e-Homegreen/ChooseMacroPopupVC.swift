//
//  ChooseMacroVC.swift
//  e-Homegreen
//
//  When user long press on tableview cell in ScanDevicesViewController this popup is presented.
//  It is used to attach devices action to macros.
//
//  Created by Bratislav Baljak on 4/2/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit


class ChooseMacroPopupVC: PopoverVC {
    
    @IBOutlet weak var popUpView: CustomGradientBackground!
    var delayLabel: UILabel!
    var delayHours: EditTextField!
    var delayMinutes: EditTextField!
    var delaySeconds: EditTextField!
    
    var firstTwoDotsLabel: UILabel!
    var secondTwoDotsLabel: UILabel!
    
    var stateOfDeviceLabel: UILabel!
    var stateOfDeviceDropDown: CustomGradientButton!
    
    var macroTableView: UITableView!
    var cancelButton: CustomGradientButton!
    var confirmButton: CustomGradientButton!
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var popUpWidth: CGFloat!
    var popUpHeight: CGFloat!
    
    var device: Device?
    var macroList = [Macro]()
    var selectedIndexPaths = [Int]()
    var stateOfDevice: NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
        
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
        }
        setUpPopUpView()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpPopUpView() {
        
        popUpView.frame = CGRect(x: 6, y: 0, width: screenWidth - 12, height: screenHeight/1.7)
        popUpView.center.y = self.view.center.y
        popUpView.layer.cornerRadius = 9
        popUpView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        popUpHeight = popUpView.frame.height
        popUpWidth = popUpView.frame.width
        
        setUpElementsInsidePopUp()
    }
    
    private func setUpElementsInsidePopUp() {
        
        delayLabel = UILabel()
        delayLabel.frame = CGRect(x: 8, y: 17, width: 150, height: 16)
        delayLabel.text = "Delay before running: "
        delayLabel.textColor = .white
        delayLabel.font = .tahoma(size: 14)
        
        delayHours = EditTextField()
        delayHours.frame = CGRect(x: delayLabel.frame.maxX + 5, y: 10, width: 30, height: 30)
        
        firstTwoDotsLabel = UILabel()
        firstTwoDotsLabel.frame = CGRect(x: delayHours.frame.maxX + 2, y: 10, width: 3, height: 30)
        firstTwoDotsLabel.text = ":"
        firstTwoDotsLabel.textColor = .white
        
        delayMinutes = EditTextField()
        delayMinutes.frame = CGRect(x: firstTwoDotsLabel.frame.maxX + 2, y: 10, width: 30, height: 30)
        
        secondTwoDotsLabel = UILabel()
        secondTwoDotsLabel.frame = CGRect(x: delayMinutes.frame.maxX + 2, y: 10, width: 3, height: 30)
        secondTwoDotsLabel.text = ":"
        secondTwoDotsLabel.textColor = .white
        
        delaySeconds = EditTextField()
        delaySeconds.frame = CGRect(x: secondTwoDotsLabel.frame.maxX + 2, y: 10, width: 30, height: 30)
        
        stateOfDeviceLabel = UILabel()
        stateOfDeviceLabel.frame = CGRect(x: 8, y: delayHours.frame.maxY + 16, width: 150, height: 16)
        stateOfDeviceLabel.text = "Set device state:"
        stateOfDeviceLabel.textColor = .white
        stateOfDeviceLabel.font = .tahoma(size: 14)
        
        stateOfDeviceDropDown = CustomGradientButton()
        stateOfDeviceDropDown.frame = CGRect(x: delayHours.frame.minX, y: delayHours.frame.maxY + 9, width: 105, height: 30)
        stateOfDeviceDropDown.setTitle("State", for: UIControlState())
        stateOfDeviceDropDown.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        stateOfDeviceDropDown.addTarget(self, action: #selector(openStateDropDown(_:)), for: .touchUpInside)
        
        macroTableView = UITableView()
        macroTableView.frame = CGRect(x: 8, y: stateOfDeviceDropDown.frame.maxY + 6, width: popUpWidth - 16, height: popUpHeight/1.7)
        macroTableView.delegate = self
        macroTableView.dataSource = self
        macroTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        macroTableView.backgroundColor = .clear
        macroTableView.separatorStyle = .singleLine

        cancelButton = CustomGradientButton()
        cancelButton.frame = CGRect(x: 8, y: popUpHeight - 31 - 8, width: (popUpWidth/2) - 8 - 4, height: 31)
        cancelButton.setTitle("CANCEL", for: UIControlState())
        cancelButton.titleLabel?.font = UIFont(name: "Tahoma", size: 11)
        cancelButton.addTarget(self, action: #selector(cancel(_:)), for: .touchUpInside)
        
        confirmButton = CustomGradientButton()
        confirmButton.frame = CGRect(x: cancelButton.frame.maxX + 8, y: popUpHeight - 31 - 8, width:  (popUpWidth/2) - 8 - 4, height: 31)
        confirmButton.setTitle("ADD ACTION TO MACROS", for: UIControlState())
        confirmButton.titleLabel?.font = UIFont(name: "Tahoma", size: 11)
        confirmButton.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        
        
        //add to popup view
        popUpView.addSubview(delayLabel)
        popUpView.addSubview(delayHours)
        popUpView.addSubview(firstTwoDotsLabel)
        popUpView.addSubview(delayMinutes)
        popUpView.addSubview(secondTwoDotsLabel)
        popUpView.addSubview(delaySeconds)
        popUpView.addSubview(stateOfDeviceLabel)
        popUpView.addSubview(stateOfDeviceDropDown)
        popUpView.addSubview(macroTableView)
        popUpView.addSubview(cancelButton)
        popUpView.addSubview(confirmButton)
    }
    
    @objc func submit(_ sender: UIButton) {
        
        var macroListForAction = [Macro]()
        for index in selectedIndexPaths {
            macroListForAction.append(macroList[index])
            print(macroList[index].name)
        }
        
        if stateOfDevice == nil || macroListForAction.count == 0 {
            return
        }
        
        for oneMacro in macroListForAction {
             DatabaseMacrosController.sharedInstance.addActionToMacros(command: stateOfDevice!, control_type: (device?.controlType)!, delay: 0, deviceAddress: (device?.address)!, gatewayAddressOne: (device?.gateway.addressOne)!, gatewayAddressTwo: (device?.gateway.addressTwo)!, deviceChannel: (device?.channel)!, macro: oneMacro)
        }
       
        
        DatabaseMacrosController.sharedInstance.fetchMacroActionsFor(macro: macroList[0])
        DatabaseMacrosController.sharedInstance.fetchMacroActionsFor(macro: macroList[1])
        DatabaseMacrosController.sharedInstance.fetchMacroActionsFor(macro: macroList[2])

        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openStateDropDown(_ sender: UIButton) {
        var popOverList: [PopOverItem] = []
        
        popOverList.append(PopOverItem(name: "Turn on", id: "1"))
        popOverList.append(PopOverItem(name: "Turn off", id: "0"))
        popOverList.append(PopOverItem(name: "Toggle", id: "2"))
        
        if let vc = popUpView.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList: popOverList) } else { print ("unable to present pop up in ChooseMacroPopUpVC") }
    }
    
    override func nameAndId(_ name: String, id: String) {
        stateOfDevice = Int16(id) as! NSNumber
        stateOfDeviceDropDown.setTitle(name, for: UIControlState())
    }
    

}

extension ChooseMacroPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macroList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = macroList[indexPath.row].name
        cell.textLabel?.font = .tahoma(size: 14)
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            selectedIndexPaths = selectedIndexPaths.filter({$0 != indexPath.row})
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            selectedIndexPaths.append(indexPath.row)
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
    }
    
    
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.lightGray
//        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.lightGray
//
//    }
    
//    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = .red
//        tableView.cellForRow(at: indexPath)?.backgroundColor = .clear
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(60)
    }
    
}









































