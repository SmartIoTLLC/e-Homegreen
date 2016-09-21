//
//  ImportCategoryViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

enum TypeOfControl:Int{
    case Allowed = 1, Confirm, NotAllowed
    var description:String{
        switch self{
        case Allowed: return "Allowed"
        case Confirm: return "Confirm"
        case NotAllowed: return "Not Allowed"
        }
    }
}

//IPGCW02001_000_000_Categories List
class ImportCategoryViewController: UIViewController, ImportFilesDelegate, EditCategoryDelegate, AddAddressDelegate, ProgressBarDelegate, UITextFieldDelegate {
    var appDel:AppDelegate!
    var error:NSError? = nil
    var categories:[Category] = []
    var location:Location?
    
    @IBOutlet weak var importCategoryTableView: UITableView!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    var scanZones:ScanFunction?
    var zoneScanTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    
    var pbSZ:ProgressBarVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFrom.delegate = self
        txtTo.delegate = self
        
        txtFrom.inputAccessoryView = CustomToolBar()
        txtTo.inputAccessoryView = CustomToolBar()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        let longpress = UILongPressGestureRecognizer(target: self, action:#selector(ImportCategoryViewController.longPressGestureRecognized(_:)))
        importCategoryTableView.addGestureRecognizer(longpress)
        
        refreshCategoryList()
        
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    override func viewWillAppear(animated: Bool) {
        addObservers()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    func endEditingNow(){
        txtFrom.resignFirstResponder()
        txtTo.resignFirstResponder()
    }
    
    //move tableview cell on hold and swipe
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer){
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(importCategoryTableView)
        let indexPath = importCategoryTableView.indexPathForRowAtPoint(locationInView)
        
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
                let cell = importCategoryTableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell)
                var center = cell.center
                
                My.cellSnapshot!.center = center
                My.cellSnapshot!.alpha = 0.0
                importCategoryTableView.addSubview(My.cellSnapshot!)

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
                    let pom = categories[index.row]
                    categories[index.row] = categories[initial.row]
                    categories[initial.row] = pom
                    let id = categories[index.row].orderId
                    categories[index.row].orderId = categories[initial.row].orderId
                    categories[initial.row].orderId = id
                    CoreDataController.shahredInstance.saveChanges()
                    
                }
                
