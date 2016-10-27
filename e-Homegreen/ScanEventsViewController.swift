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
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    var events:[Event] = []
    
    var searchBarText:String = ""
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var imageDataOne:Data?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:Data?
    var customImageTwo:String?
    var defaultImageTwo:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshEventList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        nameEdit.delegate = self
        
        imageSceneOne.isUserInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanEventsViewController.handleTap(_:))))
        imageSceneTwo.isUserInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanEventsViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(ScanEventsViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(ScanEventsViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3

    }
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        refreshEventList()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }

    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshEventList()
    }
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshEventList()
    }
    
    override func nameAndId(_ name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            
            btnZone.setTitle("All", for: UIControlState())
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
        
        button.setTitle(name, for: UIControlState())
    }
    
    func changeValue (_ sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.isOn = false
        } else if sender.tag == 200 {
            broadcastSwitch.isOn = false
        }
    }
    func refreshEventList() {
        events = DatabaseEventsController.shared.updateEventList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty{
            events = self.events.filter() {
                event in
                if event.eventName.lowercased().range(of: searchBarText.lowercased()) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        eventTableView.reloadData()
    }
    
    func handleTap (_ gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    func addObservers(){
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanSequencesesViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveEventFromGateway), object: nil)
    }
    func removeObservers(){
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningEventsNameAndParameters)
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveEventFromGateway), object: nil)
    }
    
    @IBAction func btnLevel(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnZoneAction(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnAdd(_ sender: AnyObject) {
        if let eventId = Int(IDedit.text!), let eventName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if eventId <= 32767 && address <= 255 {
                
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
                
                DatabaseEventsController.shared.createEvent(eventId, eventName: eventName, moduleAddress: address, gateway: gateway, levelId: levelId, zoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo, report: reportSwitch.isOn)
                
            }
            refreshEventList()
            self.view.endEditing(true)
        }else{
            self.view.makeToast(message: "Please check fields: name, id and address")
        }
    }
    
    @IBAction func scanEvents(_ sender: AnyObject) {
        findEvents()
    }
    
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all scenes?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseEventsController.shared.deleteAllEvents(self.gateway)
                self.refreshEventList()
                self.view.endEditing(true)
            }
        }
    }
    
    // MARK: - FINDING EVENTS
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var eventsTimer:Foundation.Timer?
    var timesRepeatedCounter:Int = 0
    var arrayOfEventsToBeSearched = [Int]()
    var indexOfEventsToBeSearched = 0
    var progressBarScreenEvents: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findEvents() {
            arrayOfEventsToBeSearched = [Int]()
            indexOfEventsToBeSearched = 0
            
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
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            for i in from...to{
                arrayOfEventsToBeSearched.append(i)
            }
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfEventsToBeSearched.count != 0{
                let firstEventIndexThatDontHaveName = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                timesRepeatedCounter = 0
                progressBarScreenEvents = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfEventsToBeSearched.count), howMuchOf: "1 / \(arrayOfEventsToBeSearched.count)")
                progressBarScreenEvents?.delegate = self
                self.present(progressBarScreenEvents!, animated: true, completion: nil)
                eventsTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: firstEventIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstEventIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningEventsNameAndParameters)
                sendCommandWithEventAddress(firstEventIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
    }
    // Called from findEvents or from it self.
    // Checks which sequence ID should be searched for and calls sendCommandWithEventAddress for that specific sequence id.
    func checkIfEventDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let eventIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            eventsTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: eventIndex, repeats: false)
            NSLog("func checkIfEventDidGetName \(eventIndex)")
            sendCommandWithEventAddress(eventIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.index(of: eventIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfEventsToBeSearched+1 < arrayOfEventsToBeSearched.count{ // if next exists
                    indexOfEventsToBeSearched = indexOfEventIndexInArrayOfNamesToBeSearched+1
                    let nextEventIndexToBeSearched = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                    timesRepeatedCounter = 0
                    eventsTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: nextEventIndexToBeSearched, repeats: false)
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
    func nameReceivedFromPLC (_ notification:Notification) {
        refreshEventList()
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningEventsNameAndParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let eventAddress  = info["eventAddress"] else{
                return
            }
            guard let eventId  = info["eventId"] else{
                return
            }
            let eventTemp = self.events.filter({ (e) -> Bool in
                return (Int(e.address) == eventAddress && Int(e.eventId) == eventId)
            })
            
            if eventTemp.count > 0 {
                guard let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.index(of: Int(eventTemp.first!.eventId)) else{
                    return
                }
                
                if indexOfEventIndexInArrayOfNamesToBeSearched+1 < arrayOfEventsToBeSearched.count{ // if next exists
                    indexOfEventsToBeSearched = indexOfEventIndexInArrayOfNamesToBeSearched+1
                    let nextEventIndexToBeSearched = arrayOfEventsToBeSearched[indexOfEventsToBeSearched]
                    
                    timesRepeatedCounter = 0
                    eventsTimer?.invalidate()
                    eventsTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanEventsViewController.checkIfEventDidGetName(_:)), userInfo: nextEventIndexToBeSearched, repeats: false)
                    sendCommandWithEventAddress(nextEventIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }
        }
    }
    func sendCommandWithEventAddress(_ eventId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(eventId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getEventNameAndParametar(address, eventId: UInt8(eventId)), gateway: self.gateway)
    }
    func setProgressBarParametars (_ eventId:Int) {
        if let indexOfEventIndexInArrayOfNamesToBeSearched = arrayOfEventsToBeSearched.index(of: eventId){
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
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningEventsNameAndParameters)
        progressBarScreenEvents!.dissmissProgressBar()
        
        arrayOfEventsToBeSearched = [Int]()
        indexOfEventsToBeSearched = 0
        UIApplication.shared.isIdleTimerDisabled = false
        refreshEventList()
    }
}

