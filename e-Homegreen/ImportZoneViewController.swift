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


class ImportZoneViewController: PopoverVC, ImportFilesDelegate, ProgressBarDelegate, EditZoneDelegate, AddAddressDelegate {
    
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
    
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    @IBOutlet weak var importZoneTableView: UITableView!
    // MARK: - ZONE SCANNING
    @IBAction func addZone(_ sender: AnyObject) {
        DispatchQueue.main.async(execute: { self.showEditZone(nil, location: self.location).delegate = self } )
    }
    @IBAction func btnScanZones(_ sender: AnyObject) {
        showAddAddress(ScanType.zone).delegate = self
    }
    @IBAction func btnClearFields(_ sender: AnyObject) {
        clearTextFields()
    }
    // MARK:- Delete zones and other
    @IBAction func btnDeleteAll(_ sender: UIButton) {
        deleteAll(sender: sender)
    }
    @IBAction func btnImportFile(_ sender: AnyObject) {
        showImportFiles().delegate = self
    }
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addTag(_ sender: AnyObject) {
        showTag()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
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
    
}



// MARK: - Table View Delegate
extension ImportZoneViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectEditZone(indexPath: indexPath)
    }

}

// MARK: - Table View Data Source
extension ImportZoneViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = importZoneTableView.dequeueReusableCell(withIdentifier: "importZone") as? ImportZoneTableViewCell {
            
            cell.setItem(zones[indexPath.row], tag: indexPath.row, location: location)
            
            cell.switchVisible.addTarget(self, action: #selector(isVisibleValueChanged(_:)), for: .valueChanged)
            cell.btnZonePicker.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseGateway(_:))))
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zones.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return canEditZone(at: indexPath)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { deleteSingleZone(at: indexPath) }
    }
    

}

// MARK: - View setup
extension ImportZoneViewController {
    
    fileprivate func setupViews() {
        txtFrom.delegate = self
        txtTo.delegate   = self
        
        txtFrom.inputAccessoryView = CustomToolBar()
        txtTo.inputAccessoryView   = CustomToolBar()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(ImportZoneViewController.longPressGestureRecognized(_:)))
        importZoneTableView.addGestureRecognizer(longpress)
    }
    
    func endEditingNow(){
        txtFrom.resignFirstResponder()
        txtTo.resignFirstResponder()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ImportZoneViewController.zoneReceivedFromGateway(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveZoneFromGateway), object: nil)
    }
    
    func removeObservers() {
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningForZones)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "zoneReceivedFromGateway:"), object: nil)
    }
    
    fileprivate func clearTextFields() {
        txtFrom.text = ""
        txtTo.text   = ""
    }
}

// MARK: - Logic
extension ImportZoneViewController {
    
    fileprivate func deleteSingleZone(at indexPath: IndexPath) {
        if let moc = appDel.managedObjectContext {
            let zone = zones[indexPath.row]
            moc.delete(zone)
            appDel.saveContext()
            refreshZoneList()
        }
    }
    
    fileprivate func canEditZone(at indexPath: IndexPath) -> Bool {
        if let id = zones[indexPath.row].id as? Int {
            if id == 255 || id == 254 { return false }
            return true
        }
        return false
    }
    
