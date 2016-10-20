//
//  ImportZoneViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ImportZoneViewController: PopoverVC, ImportFilesDelegate, ProgressBarDelegate, EditZoneDelegate, AddAddressDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var importZoneTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var zones:[Zone] = []
    var location:Location!
    var beacon:IBeacon?
    var choosedIndex = -1
    var scanZones:ScanFunction?
    var zoneScanTimer:Foundation.Timer?
    
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
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(ImportZoneViewController.longPressGestureRecognized(_:)))
        importZoneTableView.addGestureRecognizer(longpress)

        refreshZoneList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        removeObservers()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    
    override func nameAndId(_ name: String, id: String) {
        
    }
    
    func endEditingNow(){
        txtFrom.resignFirstResponder()
        txtTo.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    //move tableview cell on hold and swipe
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer){
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: importZoneTableView)
        let indexPath = importZoneTableView.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
    
        switch state {
        case UIGestureRecognizerState.began:
            
            if indexPath != nil {
                
                Path.initialIndexPath = indexPath
                let cell = importZoneTableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell!)
                var center = cell?.center
                
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                importZoneTableView.addSubview(My.cellSnapshot!)
                
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    
                    center?.y = locationInView.y
                    My.cellSnapshot!.center = center!
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                    My.cellSnapshot!.alpha = 0.98
                    cell?.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                        if finished {
                            cell?.isHidden = true
                        }
                })
            }
            
        case UIGestureRecognizerState.changed:
            var center = My.cellSnapshot!.center
            
            center.y = locationInView.y
            
            My.cellSnapshot!.center = center
            
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {       
                if let index = indexPath, let initial = Path.initialIndexPath {
                    let pom = zones[(index as NSIndexPath).row]
                    zones[(index as NSIndexPath).row] = zones[(initial as NSIndexPath).row]
                    zones[(initial as NSIndexPath).row] = pom
                    let id = zones[(index as NSIndexPath).row].orderId
                    zones[(index as NSIndexPath).row].orderId = zones[(initial as NSIndexPath).row].orderId
                    zones[(initial as NSIndexPath).row].orderId = id
                    CoreDataController.shahredInstance.saveChanges()
                    
                }
                
                importZoneTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
                
            }
            
        default:
            let cell = importZoneTableView.cellForRow(at: Path.initialIndexPath!) as! ImportZoneTableViewCell!
            cell?.isHidden = false
            cell?.alpha = 0.0
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                
                My.cellSnapshot!.center = (cell?.center)!
                My.cellSnapshot!.transform = CGAffineTransform.identity
                My.cellSnapshot!.alpha = 0.0
                
                cell?.alpha = 1.0
                }, completion: { (finished) -> Void in
                    
                    if finished {
                        
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                        
                    }
                    
            })
            
        }
    }
    
    func snapshopOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
        
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ImportZoneViewController.zoneReceivedFromGateway(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveZoneFromGateway), object: nil)
    }
    
    func removeObservers() {
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningForZones)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "zoneReceivedFromGateway:"), object: nil)
    }
    
    func backURL(_ strText: String) {
//        First - Delete all zones
        for item in 0 ..< zones.count {
            if zones[item].location == location! {
                appDel.managedObjectContext!.delete(zones[item])
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
                    let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: appDel.managedObjectContext!) as! Zone
                    zone.id = zoneJSON.id as NSNumber?
                    zone.name = zoneJSON.name
                    zone.zoneDescription = zoneJSON.description
                    zone.level = zoneJSON.level as NSNumber?
                    zone.location = location!
                    zone.orderId = 1
                    if zoneJSON.id == 254 || zoneJSON.id == 255 {
                        zone.isVisible = NSNumber(value: false as Bool)
                    } else {
                        zone.isVisible = NSNumber(value: true as Bool)
                    }
                    CoreDataController.shahredInstance.saveChanges()
                }
            } else {
                let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                present(alert, animated: true, completion: nil)
                createZones(location!)
            }
        } else {
            let alert = UIAlertController(title: "Something Went Wrong", message: "There was problem parsing json file. Please configure your file.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
            createZones(location!)
        }
        refreshZoneList()
    }
    
    
    // MARK: - ZONE SCANNING
    @IBAction func addZone(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: {
            self.showEditZone(nil, location: self.location).delegate = self
        })
    }
    @IBAction func btnScanZones(_ sender: AnyObject) {
        showAddAddress(ScanType.zone).delegate = self
    }
    @IBAction func btnClearFields(_ sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    
    func editZoneFInished() {
        refreshZoneList()
    }
    func progressBarDidPressedExit () {
        dismissScaningControls()
    }
    func addAddressFinished(_ address: Address) {
        do {
            var gatewayForScan:Gateway?
            guard let location = location else{
                return
            }
            guard let gateways = location.gateways?.allObjects as? [Gateway] else{
                return
            }
            for gate in gateways{
                if Int(gate.addressOne) == address.firstByte && Int(gate.addressTwo) == address.secondByte && Int(gate.addressThree) == address.thirdByte{
                    gatewayForScan = gate
                }
            }
            
            guard let gateway = gatewayForScan else {
                self.view.makeToast(message: "No gateway with address")
                return
            }
            
            
            let sp = try returnSearchParametars(txtFrom.text!, to: txtTo.text!)
            scanZones = ScanFunction(from: sp.from, to: sp.to, gateway: gateway, scanForWhat: .zone)
            pbSZ = ProgressBarVC(title: "Scanning Zones", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbSZ?.delegate = self
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningForZones)
            scanZones?.sendCommandForFinding(id:Byte(sp.from))
            zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: sp.from, repeats: false)
            timesRepeatedCounter = 1
            self.present(pbSZ!, animated: true, completion: nil)
            UIApplication.shared.isIdleTimerDisabled = true
            
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    func checkIfGatewayDidGetZones (_ timer:Foundation.Timer) {
        guard var zoneId = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 4 {  // try three times
            scanZones?.sendCommandForFinding(id:Byte(zoneId))
            setProgressBarParametarsForScanningZones(id: zoneId)
            zoneScanTimer!.invalidate()
            zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: zoneId, repeats: false)
            timesRepeatedCounter += 1
        }else{
            if (zoneId+1) > scanZones?.to { // If it is the last one
                dismissScaningControls()
            } else {
                //there is more
                zoneId += 1
                scanZones?.sendCommandForFinding(id:Byte(zoneId))
                setProgressBarParametarsForScanningZones(id: zoneId)
                zoneScanTimer!.invalidate()
                zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: zoneId, repeats: false)
                timesRepeatedCounter = 1
            }
        }
    }
    func zoneReceivedFromGateway (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForZones) {
            guard var zoneId = (notification as NSNotification).userInfo as? [String:Int] else {
                return
            }
            timesRepeatedCounter = 0
            if zoneId["zoneId"] >= scanZones?.to{
                //gotovo
                dismissScaningControls()
            } else {
                //ima jos
                let newZoneId = zoneId["zoneId"]! + 1
                scanZones?.sendCommandForFinding(id:Byte(newZoneId))
                setProgressBarParametarsForScanningZones(id: newZoneId)
                zoneScanTimer!.invalidate()
                zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: newZoneId, repeats: false)
                timesRepeatedCounter = 1
            }
            refreshZoneList()
            return
        }
    }
    func setProgressBarParametarsForScanningZones(id zoneId:Int) {
        var index:Int = zoneId
        index = index - scanZones!.from + 1
        let howMuchOf = scanZones!.to - scanZones!.from + 1
        pbSZ?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
        pbSZ?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
        pbSZ?.progressView.progress = Float(index)/Float(howMuchOf)
    }
    func returnSearchParametars (_ from:String, to:String) throws -> SearchParametars {
        if from == "" && to == "" {
            let count = 255
            let percent = Float(1)/Float(count)
            return SearchParametars(from: 1, to: 255, count: count, initialPercentage: percent)
        }
        guard let from = Int(from), let to = Int(to) else {
            throw InputError.notConvertibleToInt
        }
        if from < 0 || to < 0 {
            throw InputError.notPositiveNumbers
        }
        if from > to {
            throw InputError.fromBiggerThanTo
        }
        let count = to - from + 1
        let percent = Float(1)/Float(count)
        return SearchParametars(from: from, to: to, count: count, initialPercentage: percent)
    }
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        zoneScanTimer?.invalidate()
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningForZones)
        pbSZ?.dissmissProgressBar()
        UIApplication.shared.isIdleTimerDisabled = false
        refreshZoneList()
    }
    
