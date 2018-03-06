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
    
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Flag name
    var flagNameTimer:Foundation.Timer?
    var timesRepeatedCounterNames:Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    // Flag parameter
    var flagParameterTimer: Foundation.Timer?
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    
    var alertController:UIAlertController?
    var progressBarScreenFlagNames: ProgressBarVC?
    var shouldFindFlagParameters = false
    
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

    @IBAction func btnLevel(_ sender: UIButton) {
        openPopover(popOverType: .level, sender: sender)
    }
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        openPopover(popOverType: .category, sender: sender)
    }
    @IBAction func btnZoneAction(_ sender: UIButton) {
        openPopover(popOverType: .zone, sender: sender)
    }
    @IBAction func btnAdd(_ sender: AnyObject) {
        addTapped()
    }
    @IBAction func scanFlag(_ sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        clearRangeFields()
    }
    @IBAction func btnRemove(_ sender: UIButton) {
        removeTapped(sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshFlagList()
        setupViews()
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
        
        switch button.tag {
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
    
    @objc func changeValue (_ sender:UISwitch) {
        switch sender.tag {
            case 100 : localcastSwitch.isOn = false
            case 200 : broadcastSwitch.isOn = false
            default  : break
        }
    }

}

// MARK: - Flag name
extension ScanFlagViewController {
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
        arrayOfNamesToBeSearched = []
        indexOfNamesToBeSearched = 0
        
        guard let address1Text = devAddressOne.text else { self.view.makeToast(message: "Address can't be empty"); return }
        guard let address1 = Int(address1Text) else { self.view.makeToast(message: "Address can be only number"); return }
        addressOne = address1
        
        guard let address2Text = devAddressTwo.text else { self.view.makeToast(message: "Address can't be empty"); return }
        guard let address2 = Int(address2Text) else { self.view.makeToast(message: "Address can be only number"); return }
        addressTwo = address2
        
        guard let address3Text = devAddressThree.text else { self.view.makeToast(message: "Address can't be empty"); return }
        guard let address3 = Int(address3Text) else { self.view.makeToast(message: "Address can be only number"); return }
        addressThree = address3
        
        guard let rangeFromText = fromTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeFrom = Int(rangeFromText) else { self.view.makeToast(message: "Range can be only number"); return }
        
        guard let rangeToText = toTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeTo = Int(rangeToText) else { self.view.makeToast(message: "Range can be only number"); return }
        
        if rangeTo < rangeFrom { self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\""); return }
        for i in rangeFrom...rangeTo { arrayOfNamesToBeSearched.append(i) }
        
        shouldFindFlagParameters = true
        
        UIApplication.shared.isIdleTimerDisabled = true
        if arrayOfNamesToBeSearched.count != 0 {
            let firstFlagIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
            
            startProgressBar(type: .name)
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningFlagNames)
            checkForFlagName(withId: firstFlagIndexThatDontHaveName)
        }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    @objc func checkIfFlagDidGetName (_ timer:Foundation.Timer) {
        guard let flagIndex = timer.userInfo as? Int else { return }
        
        if timesRepeatedCounterNames < 3 {
            checkForFlagName(withId: flagIndex, shouldStartOver: false)
        } else {
            if let nextFlagIndexToBeSearched = indexOfFlagIndexInArrayOfNamesToBeSearch(afterIndex: flagIndex) {
                checkForFlagName(withId: nextFlagIndexToBeSearched)
            } else {
                dismissScaningControls()
            }
        }
    }
    
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    @objc func nameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningFlagNames) {
            guard let info = notification.userInfo! as? [String:Int] else { return }
            guard let flagIndex = info["flagId"] else { return }
            
            if let nextFlagIndexToBeSearched = indexOfFlagIndexInArrayOfNamesToBeSearch(afterIndex: flagIndex) {
                checkForFlagName(withId: nextFlagIndexToBeSearched)
            }
        }
    }
    
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithFlagAddress(_ flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(flagId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagName(address, flagId: UInt8(flagId + 100)) , gateway: self.gateway)
    }
    
    fileprivate func indexOfFlagIndexInArrayOfNamesToBeSearch(afterIndex flagIndex: Int) -> Int? {
        if let indexOfFlagIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: flagIndex) {
            if indexOfFlagIndexInArrayOfNamesToBeSearched + 1 < arrayOfNamesToBeSearched.count {
                indexOfNamesToBeSearched = indexOfFlagIndexInArrayOfNamesToBeSearched + 1
                let nextFlagIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                return nextFlagIndexToBeSearched
            } else {
                dismissScaningControls()
            }
        }
        return nil
    }
    fileprivate func checkForFlagName(withId id: Int, shouldStartOver: Bool = true) {
        if shouldStartOver { timesRepeatedCounterNames = 0 } else { timesRepeatedCounterNames += 1 }
        flagNameTimer?.invalidate()
        flagNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfFlagDidGetName(_:)), userInfo: id, repeats: false)
        sendCommandForFindingNameWithFlagAddress(id, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
    }
}

