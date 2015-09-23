//
//  ImportZoneViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

//IPGCW02001_000_000_Zones List
class ImportZoneViewController: UIViewController, ImportFilesDelegate {

    var appDel:AppDelegate!
    var error:NSError? = nil
    var zones:[Zone] = []
    var gateway:Gateway?
    
    @IBOutlet weak var importZoneTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
//        let zones:[ZoneJSON] = DataImporter.createZonesFromFile("IPGCW02001_000_000_Zones List.json")!
//        print(zones)

        refreshZoneList()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backURL(strText: String) {
        if let zonesJSON = DataImporter.createZonesFromFile(strText) {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                zone.id = zoneJSON.id
                zone.name = zoneJSON.name
                zone.zoneDescription = zoneJSON.description
                zone.level = zoneJSON.level
                zone.gateway = gateway!
                saveChanges()
            }
        }
        refreshZoneList()
    }
    
    @IBAction func btnDeleteAll(sender: AnyObject) {
        for var item = 0; item < zones.count; item++ {
            if zones[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(zones[item])
            }
        }
        saveChanges()
        refreshZoneList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
//        if let zonesJSON:[ZoneJSON] = DataImporter.createZonesFromFile("IPGCW02001_000_000_Zones List.json")! {
//            for zoneJSON in zonesJSON {
//                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
//                zone.id = zoneJSON.id
//                zone.name = zoneJSON.name
//                zone.zoneDescription = zoneJSON.description
//                zone.level = zoneJSON.level
//                zone.gateway = gateway!
//                saveChanges()
//            }
//        }
//        refreshZoneList()
    }
    
    func refreshZoneList() {
        updateZoneList()
        importZoneTableView.reloadData()
    }
    
    func updateZoneList () {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "id", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "name", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "level", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            zones = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ImportZoneViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
extension ImportZoneViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = importZoneTableView.dequeueReusableCellWithIdentifier("importZone") as? ImportZoneTableViewCell {
            cell.lblName.text = "\(zones[indexPath.row].id)" + ", \(zones[indexPath.row].name)"
            cell.lblLevel.text = "Level: \(zones[indexPath.row].level)"
            cell.lblDescription.text = "Desc: \(zones[indexPath.row].zoneDescription)"
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text =  "\(zones[indexPath.row].id). \(zones[indexPath.row].name), Level: \(zones[indexPath.row].level), Desc: \(zones[indexPath.row].zoneDescription)"
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.clearColor()
        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
}
class ImportZoneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var switchEnable: UISwitch!
    @IBOutlet weak var switchVisible: UISwitch!
    
}