//    // MARK: Alert controller
//    var alertController:UIAlertController?
//    func alertController (_ title:String, message:String) {
//        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            // ...
//        }
//        alertController!.addAction(cancelAction)
//        
//        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
//            // ...
//        }
//        alertController!.addAction(OKAction)
//        
//        self.present(alertController!, animated: true) {
//            // ...
//        }
//    }
    
    // MARK:- Delete zones and other
    @IBAction func btnDeleteAll(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all devices?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                for item in 0 ..< self.zones.count {
                    if self.zones[item].location == self.location! {
                        self.appDel.managedObjectContext!.delete(self.zones[item])
                    }
                }
                self.createZones(self.location!)
                CoreDataController.shahredInstance.saveChanges()
                self.refreshZoneList()
            }
        }
    }
    @IBAction func btnImportFile(_ sender: AnyObject) {
        showImportFiles().delegate = self
    }
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createZones(_ location:Location) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: false as Bool), location, zoneJSON.id as NSNumber?, 1)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: true as Bool), location, zoneJSON.id as NSNumber?, 1)
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        let predicate = NSPredicate(format: "location == %@", location!)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Zone]
            zones = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func isVisibleValueChanged (_ sender:UISwitch) {
        if sender.isOn == true {
            zones[sender.tag].isVisible = true
        }else {
            zones[sender.tag].isVisible = false
        }
        CoreDataController.shahredInstance.saveChanges()
        importZoneTableView.reloadData()
    }
    
    
    
    func chooseGateway (_ gestureRecognizer:UIGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            choosedIndex = tag
            var popoverList:[PopOverItem] = []
            popoverList.insert(PopOverItem(name: "  ", id: ""), at: 0)
            openPopover(gestureRecognizer.view!, popOverList:popoverList)
        }
    }
    
    func returniBeaconWithName(_ name:String) -> IBeacon? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = IBeacon.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let results = try appDel.managedObjectContext!.fetch(fetchRequest) as! [IBeacon]
            return results[0]
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
    }
    
    @IBAction func addTag(_ sender: AnyObject) {
        showTag()
    }
    
}