// MARK: - Parameter name
extension ScanFlagViewController {
    @objc func findParametarsForFlag() {
        progressBarScreenFlagNames?.dissmissProgressBar()
        progressBarScreenFlagNames = nil
        
        arrayOfParametersToBeSearched = []
        indexOfParametersToBeSearched = 0
        
        refreshFlagList()
        
        guard let rangeFromText = fromTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeFrom = Int(rangeFromText) else { self.view.makeToast(message: "Range can be only number"); return }
        let from = rangeFrom
        
        guard let rangeToText = toTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeTo = Int(rangeToText) else { self.view.makeToast(message: "Range can be only number"); return }
        let to = rangeTo
        
        if rangeTo < rangeFrom { self.view.makeToast(message: "Range \"from\" can't be higher than range \"to\""); return }
        
        for i in from...to {
            for flagTemp in flags { if flagTemp.flagId.intValue == i { arrayOfParametersToBeSearched.append(i) } }
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        if arrayOfParametersToBeSearched.count != 0 {
            let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
            
            startProgressBar(type: .parameters)
            checkForFlagParameter(withId: parameterIndex)
            defaults.set(true, forKey: UserDefaults.IsScaningFlagParameters)
        }
    }
    
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    @objc func checkIfFlagDidGetParametar (_ timer:Foundation.Timer) {
        guard let flagIndex = timer.userInfo as? Int else { return }
        
        if timesRepeatedCounterParameters < 3 {
            checkForFlagParameter(withId: flagIndex, shouldStartOver: false)
        } else {
            if let nextFlagIndexToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched(afterIndex: flagIndex) {
                checkForFlagParameter(withId: nextFlagIndexToBeSearched)
            }
        }
    }
    
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    @objc func flagParametarReceivedFromPLC (_ notification:Notification) {
        if defaults.bool(forKey: UserDefaults.IsScaningFlagParameters) {
            guard let info = notification.userInfo! as? [String:Int] else { return }
            guard let flagIndex = info["flagId"] else { return }
            
            if let nextFlagIndexToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched(afterIndex: flagIndex) {
                checkForFlagParameter(withId: nextFlagIndexToBeSearched)
            }
        }
    }
    
    fileprivate func indexOfDeviceIndexInArrayOfParametersToBeSearched(afterIndex flagIndex: Int) -> Int? {
        if let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: flagIndex) {
            if indexOfDeviceIndexInArrayOfParametersToBeSearched + 1 < arrayOfParametersToBeSearched.count {
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched + 1
                let nextFlagIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                return nextFlagIndexToBeSearched
            } else {
                dismissScanningFlagParameters()
            }
        }
        return nil
    }
    
