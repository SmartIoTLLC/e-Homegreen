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
    
    var macroTableView: UITableView!
    var confirmButton: CustomGradientButton!
    
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var popUpWidth: CGFloat!
    var popUpHeight: CGFloat!
    
    var device: Device?
    var macroList = [Macro]()
    var selectedIndexPaths = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenWidth = UIScreen.main.bounds.width
        self.screenHeight = UIScreen.main.bounds.height
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
        }
        setUpPopUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpPopUpView() {
        
        popUpView.frame = CGRect(x: 6, y: 0, width: screenWidth - 12, height: screenHeight/2.1) //3
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
        
        macroTableView = UITableView()
        macroTableView.frame = CGRect(x: 8, y: delayHours.frame.maxY + 8, width: popUpWidth - 16, height: popUpHeight/1.7)
        macroTableView.delegate = self
        macroTableView.dataSource = self
        macroTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        macroTableView.backgroundColor = .clear
        macroTableView.separatorStyle = .singleLine

        confirmButton = CustomGradientButton()
        confirmButton.frame = CGRect(x: 8, y: popUpHeight - 31 - 8, width: popUpWidth - 16, height: 31)
        confirmButton.setTitle("ADD ACTION TO MACROS", for: UIControlState())
        confirmButton.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        confirmButton.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
        
        //add to popup view
        popUpView.addSubview(delayLabel)
        popUpView.addSubview(delayHours)
        popUpView.addSubview(firstTwoDotsLabel)
        popUpView.addSubview(delayMinutes)
        popUpView.addSubview(secondTwoDotsLabel)
        popUpView.addSubview(delaySeconds)
        popUpView.addSubview(macroTableView)
        popUpView.addSubview(confirmButton)
    }
    
    @objc func submit(_ sender: UIButton) {
        let action = Macro_action()
        action.command = 100
        action.control_type = 1
        action.gatewayId = "gejtvej"
       
        if DatabaseMacrosController.sharedInstance.addActionToMacros(action: action, macro: macroList.first!) == true {
            print("uspeh")
        }
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









































