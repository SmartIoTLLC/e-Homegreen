//
//  ImportSSIDViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ImportSSIDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var ssidList:[SSID] = []
    var location:Location?
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    @IBOutlet weak var ssidNameTextfield: UITextField!
    
    @IBOutlet weak var ssidTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ssidNameTextfield.delegate = self
        
        updateSSID()

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateSSID(){
        if let location = location{
            if let list = location.ssids?.allObjects as? [SSID]{
                ssidList = list.sort({ (first, second) -> Bool in
                    return first.name < second.name
                })
            }
        }
        ssidTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ssidCell") as? SSIDCell {
            cell.setItem(ssidList[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ssidList.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let optionMenu = UIAlertController(title: nil, message: "Delete SSID?", preferredStyle: .ActionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                
            self.appDel.managedObjectContext?.deleteObject(self.ssidList[indexPath.row])
                self.saveChanges()
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.presentViewController(optionMenu, animated: true, completion: nil)
            
        }
    }

    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func addSSID(sender: AnyObject) {
        guard let name = ssidNameTextfield.text where name != "" else {
            return
        }
        if let location = location{
        if let ssid = NSEntityDescription.insertNewObjectForEntityForName("SSID", inManagedObjectContext: appDel.managedObjectContext!) as? SSID{
                ssid.name = name
                ssid.location = location
            saveChanges()
            }
        }
    }
    
    @IBAction func removeAll(sender: AnyObject) {
        for item in ssidList{
            appDel.managedObjectContext?.deleteObject(item)
        }
        saveChanges()
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
            updateSSID()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    
}

class SSIDCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func setItem(ssid:SSID){
        nameLabel.text = ssid.name
    }
}
