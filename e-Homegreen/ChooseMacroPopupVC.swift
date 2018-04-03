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
    
    @IBOutlet weak var popUpView: UIView!
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
    
    var macroList = [Macro]()
    
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
        
        popUpView.frame = CGRect(x: 6, y: 0, width: screenWidth - 12, height: screenHeight/2.6) //3
        popUpView.center.y = self.view.center.y
        popUpView.layer.cornerRadius = 9
        popUpView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        popUpHeight = popUpView.frame.height
        popUpWidth = popUpView.frame.width
        
        setUpElementsInsidePopUp()
    }
    
    private func setUpElementsInsidePopUp() {
        
        delayLabel = UILabel()
        delayLabel.frame = CGRect(x: 8, y: 15, width: 60, height: 16)
        delayLabel.text = "Delay before running: "
        delayLabel.textColor = .white
        delayLabel.font = .tahoma(size: 15)
        
        delayHours = EditTextField()
        delayHours.frame = CGRect(x: delayLabel.frame.maxX + 5, y: 10, width: 30, height: 30)
        
        delayMinutes = EditTextField()
        delayMinutes.frame = CGRect(x: delayHours.frame.maxX + 5, y: 10, width: 30, height: 30)
        
        delaySeconds = EditTextField()
        delaySeconds.frame = CGRect(x: delayMinutes.frame.maxX + 5, y: 10, width: 30, height: 30)
        
        macroTableView = UITableView()
        macroTableView.frame = CGRect(x: 8, y: delayHours.frame.maxY + 8, width: popUpWidth - 16, height: popUpHeight - 15 - delayHours.frame.height - 8 - 31 - 3)
        macroTableView.delegate = self
        macroTableView.dataSource = self
        macroTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        confirmButton = CustomGradientButton()
        confirmButton.frame = CGRect(x: 8, y: macroTableView.frame.maxY + 8, width: popUpHeight - 16, height: 31)
        confirmButton.setTitle("ADD ACTION TO MACROS", for: UIControlState())
        confirmButton.titleLabel?.font = UIFont(name: "Tahoma", size: 14)
        
        //add to popup view
        popUpView.addSubview(delayLabel)
        popUpView.addSubview(delayHours)
        popUpView.addSubview(delayMinutes)
        popUpView.addSubview(macroTableView)
        popUpView.addSubview(confirmButton)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(30)
    }
    
}









