extension ScanEventsViewController: SceneGalleryDelegate{
    
    func backImage(_ image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(data: image.imageData! as Data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(data: image.imageData! as Data)
        }
    }
    
    func backString(_ strText: String, imageIndex:Int) {
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
    
    func backImageFromGallery(_ data: Data, imageIndex:Int ) {
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "eventsCell") as? EventsCell {
            cell.backgroundColor = UIColor.clear
            cell.labelID.text = "\(events[(indexPath as NSIndexPath).row].eventId)"
            cell.labelName.text = "\(events[(indexPath as NSIndexPath).row].eventName)"
            print("\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].gateway.addressOne)))")
            print("\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].gateway.addressTwo)))")
            print("\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].address)))")
            cell.address.text = "\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].address)))"
            
            if let id = events[(indexPath as NSIndexPath).row].eventImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = events[(indexPath as NSIndexPath).row].eventImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        IDedit.text = "\(events[(indexPath as NSIndexPath).row].eventId)"
        nameEdit.text = "\(events[(indexPath as NSIndexPath).row].eventName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(events[(indexPath as NSIndexPath).row].address)))"
        broadcastSwitch.isOn = events[(indexPath as NSIndexPath).row].isBroadcast.boolValue
        localcastSwitch.isOn = events[(indexPath as NSIndexPath).row].isLocalcast.boolValue
        reportSwitch.isOn = events[(indexPath as NSIndexPath).row].report.boolValue
        
        if let levelId = events[(indexPath as NSIndexPath).row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, for: UIControlState())
        }else{
            btnLevel.setTitle("All", for: UIControlState())
        }
        if let zoneId = events[(indexPath as NSIndexPath).row].eventZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        }else{
            btnZone.setTitle("All", for: UIControlState())
        }
        if let categoryId = events[(indexPath as NSIndexPath).row].eventCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, for: UIControlState())
        }else{
            btnCategory.setTitle(category?.name, for: UIControlState())
        }
        
        defaultImageOne = events[(indexPath as NSIndexPath).row].eventImageOneDefault
        customImageOne = events[(indexPath as NSIndexPath).row].eventImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = events[(indexPath as NSIndexPath).row].eventImageTwoDefault
        customImageTwo = events[(indexPath as NSIndexPath).row].eventImageTwoCustom
        imageDataTwo = nil
        
        if let id = events[(indexPath as NSIndexPath).row].eventImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = events[(indexPath as NSIndexPath).row].eventImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.eventTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            DatabaseEventsController.shared.deleteEvent(events[(indexPath as NSIndexPath).row])
            events.remove(at: (indexPath as NSIndexPath).row)
            eventTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
}
