//
//  ImportZoneViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ImportZoneViewController: PopoverVC, ImportFilesDelegate, ProgressBarDelegate, EditZoneDelegate, AddAddressDelegate, UITextFieldDelegate {

    var appDel:AppDelegate!
    var error:NSError? = nil
    var zones:[Zone] = []
    var location:Location!
    
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    @IBOutlet weak var importZoneTableView: UITableView!
    
    var beacon:IBeacon?
    
    var choosedIndex = -1
    
    var scanZones:ScanFunction?
    var zoneScanTimer:NSTimer?
    var idToSearch:Int?
    var timesRepeatedCounter:Int = 0
    
    var currentIndex:Int = 0
    var from:Int = 0
    var to:Int = 0
    
    var pbSZ:ProgressBarVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFrom.delegate = self
        txtTo.delegate = self
        
        txtFrom.inputAccessoryView = CustomToolBar()
        txtTo.inputAccessoryView = CustomToolBar()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(ImportZoneViewController.longPressGestureRecognized(_:)))
        importZoneTableView.addGestureRecognizer(longpress)

        refreshZoneList()
    }
    
    override func viewDidAppear(animated: Bool) {
        removeObservers()
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    
    func endEditingNow(){
        txtFrom.resignFirstResponder()
        txtTo.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
    //move tableview cell on hold and swipe
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer){
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(importZoneTableView)
        let indexPath = importZoneTableView.indexPathForRowAtPoint(locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
    
        switch state {
        case UIGestureRecognizerState.Began:
            
            if indexPath != nil {
                
                Path.initialIndexPath = indexPath
                let cell = importZoneTableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell)
                var center = cell.center
                
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                importZoneTableView.addSubview(My.cellSnapshot!)
                
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    
                    center.y = locationInView.y
                    My.cellSnapshot!.center = center
                    My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.02, 1.02)
                    My.cellSnapshot!.alpha = 0.98
                    cell.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            cell.hidden = true
                        }
                })
            }
            
        case UIGestureRecognizerState.Changed:
            var center = My.cellSnapshot!.center
            
            center.y = locationInView.y
            
            My.cellSnapshot!.center = center
            
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {       
                if let index = indexPath, let initial = Path.initialIndexPath {
                    let pom = zones[index.row]
                    zones[index.row] = zones[initial.row]
                    zones[initial.row] = pom
                    let id = zones[index.row].orderId
                    zones[index.row].orderId = zones[initial.row].orderId
                    zones[initial.row].orderId = id
                    CoreDataController.shahredInstance.saveChanges()
                    
                }
                
                importZoneTableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                Path.initialIndexPath = indexPath
                
            }
            
        default:
            let cell = importZoneTableView.cellForRowAtIndexPath(Path.initialIndexPath!) as! ImportZoneTableViewCell!
            cell.hidden = false
            cell.alpha = 0.0
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                My.cellSnapshot!.center = cell.center
                My.cellSnapshot!.transform = CGAffineTransformIdentity
                My.cellSnapshot!.alpha = 0.0
                
                cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    
                    if finished {
                        
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                        
                    }
                    
            })
            
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
        
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "zoneReceivedFromGateway:", name: NotificationKey.DidReceiveZoneFromGateway, object: nil)
    }
    
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForZones)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "zoneReceivedFromGateway:", object: nil)
    }
    
    func backURL(strText: String) {
//        First - Delete all zones
        for item in 0 ..< zones.count {
            if zones[item].location == location! {
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
                    zone.location = location!
                    zone.orderId = 1
                    if zoneJSON.id == 254 || zoneJSON.id == 255 {
                        zone.isVisible = NSNumber(bool: false)
                    } else {
                        zone.isVisible = NSNumber(bool: true)
                    }
                    CoreDataController.shahredInstance.saveChanges()
                }
            } else {
                let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                createZones(location!)
            }
        } else {
            let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            createZones(location!)
        }
        refreshZoneList()
    }
    
    //MARK: - ZONE SCANNING
    
    func progressBarDidPressedExit () {
        dismissScaningControls()
    }
    
    @IBAction func addZone(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.showEditZone(nil, location: self.location).delegate = self
        })
    }
    
    func editZoneFInished() {
        refreshZoneList()
    }
    
    @IBAction func btnScanZones(sender: AnyObject) {
        showAddAddress().delegate = self
    }
    
    func addAddressFinished(address: Address) {
        do {
            
            var gatewayForScan:Gateway?
            
            if let location = location{
                if let gateways = location.gateways?.allObjects as? [Gateway]{
                    for gate in gateways{
                        if gate.addressOne == address.firstByte && gate.addressTwo == address.secondByte && gate.addressThree == address.thirdByte{
                            gatewayForScan = gate
                        }
                    }
                }
            }
            
            guard let gateway = gatewayForScan else {
                self.view.makeToast(message: "No gateway with address")
                return
            }
            let sp = try returnSearchParametars(txtFrom.text!, to: txtTo.text!)
            scanZones = ScanFunction(from: sp.from, to: sp.to, gateway: gateway, scanForWhat: .Zone)
            pbSZ = ProgressBarVC(title: "Scanning Zones", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbSZ?.delegate = self
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningForZones)
            scanZones?.sendCommandForFinding(id:Byte(sp.from))
            idToSearch = sp.from
            zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: idToSearch, repeats: false)
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
                        zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: idToSearch, repeats: false)
                        timesRepeatedCounter = 1
                    }
                } else {
                    scanZones?.sendCommandForFinding(id:Byte(idToSearch!))
                    setProgressBarParametarsForScanningZones(id: idToSearch!)
                    zoneScanTimer!.invalidate()
                    zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: idToSearch, repeats: false)
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
                        zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: idToSearch, repeats: false)
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
            if zones[item].location == location! {
                appDel.managedObjectContext!.deleteObject(zones[item])
            }
        }
        createZones(location!)
        CoreDataController.shahredInstance.saveChanges()
        refreshZoneList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createZones(location:Location) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: false), location, zoneJSON.id, 1)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: true), location, zoneJSON.id, 1)
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    func refreshZoneList() {
        updateZoneList()
        importZoneTableView.reloadData()
    }
    
    func updateZoneList () {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        let predicate = NSPredicate(format: "location == %@", location!)
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
    
    func isVisibleValueChanged (sender:UISwitch) {
        if sender.on == true {
            zones[sender.tag].isVisible = true
        }else {
            zones[sender.tag].isVisible = false
        }
        CoreDataController.shahredInstance.saveChanges()
        importZoneTableView.reloadData()
    }
    
    func chooseGateway (gestureRecognizer:UIGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            choosedIndex = tag
            
//            button = sender
            var popoverList:[PopOverItem] = []
//            let list:[Gateway] = DatabaseGatewayController.shared.getGatewayByLocationForSecurity(location!)
//            for item in list {
//                popoverList.append(PopOverItem(name: item.gatewayDescription, id: item.objectID.URIRepresentation().absoluteString))
//            }
            popoverList.insert(PopOverItem(name: "  ", id: ""), atIndex: 0)
            openPopover(gestureRecognizer.view!, popOverList:popoverList)
        }
    }
    
    override func nameAndId(name: String, id: String) {
        
    }
    
