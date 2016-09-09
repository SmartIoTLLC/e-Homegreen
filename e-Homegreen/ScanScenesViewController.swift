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
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var scenes:[Scene] = []
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var selected:AnyObject?
    
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
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateSceneList()
        
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
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateSceneList()
        sceneTableView.reloadData()
    }
    
    override func sendSearchBarText(text: String) {
        updateSceneList()
        if !text.isEmpty{
            scenes = self.scenes.filter() {
                scene in
                if scene.sceneName.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        
        sceneTableView.reloadData()
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
        updateSceneList()
        sceneTableView.reloadData()
    }
    
    func updateSceneList() {
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "sceneZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "sceneCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            scenes = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = FilterController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = FilterController.shared.getCategoriesByLocation(gateway.location)
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
            let list:[Zone] = FilterController.shared.getZoneByLevel(gateway.location, parentZone: level)
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
                var itExists = false
                var existingScene:Scene?
                for scene in scenes {
                    if scene.sceneId == sceneId && scene.address == address {
                        itExists = true
                        existingScene = scene
                    }
                }
                if !itExists {
                    let scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
                    scene.sceneId = sceneId
                    scene.sceneName = sceneName
                    scene.address = address
                    
                    if let customImageOne = customImageOne{
                        scene.sceneImageOneCustom = customImageOne
                        scene.sceneImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        scene.sceneImageOneDefault = def
                        scene.sceneImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            scene.sceneImageOneCustom = image.imageId
                            scene.sceneImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        scene.sceneImageTwoCustom = customImageTwo
                        scene.sceneImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        scene.sceneImageTwoDefault = def
                        scene.sceneImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            scene.sceneImageTwoCustom = image.imageId
                            scene.sceneImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    scene.entityLevelId = level?.id
                    scene.sceneZoneId = zoneSelected?.id
                    scene.sceneCategoryId = category?.id

                    scene.isBroadcast = broadcastSwitch.on
                    scene.isLocalcast = localcastSwitch.on
                    scene.entityLevel = btnLevel.titleLabel!.text!
                    scene.sceneZone = btnZone.titleLabel!.text!
                    scene.sceneCategory = btnCategory.titleLabel!.text!
                    scene.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshSceneList()
                } else {
                    existingScene!.sceneId = sceneId
                    existingScene!.sceneName = sceneName
                    existingScene!.address = address
                    if let customImageOne = customImageOne{
                        existingScene!.sceneImageOneCustom = customImageOne
                        existingScene!.sceneImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        existingScene!.sceneImageOneDefault = def
                        existingScene!.sceneImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingScene!.sceneImageOneCustom = image.imageId
                            existingScene!.sceneImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        existingScene!.sceneImageTwoCustom = customImageTwo
                        existingScene!.sceneImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        existingScene!.sceneImageTwoDefault = def
                        existingScene!.sceneImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingScene!.sceneImageTwoCustom = image.imageId
                            existingScene!.sceneImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    existingScene!.entityLevelId = level?.id
                    existingScene!.sceneZoneId = zoneSelected?.id
                    existingScene!.sceneCategoryId = category?.id
                    
                    existingScene!.isBroadcast = broadcastSwitch.on
                    existingScene!.isLocalcast = localcastSwitch.on
                    existingScene!.entityLevel = btnLevel.titleLabel!.text!
                    existingScene!.sceneZone = btnZone.titleLabel!.text!
                    existingScene!.sceneCategory = btnCategory.titleLabel!.text!
                    existingScene!.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshSceneList()
                }
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func scanScenes(sender: AnyObject) {
        findScenes()
    }
    
    @IBAction func clearRangeFields(sender: AnyObject) {
        
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if scenes.count != 0 {
            for scene in scenes {
                appDel.managedObjectContext!.deleteObject(scene)
            }
            CoreDataController.shahredInstance.saveChanges()
            refreshSceneList()
        }
        self.view.endEditing(true)
    }
    
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var scenesTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    var arrayOfScenesToBeSearched = [Int]()
    var indexOfScenesToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenScenes: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    func findScenes() {
        do {
            arrayOfScenesToBeSearched = [Int]()
            indexOfScenesToBeSearched = 0
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningSceneNameAndParameters)
            
            if devAddressOne.text != nil && devAddressOne.text != ""{
                addressOne = Int(devAddressOne.text!)!
            }
            if devAddressTwo.text != nil && devAddressTwo.text != ""{
                addressTwo = Int(devAddressTwo.text!)!
            }
            if devAddressThree.text != nil && devAddressThree.text != ""{
                addressThree = Int(devAddressThree.text!)!
            }
            var from = 0
            var to = 250
            if fromTextField.text != nil && fromTextField.text != ""{
                from = Int(fromTextField.text!)!
            }
            if toTextField.text != nil && toTextField.text != ""{
                to = Int(toTextField.text!)!
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
                sendCommandWithSceneAddress(firstSceneIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    
    // Called from findNames or from it self.
    // Checks which scene ID should be searched for and calls sendCommandForFindingNames for that specific scene id.
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
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningSceneNameAndParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["sceneId"] else{
                return
            }
            guard let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfSceneIndexInArrayOfNamesToBeSearched+1 < arrayOfScenesToBeSearched.count{ // if next exists
                indexOfScenesToBeSearched = indexOfSceneIndexInArrayOfNamesToBeSearched+1
                let nextSceneIndexToBeSearched = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                
                timesRepeatedCounter = 0
                scenesTimer?.invalidate()
                scenesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextSceneIndexToBeSearched)")
                sendCommandWithSceneAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
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
                        }else{
                            cell.imageOne.image = UIImage(named: "Scene - All On - 00")
                        }
                    }
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageOne.image = UIImage(named: "Scene - All On - 00")
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }else{
                    cell.imageOne.image = UIImage(named: "Scene - All On - 00")
                }
            }
            
            if let id = scenes[indexPath.row].sceneImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageTwo.image = UIImage(named: "Scene - All On - 01")
                        }
                    }
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageTwo.image = UIImage(named: "Scene - All On - 01")
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }else{
                    cell.imageTwo.image = UIImage(named: "Scene - All On - 01")
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = scenes[indexPath.row]
        IDedit.text = "\(scenes[indexPath.row].sceneId)"
        nameEdit.text = "\(scenes[indexPath.row].sceneName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(scenes[indexPath.row].address)))"
        broadcastSwitch.on = scenes[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = scenes[indexPath.row].isLocalcast.boolValue
        
        if let levelId = scenes[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
        }
        if let zoneId = scenes[indexPath.row].sceneZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
        }
        if let categoryId = scenes[indexPath.row].sceneCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
        }
        
        if let level = scenes[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = scenes[indexPath.row].sceneZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }
        if let category = scenes[indexPath.row].sceneCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }
        if let id = scenes[indexPath.row].sceneImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "Scene - All On - 00")
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "Scene - All On - 00")
                }
            }
        }else{
            if let defaultImage = scenes[indexPath.row].sceneImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "Scene - All On - 00")
            }
        }
        
        if let id = scenes[indexPath.row].sceneImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "Scene - All On - 01")
                    }
                }
            }else{
                if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "Scene - All On - 01")
                }
            }
        }else{
            if let defaultImage = scenes[indexPath.row].sceneImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "Scene - All On - 01")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.sceneTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                presentationController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                presentationController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
            }
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(scenes[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            refreshSceneList()
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