extension ImportZoneViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.showEditZone(self.zones[(indexPath as NSIndexPath).row], location: self.location).delegate = self
        })
    }
    


}

extension ImportZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = importZoneTableView.dequeueReusableCell(withIdentifier: "importZone") as? ImportZoneTableViewCell {
            cell.backgroundColor = UIColor.clear
            var name = ""
            if let id = zones[(indexPath as NSIndexPath).row].level?.intValue{
                if id != 0 {
                    if let level = DatabaseZoneController.shared.getZoneById(id, location: location){
                        name = level.name! + " "
                    }
                }
            }
            
            cell.lblName.text = name + "\(zones[(indexPath as NSIndexPath).row].name!)"
            cell.lblLevel.text = zones[(indexPath as NSIndexPath).row].zoneDescription
            cell.lblNo.text = "\(zones[(indexPath as NSIndexPath).row].id!)"
            cell.switchVisible.isOn = Bool(zones[(indexPath as NSIndexPath).row].isVisible)
            cell.switchVisible.tag = (indexPath as NSIndexPath).row
            cell.switchVisible.addTarget(self, action: #selector(ImportZoneViewController.isVisibleValueChanged(_:)), for: UIControlEvents.valueChanged)
            cell.btnZonePicker.setTitle("Add iBeacon", for:[])
            cell.tagsButton.setTitle("Tags", for: [])
            cell.setItem(zones[(indexPath as NSIndexPath).row])
            if let iBeaconName = zones[(indexPath as NSIndexPath).row].iBeacon?.name {
                cell.btnZonePicker.setTitle(iBeaconName, for: UIControlState())
            }
            cell.btnZonePicker.tag = (indexPath as NSIndexPath).row
            cell.btnZonePicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImportZoneViewController.chooseGateway(_:))))
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if zones[(indexPath as NSIndexPath).row].id as! Int == 255 || zones[(indexPath as NSIndexPath).row].id as! Int == 254{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            if editingStyle == .delete {
                appDel.managedObjectContext?.delete(zones[(indexPath as NSIndexPath).row])
                appDel.saveContext()
                refreshZoneList()
            }
        }
    }
}

class ImportZoneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var btnZonePicker: CustomGradientButton!
    @IBOutlet weak var tagsButton: CustomGradientButton!
    
    
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var zoneItem:Zone!
    
    func setItem(_ zone: Zone){
        self.zoneItem = zone
        if let type = TypeOfControl(rawValue: (zone.allowOption.intValue)){
            controlTypeButton.setTitle(type.description, for: UIControlState())
        }
    }
    
    @IBAction func changeControlType(_ sender: AnyObject) {
        if zoneItem.allowOption.intValue == 1{
            DatabaseZoneController.shared.changeAllowOption(2, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.confirm.description , for: UIControlState())
            return
        }
        if zoneItem.allowOption.intValue == 2{
            DatabaseZoneController.shared.changeAllowOption(3, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.notAllowed.description , for: UIControlState())
            return
        }
        if zoneItem.allowOption.intValue == 3{
            DatabaseZoneController.shared.changeAllowOption(1, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.allowed.description , for: UIControlState())
            return
        }
    }
    
    
    
}
