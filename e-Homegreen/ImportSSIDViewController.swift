//
//  ImportSSIDViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class ImportSSIDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var ssidList:[SSID] = []
    var location:Location?
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    @IBOutlet weak var ssidNameTextfield: UITextField!
    
    @IBOutlet weak var ssidTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
        updateSSID()
    }
    
    func setupViews() {
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        ssidNameTextfield.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateSSID(){
        if let location = location{
            if let list = location.ssids?.allObjects as? [SSID]{
                ssidList = list.sorted(by: { (first, second) -> Bool in
                    return first.name < second.name
                })
            }
        }
        ssidTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ssidCell") as? SSIDCell {
            
            cell.setItem(ssidList[indexPath.row])
            
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ssidList.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showAlertView(tableView, message: "Delete SSID?", completion: { (action) in
                if action == ReturnedValueFromAlertView.delete {
                    self.appDel.managedObjectContext?.delete(self.ssidList[indexPath.row])
                    CoreDataController.sharedInstance.saveChanges()
                    self.updateSSID()
                }
            })
        }
    }

    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addSSID(_ sender: AnyObject) {
        guard let name = ssidNameTextfield.text , name != "" else { return }
        
        if let location = location {
            if let ssid = NSEntityDescription.insertNewObject(forEntityName: "SSID", into: appDel.managedObjectContext!) as? SSID {
                ssid.name = name
                ssid.location = location
                CoreDataController.sharedInstance.saveChanges()
                self.updateSSID()
                ssidNameTextfield.text = ""
            }
        }
    }
    
    @IBAction func removeAll(_ sender: AnyObject) {
        
        for item in ssidList { appDel.managedObjectContext?.delete(item) }
        CoreDataController.sharedInstance.saveChanges()
        self.updateSSID()
    }
    
}

class SSIDCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func setItem(_ ssid:SSID) {
        backgroundColor = UIColor.clear
        nameLabel.text = ssid.name
    }
}
