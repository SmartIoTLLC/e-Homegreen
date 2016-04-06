//
//  ImportCategoryViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

//IPGCW02001_000_000_Categories List
class ImportCategoryViewController: UIViewController, ImportFilesDelegate, EditCategoryDelegate, AddAddressDelegate, ProgressBarDelegate {
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var categories:[Category] = []
    var location:Location?
    
    @IBOutlet weak var importCategoryTableView: UITableView!
    
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    var scanZones:ScanFunction?
    var zoneScanTimer:NSTimer?
    var idToSearch:Int?
    var timesRepeatedCounter:Int = 0
    
    var pbSZ:ProgressBarVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        refreshCategoryList()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        addObservers()
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "categoryReceivedFromGateway:", name: NotificationKey.DidReceiveCategoryFromGateway, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForCategories)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "categoryReceivedFromGateway:", object: nil)
    }
    
    @IBAction func btnScanCategories(sender: AnyObject) {
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
            scanZones = ScanFunction(from: sp.from, to: sp.to, gateway: gateway, scanForWhat: .Category)
            pbSZ = ProgressBarVC(title: "Scanning Categories", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbSZ?.delegate = self
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningForCategories)
            scanZones?.sendCommandForFinding(id:Byte(sp.from))
            idToSearch = sp.from
            zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: idToSearch, repeats: false)
            timesRepeatedCounter = 1
            self.presentViewController(pbSZ!, animated: true, completion: nil)
            UIApplication.sharedApplication().idleTimerDisabled = true
            
            
        }catch let error as InputError {
            
        } catch {
            
        }
    }
    
    func categoryReceivedFromGateway (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningForZones) {
            if let zoneId = notification.userInfo as? [String:Int] {
                if zoneId["zoneId"] > idToSearch {
                    // nesto nije dobro
                    dismissScaningControls()
                    
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
                    refreshCategoryList()
                    return
                }
                if zoneId["zoneId"] < idToSearch {
                    // nesto nije dobro
                    dismissScaningControls()
                    
                }
            }
        }
    }
    
    func checkIfGatewayDidGetCategory (timer:NSTimer) {
        if let zoneId = timer.userInfo as? Int {
            if zoneId > idToSearch {
                // nesto nije dobro
                dismissScaningControls()
                
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
                        zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: idToSearch, repeats: false)
                        timesRepeatedCounter = 1
                    }
                } else {
                    scanZones?.sendCommandForFinding(id:Byte(idToSearch!))
                    setProgressBarParametarsForScanningZones(id: idToSearch!)
                    zoneScanTimer!.invalidate()
                    zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: idToSearch, repeats: false)
                    timesRepeatedCounter += 1
                }
                return
            }
            if zoneId < idToSearch {
                // nesto nije dobro
                dismissScaningControls()
                
            }
        }
    }
    
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        idToSearch = 0
        zoneScanTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForZones)
        pbSZ?.dissmissProgressBar()
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func setProgressBarParametarsForScanningZones(id zoneId:Int) {
        var index:Int = zoneId
        index = index - scanZones!.from + 1
        let howMuchOf = scanZones!.to - scanZones!.from + 1
        pbSZ?.lblHowMuchOf.text = "\(index) / \(howMuchOf)"
        pbSZ?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(index)/Float(howMuchOf)*100) + " %"
        pbSZ?.progressView.progress = Float(index)/Float(howMuchOf)
    }
    
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
    
    func progressBarDidPressedExit() {
        
    }
    
    @IBAction func brnDeleteAll(sender: AnyObject) {
        for category in categories{
            appDel.managedObjectContext!.deleteObject(category)
        }

        createCategories()
        saveChanges()
        refreshCategoryList()
    }
    
    @IBAction func btnCleearFields(sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    
    func backURL(strText: String) {
//        First - Delete all categories
//        for var item = 0; item < categories.count; item++ {
//            if categories[item].gateway!.objectID == gateway!.objectID {
//                appDel.managedObjectContext!.deleteObject(categories[item])
//            }
//        }
//        Second - Take default categories from bundle
        let categoriesJSONBundle = DataImporter.createCategoriesFromFileFromNSBundle()
//        Third - Add new zones and edit zones from bundle if needed
        if var categoriesJSON = DataImporter.createCategoriesFromFile(strText) {
            if categoriesJSON.count != 0 {
                for categoryJsonBundle in categoriesJSONBundle! {
                    var isExisting = false
                    for categoryJSON in categoriesJSON {
                        if categoryJsonBundle.id == categoryJSON.id {
                            isExisting = true
                        }
                    }
                    if !isExisting {
                        categoriesJSON.append(categoryJsonBundle)
                    }
                }
                for categoryJSON in categoriesJSON {
                    let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                    category.id = categoryJSON.id
                    category.name = categoryJSON.name
                    category.categoryDescription = categoryJSON.description
                    if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                        category.isVisible = NSNumber(bool: false)
                    } else {
                        category.isVisible = NSNumber(bool: true)
                    }
//                    category.gateway = gateway!
                    saveChanges()
                }
            } else {
//                createCategories(gateway!)
            }
        } else {
//            createCategories(gateway!)
        }
        refreshCategoryList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
    }
    
    func createCategories() {
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: false), location, categoryJSON.id)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: true), location, categoryJSON.id)
                }
                saveChanges()
            }
        }
    }
    
    func refreshCategoryList () {
        updateCategoryList()
        importCategoryTableView.reloadData()
    }
    
    @IBAction func addCategory(sender: AnyObject) {
        showEditCategory(nil, location: location).delegate = self
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editCategoryFInished() {
        refreshCategoryList()
    }
    
    func updateCategoryList () {
        
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        let predicate = NSPredicate(format: "location == %@", location!)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            categories = fetResults!
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
            categories[sender.tag].isVisible = true
        }else {
            categories[sender.tag].isVisible = false
        }
        saveChanges()
        importCategoryTableView.reloadData()
    }

}
extension ImportCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showEditCategory(categories[indexPath.row], location: nil).delegate = self
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if ((categories[indexPath.row].id as! Int) >= 1 && (categories[indexPath.row].id as! Int) <= 19) || (categories[indexPath.row].id as! Int) == 255 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(categories[indexPath.row])
            appDel.saveContext()
            refreshCategoryList()
        }
    }
}

extension ImportCategoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = importCategoryTableView.dequeueReusableCellWithIdentifier("importCategory") as? ImportCategoryTableViewCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblName.text = "\(categories[indexPath.row].id!)" + ", \(categories[indexPath.row].name!)"
            cell.lblDescription.text = categories[indexPath.row].categoryDescription
//            cell.switchVisible.on = categories[indexPath.row].isVisible.boolValue
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.addTarget(self, action: "isVisibleValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
//        cell.textLabel?.text = "\(categories[indexPath.row].id). \(categories[indexPath.row].name), Desc: \(categories[indexPath.row].categoryDescription)"
//        cell.backgroundColor = UIColor.clearColor()
//        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}
class ImportCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var switchEnable: UISwitch!
    @IBOutlet weak var switchVisible: UISwitch!
    
}
