//
//  ListOfDevice_AppViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ListOfDevice_AppViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ImportPathDelegate {

    @IBOutlet weak var listTableView: UITableView!
    
    var filteredArray:[PCCommand] = []
    
    var typeOfFile:FileType!
    var device:Device!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        self.navigationItem.title = typeOfFile?.description
        pcCommandFilter()
        // Do any additional setup after loading the view.
    }
    
    func pcCommandFilter(){
        filteredArray = []
        if let list = device.pcCommands {
            if let commandArray = Array(list) as? [PCCommand] {
                if typeOfFile == FileType.App{
                    filteredArray = commandArray.filter({ (let pccommand) -> Bool in
                        if pccommand.isRunCommand == true {
                            return true
                        }
                        return false
                    })
                }else{
                    filteredArray = commandArray.filter({ (let pccommand) -> Bool in
                        if pccommand.isRunCommand == false {
                            return true
                        }
                        return false
                    })
                }

            }
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("device_appCell", forIndexPath: indexPath) as? Device_AppCell{
            cell.setItem(filteredArray[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "defaultCell")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showAddVideoAppXIB(typeOfFile, device:device, command:filteredArray[indexPath.row]).delegate = self
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(filteredArray[indexPath.row])
            appDel.saveContext()
            pcCommandFilter()
            listTableView.reloadData()
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addItemInListAction(sender: AnyObject) {
        showAddVideoAppXIB(typeOfFile, device:device, command:nil).delegate = self
    }
    
    func importFinished(){
        pcCommandFilter()
        listTableView.reloadData()
    }
    
}
