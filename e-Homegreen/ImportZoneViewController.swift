//
//  ImportZoneViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ImportZoneViewController: UIViewController, ImportFilesDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {

    var appDel:AppDelegate!
    var error:NSError? = nil
    var zones:[Zone] = []
    var gateway:Gateway?
    var popoverVC:PopOverViewController = PopOverViewController()
    
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func backURL(strText: String) {
//        First - Delete all zones
        for var item = 0; item < zones.count; item++ {
            if zones[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(zones[item])
            }
        }
//        Second - Take default zones from bundle
        let zonesJSONBundle = DataImporter.createZonesFromFileFromNSBundle()
//        Third - Add new zones and edit zones from bundle if needed
        if var zonesJSON = DataImporter.createZonesFromFile(strText) {
            if zonesJSON.count != 0 {
                for zoneJsonBundle in zonesJSONBundle! {
                    var isExisting = false
                    for zoneJSON in zonesJSON {
                        if zoneJsonBundle.id == zoneJSON.id {
                            isExisting = true
                        }
                    }
                    if !isExisting {
                        zonesJSON.append(zoneJsonBundle)
                    }
                }
                for zoneJSON in zonesJSON {
                    let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                    zone.id = zoneJSON.id
                    zone.name = zoneJSON.name
                    zone.zoneDescription = zoneJSON.description
                    zone.level = zoneJSON.level
                    if zoneJSON.id == 254 || zoneJSON.id == 255 {
                        zone.isVisible = NSNumber(bool: false)
                    } else {
                        zone.isVisible = NSNumber(bool: true)
                    }
                    zone.gateway = gateway!
                    saveChanges()
                }
            } else {
                let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                createZones(gateway!)
            }
        } else {
            let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            createZones(gateway!)
        }
        refreshZoneList()
    }
    
    @IBAction func btnDeleteAll(sender: AnyObject) {
        for var item = 0; item < zones.count; item++ {
            if zones[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(zones[item])
            }
        }
        createZones(gateway!)
        saveChanges()
        refreshZoneList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
    }
    
    func createZones(gateway:Gateway) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.gateway) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: false), gateway)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.gateway) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: true), gateway)
                }
                saveChanges()
            }
        }
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
    
    func isVisibleValueChanged (sender:UISwitch) {
        if sender.on == true {
            zones[sender.tag].isVisible = true
        }else {
            zones[sender.tag].isVisible = false
        }
        saveChanges()
        importZoneTableView.reloadData()
    }
    
    func chooseGateway (gestureRecognizer:UIGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            choosedIndex = tag
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.preferredContentSize = CGSizeMake(300, 200)
            popoverVC.delegate = self
            popoverVC.indexTab = 8
            popoverVC.filterGateway = zones[tag].gateway
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.delegate = self
                popoverController.permittedArrowDirections = .Any
                popoverController.sourceView = gestureRecognizer.view! as UIView
                popoverController.sourceRect = gestureRecognizer.view!.bounds
                popoverController.backgroundColor = UIColor.lightGrayColor()
                self.parentViewController!.presentViewController(popoverVC, animated: true, completion: nil)
            }
        }
    }
    var choosedIndex = -1
    func saveText(text: String, id: Int) {
        if choosedIndex != -1 && text != "No iBeacon" {
            beacon = returniBeaconWithName(text)
            zones[choosedIndex].iBeacon = beacon
            saveChanges()
            importZoneTableView.reloadData()
        } else if text == "No iBeacon" {
            zones[choosedIndex].iBeacon = nil
            saveChanges()
            importZoneTableView.reloadData()
        }
    }
    var beacon:IBeacon?
    func returniBeaconWithName(name:String) -> IBeacon? {
        let fetchRequest = NSFetchRequest(entityName: "IBeacon")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let results = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as! [IBeacon]
            return results[0]
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
    }
}

extension ImportZoneViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = importZoneTableView.dequeueReusableCellWithIdentifier("importZone") as? ImportZoneTableViewCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblName.text = "\(zones[indexPath.row].id). \(zones[indexPath.row].name)"
            cell.lblLevel.text = "Level: \(zones[indexPath.row].level)"
            cell.lblDescription.text = "Desc: \(zones[indexPath.row].zoneDescription)"
            cell.switchVisible.on = zones[indexPath.row].isVisible.boolValue
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.addTarget(self, action: "isVisibleValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.btnZonePicker.setTitle("Choose iBeacon", forState: UIControlState.Normal)
            if let iBeaconName = zones[indexPath.row].iBeacon?.name {
                cell.btnZonePicker.setTitle(iBeaconName, forState: UIControlState.Normal)
            }
            cell.btnZonePicker.tag = indexPath.row
            cell.btnZonePicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "chooseGateway:"))
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
    @IBOutlet weak var btnZonePicker: CustomGradientButton!
    
}