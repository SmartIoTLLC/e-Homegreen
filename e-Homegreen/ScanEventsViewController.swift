//
//  ScanEventsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanEventsViewController: PopoverVC, ProgressBarDelegate {
    
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
    @IBOutlet weak var reportSwitch: UISwitch!
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var events:[Event] = []
    
    var selected:AnyObject?
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
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
        
        updateEventList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanSequencesesViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveEventFromGateway, object: nil)
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateEventList()
        eventTableView.reloadData()
    }
    
    override func sendSearchBarText(text: String) {
        updateEventList()
        if !text.isEmpty{
            events = self.events.filter() {
                event in
                if event.eventName.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        eventTableView.reloadData()
        
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshEventList() {
        updateEventList()
        eventTableView.reloadData()
    }
    
    func updateEventList() {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
//        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "eventZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "eventCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            events = fetResults!
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
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingEvent:Event?
                for event in events {
                    if event.eventId == sceneId && event.address == address {
                        itExists = true
                        existingEvent = event
                    }
                }
                if !itExists {
                    let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
                    event.eventId = sceneId
                    event.eventName = sceneName
                    event.address = address
                    if let customImageOne = customImageOne{
                        event.eventImageOneCustom = customImageOne
                        event.eventImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        event.eventImageOneDefault = def
                        event.eventImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            event.eventImageOneCustom = image.imageId
                            event.eventImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        event.eventImageTwoCustom = customImageTwo
                        event.eventImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        event.eventImageTwoDefault = def
                        event.eventImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            event.eventImageTwoCustom = image.imageId
                            event.eventImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    event.entityLevelId = level?.id
                    event.eventZoneId = zoneSelected?.id
                    event.eventCategoryId = category?.id
                    
                    event.isBroadcast = broadcastSwitch.on
                    event.isLocalcast = localcastSwitch.on
                    event.report = reportSwitch.on
                    event.entityLevel = btnLevel.titleLabel!.text!
                    event.eventZone = btnZone.titleLabel!.text!
                    event.eventCategory = btnCategory.titleLabel!.text!
                    event.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshEventList()
                } else {
                    existingEvent!.eventId = sceneId
                    existingEvent!.eventName = sceneName
                    existingEvent!.address = address
                    
                    if let customImageOne = customImageOne{
                        existingEvent!.eventImageOneCustom = customImageOne
                        existingEvent!.eventImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        existingEvent!.eventImageOneDefault = def
                        existingEvent!.eventImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingEvent!.eventImageOneCustom = image.imageId
                            existingEvent!.eventImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        existingEvent!.eventImageTwoCustom = customImageTwo
                        existingEvent!.eventImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        existingEvent!.eventImageTwoDefault = def
                        existingEvent!.eventImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingEvent!.eventImageTwoCustom = image.imageId
                            existingEvent!.eventImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    existingEvent!.entityLevelId = level?.id
                    existingEvent!.eventZoneId = zoneSelected?.id
                    existingEvent!.eventCategoryId = category?.id
                    
                    existingEvent!.isBroadcast = broadcastSwitch.on
                    existingEvent!.isLocalcast = localcastSwitch.on
                    existingEvent!.report = reportSwitch.on
                    existingEvent!.entityLevel = btnLevel.titleLabel!.text!
                    existingEvent!.eventZone = btnZone.titleLabel!.text!
                    existingEvent!.eventCategory = btnCategory.titleLabel!.text!
                    existingEvent!.gateway = gateway
                    CoreDataController.shahredInstance.saveChanges()
                    refreshEventList()
                }
            }
        }
    }
    
    @IBAction func scanEvents(sender: AnyObject) {
        findEvents()
    }
    
    @IBAction func clearRangeFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }

    @IBAction func btnRemove(sender: UIButton) {
        
        let optionMenu = UIAlertController(title: nil, message: "Are you sure you want to delete all scenes?", preferredStyle: .ActionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            if self.events.count != 0 {
                for event in self.events {
                    self.appDel.managedObjectContext!.deleteObject(event)
                }
                
            }
            CoreDataController.shahredInstance.saveChanges()
            self.refreshEventList()
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
    
    // MARK: - FINDING EVENTS
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var eventsTimer:NSTimer?
    var timesRepeatedCounter:Int = 0
    var arrayOfEventsToBeSearched = [Int]()
    var indexOfEventsToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenEvents: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findEvents() {
        do {
            arrayOfEventsToBeSearched = [Int]()
            indexOfEventsToBeSearched = 0
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningEventsNameAndParameters)
            
            guard let address1Text = devAddressOne.text else{
                alertController("Error", message: "Address can't be empty")
                return
            }
            guard let address1 = Int(address1Text) else{
                alertController("Error", message: "Address can be only number")
                return
            }
            addressOne = address1
            
            guard let address2Text = devAddressTwo.text else{
                alertController("Error", message: "Address can't be empty")
                return
            }
            guard let address2 = Int(address2Text) else{
                alertController("Error", message: "Address can be only number")
                return
            }
            addressTwo = address2
            
            guard let address3Text = devAddressThree.text else{
                alertController("Error", message: "Address can't be empty")
                return
            }
            guard let address3 = Int(address3Text) else{
                alertController("Error", message: "Address can be only number")
                return
            }
            addressThree = address3
            guard let rangeFromText = fromTextField.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                alertController("Error", message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            for i in from...to{
                arrayOfEventsToBeSearched.append(i)
            }
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfEventsToBeSearched.count != 0{
                let firstEventIndexThatDontHaveName = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                timesRepeatedCounter = 0
                progressBarScreenEvents = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfEventsToBeSearched.count), howMuchOf: "1 / \(arrayOfEventsToBeSearched.count)")
                progressBarScreenEvents?.delegate = self
                self.presentViewController(progressBarScreenEvents!, animated: true, completion: nil)
                eventsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: firstEventIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstEventIndexThatDontHaveName)")
                sendCommandWithEventAddress(firstEventIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    // Called from findEvents or from it self.
    // Checks which sequence ID should be searched for and calls sendCommandWithEventAddress for that specific sequence id.
    func checkIfEventDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let eventIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            eventsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: eventIndex, repeats: false)
            NSLog("func checkIfEventDidGetName \(eventIndex)")
            sendCommandWithEventAddress(eventIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.indexOf(eventIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfEventsToBeSearched+1 < arrayOfEventsToBeSearched.count{ // if next exists
                    indexOfEventsToBeSearched = indexOfEventIndexInArrayOfNamesToBeSearched+1
                    let nextEventIndexToBeSearched = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                    timesRepeatedCounter = 0
                    eventsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: nextEventIndexToBeSearched, repeats: false)
                    NSLog("func checkIfEventDidGetName \(nextEventIndexToBeSearched)")
                    sendCommandWithEventAddress(nextEventIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
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
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningEventsNameAndParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["eventId"] else{
                return
            }
            guard let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.indexOf(timerIndex) else{
                return
            }
            
            if indexOfEventIndexInArrayOfNamesToBeSearched+1 < arrayOfEventsToBeSearched.count{ // if next exists
                indexOfEventsToBeSearched = indexOfEventIndexInArrayOfNamesToBeSearched+1
                let nextEventIndexToBeSearched = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                
                timesRepeatedCounter = 0
                eventsTimer?.invalidate()
                eventsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: nextEventIndexToBeSearched, repeats: false)
                sendCommandWithEventAddress(nextEventIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    func sendCommandWithEventAddress(eventId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(eventId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getEventNameAndParametar(address, eventId: UInt8(eventId)), gateway: self.gateway)
    }
    func setProgressBarParametars (eventId:Int) {
        if let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.indexOf(eventId){
            if let _ = progressBarScreenEvents?.lblHowMuchOf, let _ = progressBarScreenEvents?.lblPercentage, let _ = progressBarScreenEvents?.progressView{
                progressBarScreenEvents?.lblHowMuchOf.text = "\(indexOfEventIndexInArrayOfNamesToBeSearched+1) / \(arrayOfEventsToBeSearched.count)"
                progressBarScreenEvents?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfEventIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfEventsToBeSearched.count)*100) + " %"
                progressBarScreenEvents?.progressView.progress = Float(indexOfEventIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfEventsToBeSearched.count)
            }
        }
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounter = 0
        eventsTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningEventsNameAndParameters)
        progressBarScreenEvents!.dissmissProgressBar()
        
        arrayOfEventsToBeSearched = [Int]()
        indexOfEventsToBeSearched = 0
        UIApplication.sharedApplication().idleTimerDisabled = false
        refreshEventList()
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

extension ScanEventsViewController: SceneGalleryDelegate{
    
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

extension ScanEventsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("eventsCell") as? EventsCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(events[indexPath.row].eventId)"
            cell.labelName.text = "\(events[indexPath.row].eventName)"
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressOne)))")
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressTwo)))")
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))")
            cell.address.text = "\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))"
            
            if let id = events[indexPath.row].eventImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = events[indexPath.row].eventImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageOne.image = UIImage(named: "17 Event - Up Down - 00")
                        }
                    }
                }else{
                    if let defaultImage = events[indexPath.row].eventImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageOne.image = UIImage(named: "17 Event - Up Down - 00")
                    }
                }
            }else{
                if let defaultImage = events[indexPath.row].eventImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }else{
                    cell.imageOne.image = UIImage(named: "17 Event - Up Down - 00")
                }
            }
            
            if let id = events[indexPath.row].eventImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageTwo.image = UIImage(named: "17 Event - Up Down - 01")
                        }
                    }
                }else{
                    if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageTwo.image = UIImage(named: "17 Event - Up Down - 01")
                    }
                }
            }else{
                if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }else{
                    cell.imageTwo.image = UIImage(named: "17 Event - Up Down - 01")
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "sequnces"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = events[indexPath.row]
        IDedit.text = "\(events[indexPath.row].eventId)"
        nameEdit.text = "\(events[indexPath.row].eventName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))"
        broadcastSwitch.on = events[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = events[indexPath.row].isLocalcast.boolValue
        reportSwitch.on = events[indexPath.row].report.boolValue
        
        if let levelId = events[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        if let zoneId = events[indexPath.row].eventZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, forState: UIControlState.Normal)
        }else{
            btnZone.setTitle("All", forState: UIControlState.Normal)
        }
        if let categoryId = events[indexPath.row].eventCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, forState: UIControlState.Normal)
        }else{
            btnCategory.setTitle(category?.name, forState: UIControlState.Normal)
        }
        
        if let id = events[indexPath.row].eventImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = events[indexPath.row].eventImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "17 Event - Up Down - 00")
                    }
                }
            }else{
                if let defaultImage = events[indexPath.row].eventImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "17 Event - Up Down - 00")
                }
            }
        }else{
            if let defaultImage = events[indexPath.row].eventImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "17 Event - Up Down - 00")
            }
        }
        
        if let id = events[indexPath.row].eventImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "17 Event - Up Down - 01")
                    }
                }
            }else{
                if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "17 Event - Up Down - 01")
                }
            }
        }else{
            if let defaultImage = events[indexPath.row].eventImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "17 Event - Up Down - 01")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.eventTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(events[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            refreshEventList()
        }
        
    }
}

class EventsCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
