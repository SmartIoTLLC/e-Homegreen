//
//  ImportZoneViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ImportZoneViewController: UIViewController, ImportFilesDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, ProgressBarDelegate, EditZoneDelegate {

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
    
    override func viewDidAppear(animated: Bool) {
        removeObservers()
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "zoneReceivedFromGateway:", name: NotificationKey.DidReceiveZoneFromGateway, object: nil)
    }
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForZones)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "zoneReceivedFromGateway:", object: nil)
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
    
    //MARK: - ZONE SCANNING
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    var currentIndex:Int = 0
    var from:Int = 0
    var to:Int = 0
    
    var pbSZ:ProgressBarVC?
    func progressBarDidPressedExit () {
        dismissScaningControls()
    }
    var scanZones:ScanFunction?
    var zoneScanTimer:NSTimer?
    var idToSearch:Int?
    var timesRepeatedCounter:Int = 0
    
    
    @IBAction func addZone(sender: AnyObject) {
        showEditZone(nil, gateway: gateway).delegate = self
    }
    
    func editZoneFInished() {
        refreshZoneList()
    }
    
    
    @IBAction func btnScanZones(sender: AnyObject) {
        do {
            let sp = try returnSearchParametars(txtFrom.text!, to: txtTo.text!)
            scanZones = ScanFunction(from: sp.from, to: sp.to, gateway: gateway!, scanForWhat: .Zone)
            pbSZ = ProgressBarVC(title: "Scanning Zones", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbSZ?.delegate = self
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningForZones)
            scanZones?.sendCommandForFinding(id:Byte(sp.from))
            idToSearch = sp.from
            zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetZones:", userInfo: idToSearch, repeats: false)
            timesRepeatedCounter = 1
            self.presentViewController(pbSZ!, animated: true, completion: nil)
            UIApplication.sharedApplication().idleTimerDisabled = true
            
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    
    @IBAction func btnClearFields(sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    // MARK: Service for scanning zone
    func checkIfGatewayDidGetZones (timer:NSTimer) {
        if let zoneId = timer.userInfo as? Int {
            if zoneId > idToSearch {
                // nesto nije dobro
                dismissScaningControls()
                alertController("Error", message: "Something went wrong!")
                return
            }
            if zoneId == idToSearch {
                // ako je proverio tri puta
                if timesRepeatedCounter == 3 {
                    // Proveriti da li je poslednji ili idemo dalje
                    if (zoneId+1) > scanZones?.to {
                        dismissScaningControls()
                    } else {
                        //ima jos
                        idToSearch! += 1
                        scanZones?.sendCommandForFinding(id:Byte(idToSearch!))
                        setProgressBarParametarsForScanningZones(id: idToSearch!)
                        zoneScanTimer!.invalidate()
                        zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetZones:", userInfo: idToSearch, repeats: false)
                        timesRepeatedCounter = 1
                    }
                } else {
                    scanZones?.sendCommandForFinding(id:Byte(idToSearch!))
                    setProgressBarParametarsForScanningZones(id: idToSearch!)
                    zoneScanTimer!.invalidate()
                    zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetZones:", userInfo: idToSearch, repeats: false)
                    timesRepeatedCounter += 1
                }
                return
            }
            if zoneId < idToSearch {
                // nesto nije dobro
                dismissScaningControls()
                alertController("Error", message: "Something went wrong!")
            }
        }
    }
    //MARK: Zone received from gateway
    func zoneReceivedFromGateway (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningForZones) {
            if let zoneId = notification.userInfo as? [String:Int] {
                if zoneId["zoneId"] > idToSearch {
                    // nesto nije dobro
                    dismissScaningControls()
                    alertController("Error", message: "Something went wrong!")
                    return
                }
                if zoneId["zoneId"] == idToSearch {
                    timesRepeatedCounter = 0
                    if idToSearch >= scanZones?.to {
                        //gotovo
                        dismissScaningControls()
                    } else {
                        //ima jos
                        idToSearch! += 1
                        scanZones?.sendCommandForFinding(id:Byte(idToSearch!))
                        setProgressBarParametarsForScanningZones(id: idToSearch!)
                        zoneScanTimer!.invalidate()
                        zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetZones:", userInfo: idToSearch, repeats: false)
                        timesRepeatedCounter = 1
                    }
                    refreshZoneList()
                    return
                }
                if zoneId["zoneId"] < idToSearch {
                    // nesto nije dobro
                    dismissScaningControls()
                    alertController("Error", message: "Something went wrong!")
                }
            }
        }
    }
    // MARK: Controlling progress bar
    func setProgressBarParametarsForScanningZones(id zoneId:Int) {
        var index:Int = zoneId
        index = index - scanZones!.from + 1
        let howMuchOf = scanZones!.to - scanZones!.from + 1
        pbSZ?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
        pbSZ?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
        pbSZ?.progressView.progress = Float(index)/Float(howMuchOf)
    }
    // MARK: Error handling for Zones
    func returnSearchParametars (from:String, to:String) throws -> SearchParametars {
        if from == "" && to == "" {
            let count = 255
            let percent = Float(1)/Float(count)
            return SearchParametars(from: 1, to: 255, count: count, initialPercentage: percent)
//            throw InputError.SpecifyRange
        }
        guard let from = Int(from), let to = Int(to) else {
            throw InputError.NotConvertibleToInt
        }
        if from < 0 || to < 0 {
            throw InputError.NotPositiveNumbers
        }
        if from > to {
            throw InputError.FromBiggerThanTo
        }
        let count = to - from + 1
        let percent = Float(1)/Float(count)
        return SearchParametars(from: from, to: to, count: count, initialPercentage: percent)
    }
    
    // MARK: Alert controller
    var alertController:UIAlertController?
    func alertController (title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController!.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController!.addAction(OKAction)
        
        self.presentViewController(alertController!, animated: true) {
            // ...
        }
    }
    // MARK: Dismiss zone scanning
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        idToSearch = 0
        zoneScanTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForZones)
        pbSZ?.dissmissProgressBar()
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    // MARK:- Delete zones and other
    
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
extension ImportZoneViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showEditZone(zones[indexPath.row], gateway: nil).delegate = self
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if zones[indexPath.row].id as Int == 255 || zones[indexPath.row].id as Int == 254{
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
         if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(zones[indexPath.row])
            appDel.saveContext()
            refreshZoneList()
         }
    }
}
extension ImportZoneViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = importZoneTableView.dequeueReusableCellWithIdentifier("importZone") as? ImportZoneTableViewCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblName.text = "\(zones[indexPath.row].id). \(zones[indexPath.row].name)"
            print(zones[indexPath.row].level)
            cell.lblLevel.text = "Level: \(zones[indexPath.row].level)"
//            cell.lblDescription.text = "Desc: \(zones[indexPath.row].zoneDescription)"
//            cell.lblLevel.text = ""
            cell.lblDescription.text = ""
            cell.switchVisible.on = zones[indexPath.row].isVisible.boolValue
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.addTarget(self, action: "isVisibleValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.btnZonePicker.setTitle("Add iBeacon", forState: UIControlState.Normal)
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