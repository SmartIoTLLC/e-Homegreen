//
//  ScanSequencesesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanSequencesesViewController: PopoverVC, ProgressBarDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var editCycle: UITextField!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var sequencesTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var gateway:Gateway!
    var sequences:[Sequence] = []
    
    var selected:AnyObject?
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var imageDataOne:NSData?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:NSData?
    var customImageTwo:String?
    var defaultImageTwo:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateSequenceList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        editCycle.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanSequencesesViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveSequenceFromGateway, object: nil)
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateSequenceList()
        sequencesTableView.reloadData()
    }
    
    override func sendSearchBarText(text: String) {
        updateSequenceList()
        if !text.isEmpty{
            sequences = self.sequences.filter() {
                sequence in
                if sequence.sequenceName.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        sequencesTableView.reloadData()
        
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshSequenceList() {
        updateSequenceList()
        sequencesTableView.reloadData()
    }
    
    func updateSequenceList() {
        let fetchRequest = NSFetchRequest(entityName: "Sequence")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "sequenceZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            sequences = fetResults!
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
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!), let cycles = Int(editCycle.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingSequence:Sequence?
                for sequence in sequences {
                    if sequence.sequenceId == sceneId && sequence.address == address {
                        itExists = true
                        existingSequence = sequence
                    }
                }
                if !itExists {
                    let sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
                    sequence.sequenceId = sceneId
                    sequence.sequenceName = sceneName
                    sequence.address = address
                    
                    if let customImageOne = customImageOne{
                        sequence.sequenceImageOneCustom = customImageOne
                        sequence.sequenceImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        sequence.sequenceImageOneDefault = def
                        sequence.sequenceImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            sequence.sequenceImageOneCustom = image.imageId
                            sequence.sequenceImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        sequence.sequenceImageTwoCustom = customImageTwo
                        sequence.sequenceImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        sequence.sequenceImageTwoDefault = def
                        sequence.sequenceImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            sequence.sequenceImageTwoCustom = image.imageId
                            sequence.sequenceImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    sequence.entityLevelId = level?.id
                    sequence.sequenceZoneId = zoneSelected?.id
                    sequence.sequenceCategoryId = category?.id
                    
                    sequence.isBroadcast = broadcastSwitch.on
                    sequence.isLocalcast = localcastSwitch.on
                    sequence.sequenceCycles = cycles
                    sequence.entityLevel = btnLevel.titleLabel!.text!
                    sequence.sequenceZone = btnZone.titleLabel!.text!
                    sequence.sequenceCategory = btnCategory.titleLabel!.text!
                    sequence.gateway = gateway
                    refreshSequenceList()
                } else {
                    existingSequence!.sequenceId = sceneId
                    existingSequence!.sequenceName = sceneName
                    existingSequence!.address = address
                    
                    if let customImageOne = customImageOne{
                        existingSequence!.sequenceImageOneCustom = customImageOne
                        existingSequence!.sequenceImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        existingSequence!.sequenceImageOneDefault = def
                        existingSequence!.sequenceImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingSequence!.sequenceImageOneCustom = image.imageId
                            existingSequence!.sequenceImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        existingSequence!.sequenceImageTwoCustom = customImageTwo
                        existingSequence!.sequenceImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        existingSequence!.sequenceImageTwoDefault = def
                        existingSequence!.sequenceImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingSequence!.sequenceImageTwoCustom = image.imageId
                            existingSequence!.sequenceImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    existingSequence!.entityLevelId = level?.id
                    existingSequence!.sequenceZoneId = zoneSelected?.id
                    existingSequence!.sequenceCategoryId = category?.id
                    
                    existingSequence!.isBroadcast = broadcastSwitch.on
                    existingSequence!.isLocalcast = localcastSwitch.on
                    existingSequence!.sequenceCycles = cycles
                    existingSequence!.entityLevel = btnLevel.titleLabel!.text!
                    existingSequence!.sequenceZone = btnZone.titleLabel!.text!
                    existingSequence!.sequenceCategory = btnCategory.titleLabel!.text!
                    existingSequence!.gateway = gateway
                    refreshSequenceList()
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    @IBAction func scanSequences(sender: AnyObject) {
        findSequences()
    }
    
    @IBAction func clearRangeFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to delete all scenes?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if self.sequences.count != 0 {
                for sequence in self.sequences {
                    self.appDel.managedObjectContext!.deleteObject(sequence)
                }
            }
            CoreDataController.shahredInstance.saveChanges()
            self.refreshSequenceList()
            self.view.endEditing(true)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var sequencesTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    var arrayOfSequencesToBeSearched = [Int]()
    var indexOfSequencesToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenSequences: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findSequences() {
        do {
            arrayOfSequencesToBeSearched = [Int]()
            indexOfSequencesToBeSearched = 0
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningSequencesNameAndParameters)
            
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
                arrayOfSequencesToBeSearched.append(i)
            }
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfSequencesToBeSearched.count != 0{
                let firstSequenceIndexThatDontHaveName = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                timesRepeatedCounter = 0
                progressBarScreenSequences = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfSequencesToBeSearched.count), howMuchOf: "1 / \(arrayOfSequencesToBeSearched.count)")
                progressBarScreenSequences?.delegate = self
                self.presentViewController(progressBarScreenSequences!, animated: true, completion: nil)
                sequencesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: firstSequenceIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstSequenceIndexThatDontHaveName)")
                sendCommandWithSequenceAddress(firstSequenceIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    // Called from findSequences or from it self.
    // Checks which sequence ID should be searched for and calls sendCommandWithSequenceAddress for that specific sequence id.
    func checkIfSequenceDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let sequenceIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            sequencesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: sequenceIndex, repeats: false)
            NSLog("func checkIfSceneDidGetName \(sequenceIndex)")
            sendCommandWithSequenceAddress(sequenceIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.indexOf(sequenceIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfSequencesToBeSearched+1 < arrayOfSequencesToBeSearched.count{ // if next exists
                    indexOfSequencesToBeSearched = indexOfSequenceIndexInArrayOfNamesToBeSearched+1
                    let nextSceneIndexToBeSearched = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                    timesRepeatedCounter = 0
                    sequencesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                    NSLog("func checkIfSceneDidGetName \(nextSceneIndexToBeSearched)")
                    sendCommandWithSequenceAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }else{
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next sequence ID to search for. If there is not, dismiss progres bar and end the search.
    func nameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningSequencesNameAndParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["sequenceId"] else{
                return
            }
            guard let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfSequenceIndexInArrayOfNamesToBeSearched+1 < arrayOfSequencesToBeSearched.count{ // if next exists
                indexOfSequencesToBeSearched = indexOfSequenceIndexInArrayOfNamesToBeSearched+1
                let nextSequenceIndexToBeSearched = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                
                timesRepeatedCounter = 0
                sequencesTimer?.invalidate()
                sequencesTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: nextSequenceIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextSequenceIndexToBeSearched)")
                sendCommandWithSequenceAddress(nextSequenceIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    func sendCommandWithSequenceAddress(sequenceId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(sequenceId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getSequenceNameAndParametar(address, sequenceId: UInt8(sequenceId)) , gateway: self.gateway)
    }
    func setProgressBarParametars (sequenceId:Int) {
        if let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.indexOf(sequenceId){
            if let _ = progressBarScreenSequences?.lblHowMuchOf, let _ = progressBarScreenSequences?.lblPercentage, let _ = progressBarScreenSequences?.progressView{
                progressBarScreenSequences?.lblHowMuchOf.text = "\(indexOfSequenceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfSequencesToBeSearched.count)"
                progressBarScreenSequences?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfSequenceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfSequencesToBeSearched.count)*100) + " %"
                progressBarScreenSequences?.progressView.progress = Float(indexOfSequenceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfSequencesToBeSearched.count)
            }
        }
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        sequencesTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningSequencesNameAndParameters)
        progressBarScreenSequences!.dissmissProgressBar()
        
        arrayOfSequencesToBeSearched = [Int]()
        indexOfSequencesToBeSearched = 0
        UIApplication.sharedApplication().idleTimerDisabled = false
        refreshSequenceList()
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

extension ScanSequencesesViewController: SceneGalleryDelegate{
    
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

extension ScanSequencesesViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanSequencesesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sequencesCell") as? SequencesCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(sequences[indexPath.row].sequenceId)"
            cell.labelName.text = "\(sequences[indexPath.row].sequenceName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].address)))"
            if let id = sequences[indexPath.row].sequenceImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageOne.image = UIImage(named: "lightBulb")
                        }
                    }
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageOne.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }else{
                    cell.imageOne.image = UIImage(named: "lightBulb")
                }
            }
            
            if let id = sequences[indexPath.row].sequenceImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageTwo.image = UIImage(named: "lightBulb")
                        }
                    }
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageTwo.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }else{
                    cell.imageTwo.image = UIImage(named: "lightBulb")
                }
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "sequnces"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = sequences[indexPath.row]
        IDedit.text = "\(sequences[indexPath.row].sequenceId)"
        nameEdit.text = "\(sequences[indexPath.row].sequenceName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(sequences[indexPath.row].address)))"
        editCycle.text = "\(sequences[indexPath.row].sequenceCycles)"
        broadcastSwitch.on = sequences[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = sequences[indexPath.row].isLocalcast.boolValue
        
        if let levelId = sequences[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        if let zoneId = sequences[indexPath.row].sequenceZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        if let categoryId = sequences[indexPath.row].sequenceCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle("All", forState: UIControlState.Normal)
        }
        
        if let id = sequences[indexPath.row].sequenceImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "lightBulb")
            }
        }
        
        if let id = sequences[indexPath.row].sequenceImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "lightBulb")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sequences.count
    }
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.sequencesTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(sequences[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            refreshSequenceList()
        }
        
    }
}

class SequencesCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
