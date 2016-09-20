//
//  ScanScenesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanScenesViewController: PopoverVC, ProgressBarDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var sceneTableView: UITableView!
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    var scenes:[Scene] = []
    
    var searchBarText:String = ""
    
    var button:UIButton!
    
    var imageDataOne:NSData?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:NSData?
    var customImageTwo:String?
    var defaultImageTwo:String?
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshSceneList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanScenesViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanScenesViewController.handleTap(_:))))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanScenesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanScenesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanScenesViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveSceneFromGateway, object: nil)
        
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshSceneList()
    }
    
    override func sendSearchBarText(text: String) {
        searchBarText = text
        refreshSceneList()
    }
    
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            btnZone.setTitle("All", forState: .Normal)
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            break
        default:
            break
        }
        
        button.setTitle(name, forState: .Normal)
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshSceneList() {
        scenes = DatabaseScenesController.shared.updateSceneList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty{
            scenes = self.scenes.filter() {
                scene in
                if scene.sceneName.lowercaseString.rangeOfString(searchBarText.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        sceneTableView.reloadData()
    }
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnZoneAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                
                var levelId:Int?
                if let levelIdNumber = level?.id{
                    levelId = Int(levelIdNumber)
                }
                var zoneId:Int?
                if let zoneIdNumber = zoneSelected?.id{
                    zoneId = Int(zoneIdNumber)
                }
                var categoryId:Int?
                if let categoryIdNumber = category?.id{
                    categoryId = Int(categoryIdNumber)
                }
                
                DatabaseScenesController.shared.createScene(sceneId, sceneName: sceneName, moduleAddress: address, gateway: gateway, levelId: levelId, zoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.on, isLocalcast: localcastSwitch.on, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)

            }
        }
        refreshSceneList()
        self.view.endEditing(true)
    }
    
    @IBAction func scanScenes(sender: AnyObject) {
        findScenes()
    }
    
    @IBAction func clearRangeFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all scenes?") { (action) in
            if action == ReturnedValueFromAlertView.Delete{
                DatabaseScenesController.shared.deleteAllScenes(self.gateway)
                self.refreshSceneList()
                self.view.endEditing(true)
            }
        }
    }
    
    
    // MARK: - FINDING SCENES
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var scenesTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    var arrayOfScenesToBeSearched = [Int]()
    var indexOfScenesToBeSearched = 0
    var progressBarScreenScenes: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findScenes() {
        do {
            arrayOfScenesToBeSearched = [Int]()
            indexOfScenesToBeSearched = 0
            
            guard let address1Text = devAddressOne.text else{
                return
            }
            guard let address1 = Int(address1Text) else{
                return
            }
            addressOne = address1
            
            guard let address2Text = devAddressTwo.text else{
                return
            }
            guard let address2 = Int(address2Text) else{
                return
            }
            addressTwo = address2
            
            guard let address3Text = devAddressThree.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            guard let address3 = Int(address3Text) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            addressThree = address3
            guard let rangeFromText = fromTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                self.view.makeToast(message: "Range is not properly set")
                return
            }
            for i in from...to{
                arrayOfScenesToBeSearched.append(i)
            }
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfScenesToBeSearched.count != 0{
                let firstSceneIndexThatDontHaveName = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                timesRepeatedCounter = 0
                progressBarScreenScenes = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfScenesToBeSearched.count), howMuchOf: "1 / \(arrayOfScenesToBeSearched.count)")
                progressBarScreenScenes?.delegate = self
                self.presentViewController(progressBarScreenScenes!, animated: true, completion: nil)
                scenesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: firstSceneIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstSceneIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningSceneNameAndParameters)
                sendCommandWithSceneAddress(firstSceneIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findScenes or from it self.
    // Checks which scene ID should be searched for and calls sendCommandWithSceneAddress for that specific scene id.
    func checkIfSceneDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let sceneIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            scenesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: sceneIndex, repeats: false)
            NSLog("func checkIfSceneDidGetName \(sceneIndex)")
            sendCommandWithSceneAddress(sceneIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.indexOf(sceneIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfScenesToBeSearched+1 < arrayOfScenesToBeSearched.count{ // if next exists
                    indexOfScenesToBeSearched = indexOfSceneIndexInArrayOfNamesToBeSearched+1
                    let nextSceneIndexToBeSearched = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                    timesRepeatedCounter = 0
                    scenesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                    NSLog("func checkIfSceneDidGetName \(nextSceneIndexToBeSearched)")
                    sendCommandWithSceneAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }else{
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next scene ID to search for. If there is not, dismiss progres bar and end the search.
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningSceneNameAndParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let sceneIndex = info["sceneId"] else{
                return
            }
            guard let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.indexOf(sceneIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfSceneIndexInArrayOfNamesToBeSearched+1 < arrayOfScenesToBeSearched.count{ // if next exists
                indexOfScenesToBeSearched = indexOfSceneIndexInArrayOfNamesToBeSearched+1
                let nextSceneIndexToBeSearched = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                
                timesRepeatedCounter = 0
                scenesTimer?.invalidate()
                scenesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextSceneIndexToBeSearched)")
                sendCommandWithSceneAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandWithSceneAddress(sceneId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(sceneId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getSceneNameAndParametar(address, sceneId: UInt8(sceneId)) , gateway: self.gateway)
    }
    func setProgressBarParametars (sceneId:Int) {
        if let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.indexOf(sceneId){
            if let _ = progressBarScreenScenes?.lblHowMuchOf, let _ = progressBarScreenScenes?.lblPercentage, let _ = progressBarScreenScenes?.progressView{
                progressBarScreenScenes?.lblHowMuchOf.text = "\(indexOfSceneIndexInArrayOfNamesToBeSearched+1) / \(arrayOfScenesToBeSearched.count)"
                progressBarScreenScenes?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfSceneIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfScenesToBeSearched.count)*100) + " %"
                progressBarScreenScenes?.progressView.progress = Float(indexOfSceneIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfScenesToBeSearched.count)
            }
        }
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        scenesTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningSceneNameAndParameters)
        progressBarScreenScenes!.dissmissProgressBar()
        
        arrayOfScenesToBeSearched = [Int]()
        indexOfScenesToBeSearched = 0
        UIApplication.sharedApplication().idleTimerDisabled = false
        refreshSceneList()
    }
}