                importCategoryTableView.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                Path.initialIndexPath = indexPath
                
            }
            
        default:
            let cell = importCategoryTableView.cellForRowAtIndexPath(Path.initialIndexPath!) as! ImportCategoryTableViewCell!
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
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImportCategoryViewController.categoryReceivedFromGateway(_:)), name: NotificationKey.DidReceiveCategoryFromGateway, object: nil)
    }
    func removeObservers() {
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForCategories)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "categoryReceivedFromGateway:", object: nil)
    }
    
    @IBAction func brnDeleteAll(sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all devices?") { (action) in
            if action == ReturnedValueFromAlertView.Delete {
                for category in self.categories{
                    self.appDel.managedObjectContext!.deleteObject(category)
                }
                
                self.createCategories()
                CoreDataController.shahredInstance.saveChanges()
                self.refreshCategoryList()
            }
        }
    }
    @IBAction func btnCleearFields(sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
    }
    @IBAction func addCategory(sender: AnyObject) {
        showEditCategory(nil, location: location).delegate = self
    }
    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnScanCategories(sender: AnyObject) {
        showAddAddress(ScanType.Categories).delegate = self
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
            zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: sp.from, repeats: false)
            timesRepeatedCounter = 1
            self.presentViewController(pbSZ!, animated: true, completion: nil)
            UIApplication.sharedApplication().idleTimerDisabled = true
        } catch {
            
        }
    }
    func categoryReceivedFromGateway (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningForZones) {
            guard var categoryId = notification.userInfo as? [String:Int] else {
                return
            }
            timesRepeatedCounter = 0
            if categoryId["categoryId"] >= scanZones?.to{
                //gotovo
                dismissScaningControls()
            } else {
                //ima jos
                let newCategoryId = categoryId["zoneId"]! + 1
                scanZones?.sendCommandForFinding(id:Byte(newCategoryId))
                setProgressBarParametarsForScanningZones(id: newCategoryId)
                zoneScanTimer!.invalidate()
                zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: newCategoryId, repeats: false)
                timesRepeatedCounter = 1
            }
            refreshCategoryList()
            return
        }
    }
    func checkIfGatewayDidGetCategory (timer:NSTimer) {
        guard var categoryId = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 4 {  // sve dok ne pokusa tri puta, treba da pokusava
            scanZones?.sendCommandForFinding(id:Byte(categoryId))
            setProgressBarParametarsForScanningZones(id: categoryId)
            zoneScanTimer!.invalidate()
            zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: categoryId, repeats: false)
            timesRepeatedCounter += 1
        }else{
            if (categoryId+1) > scanZones?.to { // Ako je poslednji
                dismissScaningControls()
            } else {
                //ima jos
                categoryId += 1
                scanZones?.sendCommandForFinding(id:Byte(categoryId))
                setProgressBarParametarsForScanningZones(id: categoryId)
                zoneScanTimer!.invalidate()
                zoneScanTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: categoryId, repeats: false)
                timesRepeatedCounter = 1
            }
        }
    }
    
    
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        zoneScanTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningForZones)
        pbSZ?.dissmissProgressBar()
        UIApplication.sharedApplication().idleTimerDisabled = false
        refreshCategoryList()
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
        dismissScaningControls()
    }
    
    
    func backURL(strText: String) {
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
                    category.allowOption = 3
                    if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                        category.isVisible = NSNumber(bool: false)
                    } else {
                        category.isVisible = NSNumber(bool: true)
                    }
                    CoreDataController.shahredInstance.saveChanges()
                }
            }
        }
        refreshCategoryList()
    }
    func createCategories() {
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: false), location, categoryJSON.id, 3)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: true), location, categoryJSON.id, 3)
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    func refreshCategoryList () {
        updateCategoryList()
        importCategoryTableView.reloadData()
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
    
    func isVisibleValueChanged (sender:UISwitch) {
        if sender.on == true {
            categories[sender.tag].isVisible = true
        }else {
            categories[sender.tag].isVisible = false
        }
        CoreDataController.shahredInstance.saveChanges()
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
            cell.lblName.text = "\(categories[indexPath.row].name!)"
            cell.lblNo.text = "\(categories[indexPath.row].id!)"
            cell.lblDescription.text = categories[indexPath.row].categoryDescription
            cell.setItem(categories[indexPath.row])
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.on = Bool(categories[indexPath.row].isVisible)
            cell.switchVisible.addTarget(self, action: #selector(ImportCategoryViewController.isVisibleValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}

class ImportCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var category:Category!
    
    func setItem(category: Category){
        self.category = category
        if let type = TypeOfControl(rawValue: (category.allowOption.integerValue)){
            controlTypeButton.setTitle(type.description, forState: .Normal)
        }
    }
    
    @IBAction func changeControlType(sender: AnyObject) {
        if category.allowOption.integerValue == 1{
            DatabaseCategoryController.shared.changeAllowOption(2, category: category)
            controlTypeButton.setTitle(TypeOfControl.Confirm.description , forState: .Normal)
            return
        }
        if category.allowOption.integerValue == 2{
            DatabaseCategoryController.shared.changeAllowOption(3, category: category)
            controlTypeButton.setTitle(TypeOfControl.NotAllowed.description , forState: .Normal)
            return
        }
        if category.allowOption.integerValue == 3{
            DatabaseCategoryController.shared.changeAllowOption(1, category: category)
            controlTypeButton.setTitle(TypeOfControl.Allowed.description , forState: .Normal)
            return
        }
    }
}
