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
        appDel = (UIApplication.shared.delegate as! AppDelegate)

        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        self.navigationItem.title = typeOfFile?.description

        pcCommandFilter()
    }
    
    func pcCommandFilter(){
        filteredArray = []
        if let list = device.pcCommands {
            if let commandArray = Array(list) as? [PCCommand] {
                if typeOfFile == FileType.app {
                    filteredArray = commandArray.filter({ (pccommand) -> Bool in
                        if Int(pccommand.commandType!) == CommandType.application.rawValue { return true }
                        return false
                    })
                } else {
                    filteredArray = commandArray.filter({ (pccommand) -> Bool in
                        if Int(pccommand.commandType!) == CommandType.media.rawValue { return true }
                        return false
                    })
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "device_appCell", for: indexPath) as? Device_AppCell{
            cell.setItem(filteredArray[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "defaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAddVideoAppXIB(typeOfFile, device:device, command:filteredArray[indexPath.row]).delegate = self
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appDel.managedObjectContext?.delete(filteredArray[indexPath.row])
            appDel.saveContext()
            pcCommandFilter()
            listTableView.reloadData()
        }
    }
    
    @IBAction func backButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addItemInListAction(_ sender: AnyObject) {
        showAddVideoAppXIB(typeOfFile, device:device, command:nil).delegate = self
    }
    
    func importFinished(){
        pcCommandFilter()
        listTableView.reloadData()
    }
    
}