extension ScanScenesViewController: SceneGalleryDelegate{
    
    func backImage(image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(data: image.imageData!)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(data: image.imageData!)
        }
    }
    
    func backString(strText: String, imageIndex:Int) {
        if imageIndex == 1 {
            defaultImageOne = strText
            customImageOne = nil
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            defaultImageTwo = strText
            customImageTwo = nil
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(named: strText)
        }
    }
    
    func backImageFromGallery(data: NSData, imageIndex:Int ) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = nil
            imageDataOne = data
            self.imageSceneOne.image = UIImage(data: data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = nil
            imageDataTwo = data
            self.imageSceneTwo.image = UIImage(data: data)
        }
    }
}

extension ScanScenesViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanScenesViewController:  UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(scenes[indexPath.row].sceneId)"
            cell.labelName.text = "\(scenes[indexPath.row].sceneName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(scenes[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(scenes[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(scenes[indexPath.row].address)))"
            
            if let id = scenes[indexPath.row].sceneImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = scenes[indexPath.row].sceneImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        IDedit.text = "\(scenes[indexPath.row].sceneId)"
        nameEdit.text = "\(scenes[indexPath.row].sceneName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(scenes[indexPath.row].address)))"
        broadcastSwitch.on = scenes[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = scenes[indexPath.row].isLocalcast.boolValue
        
        if let levelId = scenes[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        if let zoneId = scenes[indexPath.row].sceneZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        if let categoryId = scenes[indexPath.row].sceneCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        defaultImageOne = scenes[indexPath.row].sceneImageOneDefault
        customImageOne = scenes[indexPath.row].sceneImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = scenes[indexPath.row].sceneImageTwoDefault
        customImageTwo = scenes[indexPath.row].sceneImageTwoCustom
        imageDataTwo = nil
        
        if let id = scenes[indexPath.row].sceneImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = scenes[indexPath.row].sceneImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            self.tableView(self.sceneTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            DatabaseScenesController.shared.deleteScene(scenes[indexPath.row])
            scenes.removeAtIndex(indexPath.row)
            sceneTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

class SceneCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
        
}
