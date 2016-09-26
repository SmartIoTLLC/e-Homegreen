//
//  ImportCategoryViewController.swift
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

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
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


enum TypeOfControl:Int{
    case allowed = 1, confirm, notAllowed
    var description:String{
        switch self{
        case .allowed: return "Allowed"
        case .confirm: return "Confirm"
        case .notAllowed: return "Not Allowed"
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
    var zoneScanTimer:Foundation.Timer?
    var timesRepeatedCounter:Int = 0
    
    var pbSZ:ProgressBarVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFrom.delegate = self
        txtTo.delegate = self
        
        txtFrom.inputAccessoryView = CustomToolBar()
        txtTo.inputAccessoryView = CustomToolBar()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        let longpress = UILongPressGestureRecognizer(target: self, action:#selector(ImportCategoryViewController.longPressGestureRecognized(_:)))
        importCategoryTableView.addGestureRecognizer(longpress)
        
        refreshCategoryList()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    func endEditingNow(){
        txtFrom.resignFirstResponder()
        txtTo.resignFirstResponder()
    }
    
    //move tableview cell on hold and swipe
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer){
        
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: importCategoryTableView)
        let indexPath = importCategoryTableView.indexPathForRow(at: locationInView)
        
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
                let cell = importCategoryTableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshopOfCell(cell!)
                var center = cell?.center
                
                My.cellSnapshot!.center = center!
                My.cellSnapshot!.alpha = 0.0
                importCategoryTableView.addSubview(My.cellSnapshot!)

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
                    let pom = categories[(index as NSIndexPath).row]
                    categories[(index as NSIndexPath).row] = categories[(initial as NSIndexPath).row]
                    categories[(initial as NSIndexPath).row] = pom
                    let id = categories[(index as NSIndexPath).row].orderId
                    categories[(index as NSIndexPath).row].orderId = categories[(initial as NSIndexPath).row].orderId
                    categories[(initial as NSIndexPath).row].orderId = id
                    CoreDataController.shahredInstance.saveChanges()
                    
                }
                
                importCategoryTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
                
            }
            
        default:
            let cell = importCategoryTableView.cellForRow(at: Path.initialIndexPath!) as! ImportCategoryTableViewCell!
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
        NotificationCenter.default.addObserver(self, selector: #selector(ImportCategoryViewController.categoryReceivedFromGateway(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveCategoryFromGateway), object: nil)
    }
    func removeObservers() {
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningForCategories)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "categoryReceivedFromGateway:"), object: nil)
    }
    
    @IBAction func brnDeleteAll(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all devices?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                for category in self.categories{
                    self.appDel.managedObjectContext!.delete(category)
                }
                
                self.createCategories()
                CoreDataController.shahredInstance.saveChanges()
                self.refreshCategoryList()
            }
        }
    }
    @IBAction func btnCleearFields(_ sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    @IBAction func btnImportFile(_ sender: AnyObject) {
        showImportFiles().delegate = self
    }
    @IBAction func addCategory(_ sender: AnyObject) {
        showEditCategory(nil, location: location).delegate = self
    }
    @IBAction func doneAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnScanCategories(_ sender: AnyObject) {
        showAddAddress(ScanType.categories).delegate = self
    }
    func addAddressFinished(_ address: Address) {
        do {
            var gatewayForScan:Gateway?
            if let location = location{
                if let gateways = location.gateways?.allObjects as? [Gateway]{
                    for gate in gateways{
                        if Int(gate.addressOne) == address.firstByte && Int(gate.addressTwo) == address.secondByte && Int(gate.addressThree) == address.thirdByte{
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
            scanZones = ScanFunction(from: sp.from, to: sp.to, gateway: gateway, scanForWhat: .category)
            pbSZ = ProgressBarVC(title: "Scanning Categories", percentage: sp.initialPercentage, howMuchOf: "1 / \(sp.count)")
            pbSZ?.delegate = self
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningForCategories)
            scanZones?.sendCommandForFinding(id:Byte(sp.from))
            zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: sp.from, repeats: false)
            timesRepeatedCounter = 1
            self.present(pbSZ!, animated: true, completion: nil)
            UIApplication.shared.isIdleTimerDisabled = true
        } catch {
            
        }
    }
    func categoryReceivedFromGateway (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningForZones) {
            guard var categoryId = (notification as NSNotification).userInfo as? [String:Int] else {
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
                zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: newCategoryId, repeats: false)
                timesRepeatedCounter = 1
            }
            refreshCategoryList()
            return
        }
    }
    func checkIfGatewayDidGetCategory (_ timer:Foundation.Timer) {
        guard var categoryId = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 4 {  // sve dok ne pokusa tri puta, treba da pokusava
            scanZones?.sendCommandForFinding(id:Byte(categoryId))
            setProgressBarParametarsForScanningZones(id: categoryId)
            zoneScanTimer!.invalidate()
            zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: categoryId, repeats: false)
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
                zoneScanTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ImportCategoryViewController.checkIfGatewayDidGetCategory(_:)), userInfo: categoryId, repeats: false)
                timesRepeatedCounter = 1
            }
        }
    }
    
    
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        zoneScanTimer?.invalidate()
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningForZones)
        pbSZ?.dissmissProgressBar()
        UIApplication.shared.isIdleTimerDisabled = false
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
    func progressBarDidPressedExit() {
        dismissScaningControls()
    }
    
    
    func backURL(_ strText: String) {
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
                    let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as! Category
                    category.id = categoryJSON.id as NSNumber?
                    category.name = categoryJSON.name
                    category.categoryDescription = categoryJSON.description
                    category.allowOption = 3
                    if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                        category.isVisible = NSNumber(value: false as Bool)
                    } else {
                        category.isVisible = NSNumber(value: true as Bool)
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
                let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: false as Bool), location, categoryJSON.id as NSNumber?, 3)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: true as Bool), location, categoryJSON.id as NSNumber?, 3)
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
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let sortDescriptorTwo = NSSortDescriptor(key: "orderId", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        let predicate = NSPredicate(format: "location == %@", location!)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Category]
            categories = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func isVisibleValueChanged (_ sender:UISwitch) {
        if sender.isOn == true {
            categories[sender.tag].isVisible = true
        }else {
            categories[sender.tag].isVisible = false
        }
        CoreDataController.shahredInstance.saveChanges()
        importCategoryTableView.reloadData()
    }
}