    fileprivate func didSelectEditZone(indexPath: IndexPath) {
        DispatchQueue.main.async(execute: {
            self.showEditZone(self.zones[indexPath.row], location: self.location).delegate = self
        })
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
            if let moc = appDel.managedObjectContext {
                if let fetResults = try moc.fetch(fetchRequest) as? [Zone] {
                    zones = fetResults
                }
            }
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error :", error!.userInfo)
            // abort()
        }
        
    }
    
    func createZones(_ location:Location) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                if let moc = appDel.managedObjectContext {
                    if let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: moc) as? Zone {
                        if zoneJSON.id == 254 || zoneJSON.id == 255 {
                            (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: false as Bool), location, zoneJSON.id as NSNumber?, 1)
                        } else {
                            (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: true as Bool), location, zoneJSON.id as NSNumber?, 1)
                        }
                        CoreDataController.sharedInstance.saveChanges()
                    }
                }
            }
        }
    }
    
    fileprivate func deleteAll(sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all devices?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                for item in 0 ..< self.zones.count {
                    let zone = self.zones[item]
                    if zone.location == self.location! {
                        if let moc = self.appDel.managedObjectContext {
                            moc.delete(zone)
                        }
                    }
                }
                self.createZones(self.location!)
                CoreDataController.sharedInstance.saveChanges()
                self.refreshZoneList()
            }
        }
    }
    
    func backURL(_ strText: String) {
        //        First - Delete all zones
        for item in 0 ..< zones.count {
            if zones[item].location == location! {
                if let moc = appDel.managedObjectContext {
                    moc.delete(zones[item])
                }
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
                    if let moc = appDel.managedObjectContext {
                        if let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: moc) as? Zone {
                            zone.id              = zoneJSON.id as NSNumber?
                            zone.name            = zoneJSON.name
                            zone.zoneDescription = zoneJSON.description
                            zone.level           = zoneJSON.level as NSNumber?
                            zone.location        = location!
                            zone.orderId         = 1
                            if zoneJSON.id == 254 || zoneJSON.id == 255 {
                                zone.isVisible = NSNumber(value: false as Bool)
                            } else {
                                zone.isVisible = NSNumber(value: true as Bool)
                            }
                            CoreDataController.sharedInstance.saveChanges()
                        }
                    }
                }
            } else {
                showParsingErrorAlert()
                createZones(location!)
            }
        } else {
            showParsingErrorAlert()
            createZones(location!)
        }
        refreshZoneList()
    }
    
    fileprivate func showParsingErrorAlert() {
        let alert = UIAlertController(title: "Something Went Wrong", message: "There was a problem parsing json file. Please configure your file.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //move tableview cell on hold and swipe
    @objc func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer){
        
        if let longPress = gestureRecognizer as? UILongPressGestureRecognizer {
            let state = longPress.state
            let locationInView = longPress.location(in: importZoneTableView)
            
            if let indexPath = importZoneTableView.indexPathForRow(at: locationInView) {
                struct My {
                    static var cellSnapshot : UIView? = nil
                }
                struct Path {
                    static var initialIndexPath : IndexPath? = nil
                }
                
                switch state {
                case UIGestureRecognizerState.began:
                    
                    Path.initialIndexPath = indexPath
                    if let cell = importZoneTableView.cellForRow(at: indexPath) {
                        My.cellSnapshot  = HelperFunctions.snapshotOfCell(cell)
                        var center = cell.center
                        
                        My.cellSnapshot!.center = center
                        My.cellSnapshot!.alpha  = 0.0
                        importZoneTableView.addSubview(My.cellSnapshot!)
                        
                        UIView.animate(withDuration: 0.25, animations: { () -> Void in
                            
                            center.y = locationInView.y
                            My.cellSnapshot!.center = center
                            My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
                            My.cellSnapshot!.alpha = 0.98
                            cell.alpha = 0.0
                            
                        }, completion: { (finished) -> Void in
                            if finished { cell.isHidden = true }
                        })
                    }
                    
                case UIGestureRecognizerState.changed:
                    var center = My.cellSnapshot!.center
                    center.y   = locationInView.y
                    
                    My.cellSnapshot!.center = center
                    
                    if indexPath != Path.initialIndexPath {
                        if let initial = Path.initialIndexPath {
                            let pom = zones[indexPath.row]
                            zones[indexPath.row] = zones[initial.row]
                            zones[initial.row]   = pom
                            let id = zones[indexPath.row].orderId
                            zones[indexPath.row].orderId = zones[initial.row].orderId
                            zones[initial.row].orderId   = id
                            CoreDataController.sharedInstance.saveChanges()
                        }
                        
                        importZoneTableView.moveRow(at: Path.initialIndexPath!, to: indexPath)
                        Path.initialIndexPath = indexPath
                    }
                    
                default:
                    if let cell = importZoneTableView.cellForRow(at: Path.initialIndexPath!) as? ImportZoneTableViewCell {
                        cell.isHidden = false
                        cell.alpha    = 0.0
                        
                        UIView.animate(withDuration: 0.25, animations: { () -> Void in
                            
                            My.cellSnapshot!.center    = cell.center
                            My.cellSnapshot!.transform = CGAffineTransform.identity
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
            }
        }
    }
    
    @objc func isVisibleValueChanged (_ sender:UISwitch) {
        if sender.isOn == true { zones[sender.tag].isVisible = true } else { zones[sender.tag].isVisible = false }
        CoreDataController.sharedInstance.saveChanges()
        importZoneTableView.reloadData()
    }
    
    @objc func chooseGateway (_ gestureRecognizer:UIGestureRecognizer) {
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
            if let moc = appDel.managedObjectContext {
                if let results = try moc.fetch(fetchRequest) as? [IBeacon] {
                    return results[0]
                }
            }
        } catch let catchedError as NSError {
            error = catchedError
        }
        return nil
    }
    
    func addAddressFinished(_ address: Address) {
        do {
            var gatewayForScan:Gateway?
            guard let location = location else { return }
            guard let gateways = location.gateways?.allObjects as? [Gateway] else { return }
            
            for gate in gateways {
                if gate.addressOne.intValue == address.firstByte && gate.addressTwo.intValue == address.secondByte && gate.addressThree.intValue == address.thirdByte { gatewayForScan = gate }
            }
            
            guard let gateway = gatewayForScan else { self.view.makeToast(message: "No gateway with address"); return }
            
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
    @objc func checkIfGatewayDidGetZones (_ timer:Foundation.Timer) {
        guard var zoneId = timer.userInfo as? Int else { return }
        
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 4 {  // sve dok ne pokusa tri puta, treba da pokusava
            scanZones?.sendCommandForFinding(id:Byte(zoneId))
            setProgressBarParametarsForScanningZones(id: zoneId)
            zoneScanTimer!.invalidate()
            zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: zoneId, repeats: false)
            timesRepeatedCounter += 1
        } else {
            if (zoneId+1) > scanZones?.to { // Ako je poslednji
                dismissScaningControls()
            } else {
                //ima jos
                zoneId += 1
                scanZones?.sendCommandForFinding(id:Byte(zoneId))
                setProgressBarParametarsForScanningZones(id: zoneId)
                zoneScanTimer!.invalidate()
                zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportZoneViewController.checkIfGatewayDidGetZones(_:)), userInfo: zoneId, repeats: false)
                timesRepeatedCounter = 1
            }
        }
    }
    @objc func zoneReceivedFromGateway (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForZones) {
            guard var zoneId = notification.userInfo as? [String:Int] else { return }
            
            timesRepeatedCounter = 0
            if zoneId["zoneId"] >= scanZones?.to {
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
        guard let from = Int(from), let to = Int(to) else { throw InputError.notConvertibleToInt }
        
        if from < 0 || to < 0 { throw InputError.notPositiveNumbers }
        if from > to { throw InputError.fromBiggerThanTo }
        
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
    
    func editZoneFInished() {
        refreshZoneList()
    }
    
    func progressBarDidPressedExit () {
        dismissScaningControls()
    }
    
}

// MARK: - TextField Delegate
extension ImportZoneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString     = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

// MARK: - ImportZone TableView Cell
class ImportZoneTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var btnZonePicker: CustomGradientButton!
    @IBOutlet weak var tagsButton: CustomGradientButton!
    
    
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var zoneItem:Zone!
    
    func setItem(_ zone: Zone, tag: Int, location: Location) {
        backgroundColor = .clear
        var name = ""
        if let id = zone.level?.intValue {
            if id != 0 {
                if let level = DatabaseZoneController.shared.getZoneById(id, location: location) { name = level.name! + " " }
            }
        }
        
        lblName.text = name + "\(zone.name!)"
        lblLevel.text = zone.zoneDescription
        lblNo.text = "\(zone.id!)"
        switchVisible.isOn = zone.isVisible.boolValue
        switchVisible.tag = tag
        btnZonePicker.setTitle("Add iBeacon", for: [])
        tagsButton.setTitle("Tags", for: [])
        
        if let iBeaconName = zone.iBeacon?.name { btnZonePicker.setTitle(iBeaconName, for: UIControlState()) }
        btnZonePicker.tag = tag
        
        self.zoneItem = zone
        if let type = TypeOfControl(rawValue: (zone.allowOption.intValue)) {
            controlTypeButton.setTitle(type.description, for: UIControlState())
        }
    }
    
    @IBAction func changeControlType(_ sender: AnyObject) {
        if zoneItem.allowOption.intValue == 1 {
            DatabaseZoneController.shared.changeAllowOption(2, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.confirm.description , for: UIControlState())
            return
        }
        if zoneItem.allowOption.intValue == 2 {
            DatabaseZoneController.shared.changeAllowOption(3, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.notAllowed.description , for: UIControlState())
            return
        }
        if zoneItem.allowOption.intValue == 3 {
            DatabaseZoneController.shared.changeAllowOption(1, zone: zoneItem)
            controlTypeButton.setTitle(TypeOfControl.allowed.description , for: UIControlState())
            return
        }
    }
    
    
    
}
