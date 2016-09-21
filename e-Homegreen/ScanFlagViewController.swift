//
//  ScanFlagViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/7/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanFlagViewController: PopoverVC, ProgressBarDelegate {
    
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
    @IBOutlet weak var flagTableView: UITableView!
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    var flags:[Flag] = []
    
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
        
        refreshFlagList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.enabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.enabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        
    }
    override func viewWillAppear(animated: Bool) {
        addObservers()
        refreshFlagList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }

    override func sendFilterParametar(filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshFlagList()
    }
    override func sendSearchBarText(text: String) {
        searchBarText = text
        refreshFlagList()
        
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
    func refreshFlagList() {
        flags = DatabaseFlagsController.shared.updateFlagList(gateway, filterParametar: filterParametar)
        flagTableView.reloadData()
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
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString!))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString!))
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
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString!))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let flagId = Int(IDedit.text!), let flagName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if flagId <= 32767 && address <= 255 {
                
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
                
                DatabaseFlagsController.shared.createFlag(flagId, flagName: flagName, moduleAddress: address, gateway: gateway, levelId: levelId, selectedZoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.on, isLocalcast: localcastSwitch.on, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
                
            }
            refreshFlagList()
        }
        self.view.endEditing(true)
    }
    
    @IBAction func scanFlag(sender: AnyObject) {
        findNames()
    }
    
    @IBAction func clearRangeFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(sender: UIButton) {
        showAlertView(sender, message:  "Are you sure you want to delete all flags?") { (action) in
            if action == ReturnedValueFromAlertView.Delete{
                DatabaseFlagsController.shared.deleteAllFlags(self.gateway)
                self.refreshFlagList()
                self.view.endEditing(true)
            }
        }
    }
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var flagNameTimer:NSTimer?
    var flagParameterTimer: NSTimer?
    var timesRepeatedCounterNames:Int = 0
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenFlagNames: ProgressBarVC?
    var shouldFindFlagParameters = false
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            
            guard let address1Text = devAddressOne.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            guard let address1 = Int(address1Text) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            addressOne = address1

            guard let address2Text = devAddressTwo.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            guard let address2 = Int(address2Text) else{
                self.view.makeToast(message: "Address can be only number")
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
                self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            for i in from...to{
                arrayOfNamesToBeSearched.append(i)
            }
            shouldFindFlagParameters = true
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstFlagIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenFlagNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenFlagNames?.delegate = self
                self.presentViewController(progressBarScreenFlagNames!, animated: true, completion: nil)
                flagNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: firstFlagIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstFlagIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningFlagNames)
                sendCommandForFindingNameWithFlagAddress(firstFlagIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfFlagDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let flagIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            flagNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: flagIndex, repeats: false)
            NSLog("func checkIfFlagDidGetName \(flagIndex)")
            sendCommandForFindingNameWithFlagAddress(flagIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfFlagIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(flagIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfFlagIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfFlagIndexInArrayOfNamesToBeSearched+1
                    let nextFlagIndexToBeSearched = arrayOfNamesToBeSearched[indexOfFlagIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    flagNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(nextFlagIndexToBeSearched)")
                    sendCommandForFindingNameWithFlagAddress(nextFlagIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
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
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningFlagNames) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let flagIndex = info["flagId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(flagIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextFlagIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounterNames = 0
                flagNameTimer?.invalidate()
                flagNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :flagIndex\(nextFlagIndexToBeSearched)")
                sendCommandForFindingNameWithFlagAddress(nextFlagIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithFlagAddress(flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(flagId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagName(address, flagId: UInt8(flagId + 100)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (flagId:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(flagId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = progressBarScreenFlagNames?.lblHowMuchOf, let _ = progressBarScreenFlagNames?.lblPercentage, let _ = progressBarScreenFlagNames?.progressView{
                progressBarScreenFlagNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                progressBarScreenFlagNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                progressBarScreenFlagNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
        }
    }
    
    // MARK: - Timer parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForFlag() {
        progressBarScreenFlagNames?.dissmissProgressBar()
        progressBarScreenFlagNames = nil
        
            arrayOfParametersToBeSearched = [Int]()
            indexOfParametersToBeSearched = 0
            
            refreshFlagList()
            
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
                self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            
            for i in from...to{
                for flagTemp in flags {
                    if flagTemp.flagId.integerValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }

            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenFlagNames = nil
                progressBarScreenFlagNames = ProgressBarVC(title: "Finding flag parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenFlagNames?.delegate = self
                self.presentViewController(progressBarScreenFlagNames!, animated: true, completion: nil)
                flagParameterTimer?.invalidate()
                flagParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningFlagParameters)
                sendCommandForFindingParameterWithFlagAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfFlagDidGetParametar (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let flagIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            flagParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: flagIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(flagIndex)")
            sendCommandForFindingParameterWithFlagAddress(flagIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfFlagIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(flagIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfFlagIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfFlagIndexInArrayOfParametersToBeSearched+1
                    let nextFlagIndexToBeSearched = arrayOfParametersToBeSearched[indexOfFlagIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    flagParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetParameter \(nextFlagIndexToBeSearched)")
                    sendCommandForFindingParameterWithFlagAddress(nextFlagIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                    print("Command sent for parameter from checkIfTimerDidGetParametar: next parameter")
                }else{
                    shouldFindFlagParameters = false
                    dismissScaningControls()
                }
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func flagParametarReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningFlagParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let flagIndex = info["flagId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(flagIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextFlagIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                flagParameterTimer?.invalidate()
                flagParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
                NSLog("func parameterReceivedFromPLC index:\(index) :deviceIndex\(nextFlagIndexToBeSearched)")
                sendCommandForFindingParameterWithFlagAddress(nextFlagIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from flagParametarReceivedFromPLC: next parameter")
            }else{
                shouldFindFlagParameters = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithFlagAddress(flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(flagId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagParametar(address, flagId: UInt8(flagId+100)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (flagId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.indexOf(flagId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
            if let _ = progressBarScreenFlagNames?.lblHowMuchOf {
                if let _ = progressBarScreenFlagNames?.lblPercentage{
                    if let _ = progressBarScreenFlagNames?.progressView{
                        print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
                        progressBarScreenFlagNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1) / \(arrayOfParametersToBeSearched.count)"
                        progressBarScreenFlagNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)*100) + " %"
                        progressBarScreenFlagNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)
                    }
                }
            }
        }
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        shouldFindFlagParameters = false
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounterNames = 0
        timesRepeatedCounterParameters = 0
        flagNameTimer?.invalidate()
        flagParameterTimer?.invalidate()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningFlagNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningFlagParameters)
        progressBarScreenFlagNames!.dissmissProgressBar()
        
        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        if !shouldFindFlagParameters {
            UIApplication.sharedApplication().idleTimerDisabled = false
            refreshFlagList()
        } else {
            _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanFlagViewController.findParametarsForFlag), userInfo: nil, repeats: false)
        }
    }
    
    func addObservers(){
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanFlagViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveFlagFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanFlagViewController.flagParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveFlagParameterFromGateway, object: nil)
    }
    func removeObservers(){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningFlagNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningFlagParameters)
        
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveFlagFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidReceiveFlagParameterFromGateway, object: nil)
    }
}

extension ScanFlagViewController: SceneGalleryDelegate{
    
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

extension ScanFlagViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanFlagViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("flagsCell") as? FlagsCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(flags[indexPath.row].flagId)"
            cell.labelName.text = "\(flags[indexPath.row].flagName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(flags[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(flags[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(flags[indexPath.row].address)))"
            
            if let id = flags[indexPath.row].flagImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = flags[indexPath.row].flagImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        IDedit.text = "\(flags[indexPath.row].flagId)"
        nameEdit.text = "\(flags[indexPath.row].flagName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(flags[indexPath.row].address)))"
        broadcastSwitch.on = flags[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = flags[indexPath.row].isLocalcast.boolValue
        
        if let levelId = flags[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, forState: UIControlState.Normal)
        }else{
            btnLevel.setTitle("All", forState: UIControlState.Normal)
        }
        if let zoneId = flags[indexPath.row].flagZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, forState: .Normal)
        }else{
            btnZone.setTitle("All", forState: .Normal)
        }
        if let categoryId = flags[indexPath.row].flagCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, forState: .Normal)
        }else{
            btnCategory.setTitle("All", forState: .Normal)
        }
        
        defaultImageOne = flags[indexPath.row].flagImageOneDefault
        customImageOne = flags[indexPath.row].flagImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = flags[indexPath.row].flagImageTwoDefault
        customImageTwo = flags[indexPath.row].flagImageTwoCustom
        imageDataTwo = nil
        
        if let id = flags[indexPath.row].flagImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
                    }
                }
            }else{
                if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
                }
            }
        }else{
            if let defaultImage = flags[indexPath.row].flagImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
            }
        }
        
        if let id = flags[indexPath.row].flagImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
                    }
                }
            }else{
                if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
                }
            }
        }else{
            if let defaultImage = flags[indexPath.row].flagImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            self.tableView(self.flagTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            DatabaseFlagsController.shared.deleteFlag(flags[indexPath.row])
            flags.removeAtIndex(indexPath.row)
            flagTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
}