extension ImportCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditCategory(categories[(indexPath as NSIndexPath).row], location: nil).delegate = self
    }
}

extension ImportCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = importCategoryTableView.dequeueReusableCell(withIdentifier: "importCategory") as? ImportCategoryTableViewCell {
            cell.backgroundColor = UIColor.clear
            cell.lblName.text = "\(categories[(indexPath as NSIndexPath).row].name!)"
            cell.lblNo.text = "\(categories[(indexPath as NSIndexPath).row].id!)"
            cell.lblDescription.text = categories[(indexPath as NSIndexPath).row].categoryDescription
            cell.setItem(categories[(indexPath as NSIndexPath).row])
            cell.switchVisible.tag = (indexPath as NSIndexPath).row
            cell.switchVisible.isOn = Bool(categories[(indexPath as NSIndexPath).row].isVisible)
            cell.switchVisible.addTarget(self, action: #selector(ImportCategoryViewController.isVisibleValueChanged(_:)), for: UIControlEvents.valueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if ((categories[(indexPath as NSIndexPath).row].id as! Int) >= 1 && (categories[(indexPath as NSIndexPath).row].id as! Int) <= 19) || (categories[(indexPath as NSIndexPath).row].id as! Int) == 255 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appDel.managedObjectContext?.delete(categories[(indexPath as NSIndexPath).row])
            appDel.saveContext()
            refreshCategoryList()
        }
    }
}

class ImportCategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var controlTypeButton: CustomGradientButton!
    var category:Category!
    
    func setItem(_ category: Category){
        self.category = category
        if let type = TypeOfControl(rawValue: (category.allowOption.intValue)){
            controlTypeButton.setTitle(type.description, for: UIControlState())
        }
    }
    
    @IBAction func changeControlType(_ sender: AnyObject) {
        if category.allowOption.intValue == 1{
            DatabaseCategoryController.shared.changeAllowOption(2, category: category)
            controlTypeButton.setTitle(TypeOfControl.confirm.description , for: UIControlState())
            return
        }
        if category.allowOption.intValue == 2{
            DatabaseCategoryController.shared.changeAllowOption(3, category: category)
            controlTypeButton.setTitle(TypeOfControl.notAllowed.description , for: UIControlState())
            return
        }
        if category.allowOption.intValue == 3{
            DatabaseCategoryController.shared.changeAllowOption(1, category: category)
            controlTypeButton.setTitle(TypeOfControl.allowed.description , for: UIControlState())
            return
        }
    }
}