    fileprivate func checkForFlagParameter(withId id: Int, shouldStartOver: Bool = true) {
        if shouldStartOver { timesRepeatedCounterParameters = 0 } else { timesRepeatedCounterParameters += 1 }
        flagParameterTimer?.invalidate()
        flagParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfFlagDidGetParametar(_:)), userInfo: id, repeats: false)
        sendCommandForFindingParameterWithFlagAddress(id, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
    }
    fileprivate func dismissScanningFlagParameters() {
        shouldFindFlagParameters = false
        dismissScaningControls()
    }
    
    
    
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithFlagAddress(_ flagId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        
        setProgressBarParametarsForFindingParameters(flagId)
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getFlagParametar(address, flagId: UInt8(flagId+100)) , gateway: self.gateway)
    }
}

// MARK: - Progress Bar
extension ScanFlagViewController {
    
    func setProgressBarParametarsForFindingNames (_ flagId:Int) {
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: flagId) { // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = progressBarScreenFlagNames?.lblHowMuchOf,
                let _ = progressBarScreenFlagNames?.lblPercentage,
                let _ = progressBarScreenFlagNames?.progressView {
                progressBarScreenFlagNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                progressBarScreenFlagNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                progressBarScreenFlagNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
        }
    }
    
    func setProgressBarParametarsForFindingParameters (_ flagId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.index(of: flagId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
            if let _ = progressBarScreenFlagNames?.lblHowMuchOf {
                if let _ = progressBarScreenFlagNames?.lblPercentage {
                    if let _ = progressBarScreenFlagNames?.progressView {
                        print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
                        progressBarScreenFlagNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1) / \(arrayOfParametersToBeSearched.count)"
                        progressBarScreenFlagNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)*100) + " %"
                        progressBarScreenFlagNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)
                    }
                }
            }
        }
    }
    
    fileprivate func startProgressBar(type: PBType) {
        var howMuchOf: Int!
        var title: String!
        switch type {
        case .name:
            howMuchOf = arrayOfNamesToBeSearched.count
            title = "Finding name"
        case .parameters:
            howMuchOf = arrayOfParametersToBeSearched.count
            title = "Finding flag parameters"
        }
        
        progressBarScreenFlagNames = nil
        progressBarScreenFlagNames = ProgressBarVC(title: title, percentage: Float(1)/Float(howMuchOf), howMuchOf: "1 / \(howMuchOf)")
        progressBarScreenFlagNames?.delegate = self
        self.present(progressBarScreenFlagNames!, animated: true, completion: nil)
    }
    
    fileprivate enum PBType {
        case name
        case parameters
    }
    
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
            _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(findParametarsForFlag), userInfo: nil, repeats: false)
        }
    }
}

// MARK: - Gallery Delegate
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

// MARK: - TextField Delegate
extension ScanFlagViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - TableView Data Source & Delegate
extension ScanFlagViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "flagsCell") as? FlagsCell {
            
            cell.setCell(flag: flags[indexPath.row])
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(flag: flags[indexPath.row])
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
            DatabaseFlagsController.shared.deleteFlag(flags[indexPath.row])
            flags.remove(at: indexPath.row)
            flagTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func didSelect(flag: Flag) {
        let flag0 = UIImage(named: "16 Flag - Flag - 00")
        let flag1 = UIImage(named: "16 Flag - Flag - 01")
        
        IDedit.text = "\(flag.flagId)"
        nameEdit.text = "\(flag.flagName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(flag.address.intValue))"
        broadcastSwitch.isOn = flag.isBroadcast.boolValue
        localcastSwitch.isOn = flag.isLocalcast.boolValue
        
        if let levelId = flag.entityLevelId as? Int { level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location); btnLevel.setTitle(level?.name, for: UIControlState())
        } else { btnLevel.setTitle("All", for: UIControlState()) }
        
