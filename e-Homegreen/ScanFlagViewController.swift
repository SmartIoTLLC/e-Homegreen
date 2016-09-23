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
    
    var imageDataOne:Data?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:Data?
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
        
        imageSceneOne.isUserInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        imageSceneTwo.isUserInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.isEnabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.isEnabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        refreshFlagList()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }

    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshFlagList()
    }
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshFlagList()
        
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
    func refreshFlagList() {
        flags = DatabaseFlagsController.shared.updateFlagList(gateway, filterParametar: filterParametar)
        flagTableView.reloadData()
    }
    
    func handleTap (_ gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
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
                
                DatabaseFlagsController.shared.createFlag(flagId, flagName: flagName, moduleAddress: address, gateway: gateway, levelId: levelId, selectedZoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
                
            }
            refreshFlagList()
        }
        self.view.endEditing(true)
    }
    
    @IBAction func scanFlag(_ sender: AnyObject) {
        findNames()
    }
    
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(_ sender: UIButton) {
        showAlertView(sender, message:  "Are you sure you want to delete all flags?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseFlagsController.shared.deleteAllFlags(self.gateway)
                self.refreshFlagList()
                self.view.endEditing(true)
            }
        }
    }
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var flagNameTimer:Foundation.Timer?
    var flagParameterTimer: Foundation.Timer?
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
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstFlagIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenFlagNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenFlagNames?.delegate = self
                self.present(progressBarScreenFlagNames!, animated: true, completion: nil)
                flagNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: firstFlagIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstFlagIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningFlagNames)
                sendCommandForFindingNameWithFlagAddress(firstFlagIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfFlagDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let flagIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            flagNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: flagIndex, repeats: false)
            NSLog("func checkIfFlagDidGetName \(flagIndex)")
            sendCommandForFindingNameWithFlagAddress(flagIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfFlagIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: flagIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfFlagIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfFlagIndexInArrayOfNamesToBeSearched+1
                    let nextFlagIndexToBeSearched = arrayOfNamesToBeSearched[indexOfFlagIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    flagNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
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
    func nameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagNames) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let flagIndex = info["flagId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: flagIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextFlagIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounterNames = 0
                flagNameTimer?.invalidate()
                flagNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetName(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :flagIndex\(nextFlagIndexToBeSearched)")
                sendCommandForFindingNameWithFlagAddress(nextFlagIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithFlagAddress(_ flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(flagId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagName(address, flagId: UInt8(flagId + 100)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (_ flagId:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: flagId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
                    if flagTemp.flagId.intValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }

            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenFlagNames = nil
                progressBarScreenFlagNames = ProgressBarVC(title: "Finding flag parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenFlagNames?.delegate = self
                self.present(progressBarScreenFlagNames!, animated: true, completion: nil)
                flagParameterTimer?.invalidate()
                flagParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningFlagParameters)
                sendCommandForFindingParameterWithFlagAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfFlagDidGetParametar (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let flagIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            flagParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: flagIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(flagIndex)")
            sendCommandForFindingParameterWithFlagAddress(flagIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfFlagIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: flagIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfFlagIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfFlagIndexInArrayOfParametersToBeSearched+1
                    let nextFlagIndexToBeSearched = arrayOfParametersToBeSearched[indexOfFlagIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    flagParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
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
    func flagParametarReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let flagIndex = info["flagId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: flagIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextFlagIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                flagParameterTimer?.invalidate()
                flagParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanFlagViewController.checkIfFlagDidGetParametar(_:)), userInfo: nextFlagIndexToBeSearched, repeats: false)
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
    func sendCommandForFindingParameterWithFlagAddress(_ flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(flagId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagParametar(address, flagId: UInt8(flagId+100)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (_ flagId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.index(of: flagId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningFlagNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningFlagParameters)
        progressBarScreenFlagNames!.dissmissProgressBar()
        
        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        if !shouldFindFlagParameters {
            UIApplication.shared.isIdleTimerDisabled = false
            refreshFlagList()
        } else {
            _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(ScanFlagViewController.findParametarsForFlag), userInfo: nil, repeats: false)
        }
    }
    
    func addObservers(){
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanFlagViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanFlagViewController.flagParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: nil)
    }
    func removeObservers(){
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningFlagNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningFlagParameters)
        
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: nil)
    }
}

extension ScanFlagViewController: SceneGalleryDelegate{
    
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

extension ScanFlagViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanFlagViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "flagsCell") as? FlagsCell {
            cell.backgroundColor = UIColor.clear
            cell.labelID.text = "\(flags[(indexPath as NSIndexPath).row].flagId)"
            cell.labelName.text = "\(flags[(indexPath as NSIndexPath).row].flagName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(flags[(indexPath as NSIndexPath).row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(flags[(indexPath as NSIndexPath).row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(flags[(indexPath as NSIndexPath).row].address)))"
            
            if let id = flags[(indexPath as NSIndexPath).row].flagImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = flags[(indexPath as NSIndexPath).row].flagImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        IDedit.text = "\(flags[(indexPath as NSIndexPath).row].flagId)"
        nameEdit.text = "\(flags[(indexPath as NSIndexPath).row].flagName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(flags[(indexPath as NSIndexPath).row].address)))"
        broadcastSwitch.isOn = flags[(indexPath as NSIndexPath).row].isBroadcast.boolValue
        localcastSwitch.isOn = flags[(indexPath as NSIndexPath).row].isLocalcast.boolValue
        
        if let levelId = flags[(indexPath as NSIndexPath).row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, for: UIControlState())
        }else{
            btnLevel.setTitle("All", for: UIControlState())
        }
        if let zoneId = flags[(indexPath as NSIndexPath).row].flagZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        }else{
            btnZone.setTitle("All", for: UIControlState())
        }
        if let categoryId = flags[(indexPath as NSIndexPath).row].flagCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, for: UIControlState())
        }else{
            btnCategory.setTitle("All", for: UIControlState())
        }
        
        defaultImageOne = flags[(indexPath as NSIndexPath).row].flagImageOneDefault
        customImageOne = flags[(indexPath as NSIndexPath).row].flagImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault
        customImageTwo = flags[(indexPath as NSIndexPath).row].flagImageTwoCustom
        imageDataTwo = nil
        
        if let id = flags[(indexPath as NSIndexPath).row].flagImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
                    }
                }
            }else{
                if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
                }
            }
        }else{
            if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "16 Flag - Flag - 00")
            }
        }
        
        if let id = flags[(indexPath as NSIndexPath).row].flagImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
                    }
                }
            }else{
                if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
                }
            }
        }else{
            if let defaultImage = flags[(indexPath as NSIndexPath).row].flagImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "16 Flag - Flag - 01")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.flagTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseFlagsController.shared.deleteFlag(flags[(indexPath as NSIndexPath).row])
            flags.remove(at: (indexPath as NSIndexPath).row)
            flagTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
}