//    func saveText(text: String, id: Int) {
//        if choosedIndex != -1 && text != "No iBeacon" {
//            beacon = returniBeaconWithName(text)
//            zones[choosedIndex].iBeacon = beacon
//            saveChanges()
//            importZoneTableView.reloadData()
//        } else if text == "No iBeacon" {
//            zones[choosedIndex].iBeacon = nil
//            saveChanges()
//            importZoneTableView.reloadData()
//        }
//    }
    
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
        dispatch_async(dispatch_get_main_queue(),{
            self.showEditZone(self.zones[indexPath.row], location: self.location).delegate = self
        })
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if zones[indexPath.row].id as! Int == 255 || zones[indexPath.row].id as! Int == 254{
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
            var name = ""
            if let id = zones[indexPath.row].level?.integerValue{
                if id != 0 {
                    if let level = DatabaseZoneController.shared.getZoneById(id, location: location){
                        name = level.name! + " "
                    }
                }
            }
            
            cell.lblName.text = name + "\(zones[indexPath.row].name!)"
            cell.lblLevel.text = zones[indexPath.row].zoneDescription
            cell.lblNo.text = "\(zones[indexPath.row].id!)"
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.addTarget(self, action: #selector(ImportZoneViewController.isVisibleValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            cell.btnZonePicker.setTitle("Add iBeacon", forState: UIControlState.Normal)
            cell.setItem(zones[indexPath.row])
            if let iBeaconName = zones[indexPath.row].iBeacon?.name {
                cell.btnZonePicker.setTitle(iBeaconName, forState: UIControlState.Normal)
            }
            cell.btnZonePicker.tag = indexPath.row
            cell.btnZonePicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImportZoneViewController.chooseGateway(_:))))
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
}

class ImportZoneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var btnZonePicker: CustomGradientButton!
    
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var zoneItem:Zone!
    
    func setItem(zone: Zone){
        self.zoneItem = zone
        if let type = TypeOfControl(rawValue: (zone.allowOption.integerValue)){
            controlTypeButton.setTitle(type.description, forState: .Normal)
        }
    }
    
    @IBAction func changeControlType(sender: AnyObject) {
        if zoneItem.allowOption.integerValue == 1{
            DatabaseZoneController.shared.changeAllowOption(2, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.Confirm.description , forState: .Normal)
            return
        }
        if zoneItem.allowOption.integerValue == 2{
            DatabaseZoneController.shared.changeAllowOption(3, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.NotAllowed.description , forState: .Normal)
            return
        }
        if zoneItem.allowOption.integerValue == 3{
            DatabaseZoneController.shared.changeAllowOption(1, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.Allowed.description , forState: .Normal)
            return
        }
    }
    
}