        if let zoneId = flag.flagZoneId as? Int { zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location); btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        } else { btnZone.setTitle("All", for: UIControlState()) }
        
        if let categoryId = flag.flagCategoryId as? Int { category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location); btnCategory.setTitle(category?.name, for: UIControlState())
        } else { btnCategory.setTitle("All", for: UIControlState()) }
        
        defaultImageOne = flag.flagImageOneDefault
        customImageOne = flag.flagImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = flag.flagImageTwoDefault
        customImageTwo = flag.flagImageTwoCustom
        imageDataTwo = nil
        
        if let id = flag.flagImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageSceneOne.image = UIImage(data: data)
                } else {
                    if let defaultImage = flag.flagImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage)
                    } else { imageSceneOne.image = flag0 } }
                
            } else {
                if let defaultImage = flag.flagImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage)
                } else { imageSceneOne.image = flag0 } }
            
        } else {
            if let defaultImage = flag.flagImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage)
            } else { imageSceneOne.image = flag0 }
        }
        
        if let id = flag.flagImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageSceneTwo.image = UIImage(data: data)
                } else {
                    if let defaultImage = flag.flagImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage)
                    } else { imageSceneTwo.image = flag1 } }
                
            } else {
                if let defaultImage = flag.flagImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage)
                } else { imageSceneTwo.image = flag1 } }
            
        } else {
            if let defaultImage = flag.flagImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage)
            } else { imageSceneTwo.image = flag1 } }
        
    }
}

// MARK: - Logic
extension ScanFlagViewController {
    fileprivate func removeTapped(sender: UIButton) {
        showAlertView(sender, message:  "Are you sure you want to delete all flags?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseFlagsController.shared.deleteAllFlags(self.gateway)
                self.refreshFlagList()
                self.dismissEditing()
            }
        }
    }
    
    fileprivate func addTapped() {
        if let flagId = Int(IDedit.text!), let flagName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if flagId <= 32767 && address <= 255 {
                
                var levelId:Int?
                if let levelIdNumber = level?.id { levelId = levelIdNumber.intValue }
                
                var zoneId:Int?
                if let zoneIdNumber = zoneSelected?.id { zoneId = zoneIdNumber.intValue }
                
                var categoryId:Int?
                if let categoryIdNumber = category?.id { categoryId = categoryIdNumber.intValue }
                
                DatabaseFlagsController.shared.createFlag(flagId, flagName: flagName, moduleAddress: address, gateway: gateway, levelId: levelId, selectedZoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
                
            }
            refreshFlagList()
        } else {
            self.view.makeToast(message: "Please check fields: name, id and address")
        }
        dismissEditing()
    }
    
    fileprivate func openPopover(popOverType: PopOverType, sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        switch popOverType {
            case .level:
                let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(gateway.location)
                for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
            case .category:
                let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
                for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
            case .zone:
                if let level = level {
                    let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
                    for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
            }
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    fileprivate enum PopOverType {
        case level
        case category
        case zone
    }
}

// MARK: - Setup views
extension ScanFlagViewController {
    
    func refreshFlagList() {
        flags = DatabaseFlagsController.shared.updateFlagList(gateway, filterParametar: filterParametar)
        flagTableView.reloadData()
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(ScanFlagViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanFlagViewController.flagParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: nil)
    }
    
    func removeObservers(){
        defaults.set(false, forKey: UserDefaults.IsScaningFlagNames)
        defaults.set(false, forKey: UserDefaults.IsScaningFlagParameters)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagFromGateway), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidReceiveFlagParameterFromGateway), object: nil)
    }
    
    func setupViews() {
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.isUserInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        imageSceneTwo.isUserInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(gateway.addressOne.intValue))"
        devAddressOne.isEnabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(gateway.addressTwo.intValue))"
        devAddressTwo.isEnabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
    }
    
    @objc func handleTap (_ gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    
    fileprivate func clearRangeFields() {
        fromTextField.text = ""
        toTextField.text = ""
    }
}


