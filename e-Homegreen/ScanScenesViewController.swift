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
        
        refreshSceneList()
        setupViews()
        
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveSceneFromGateway), object: nil)
        
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
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
    }
    
    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshSceneList()
    }
    
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshSceneList()
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
    
    func changeValue (_ sender:UISwitch) {
        if sender.tag == 100 { localcastSwitch.isOn = false } else if sender.tag == 200 { broadcastSwitch.isOn = false }
    }
    
    func refreshSceneList() {
        scenes = DatabaseScenesController.shared.updateSceneList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty {
            scenes = self.scenes.filter() {
                scene in
                if scene.sceneName.lowercased().range(of: searchBarText.lowercased()) != nil { return true } else { return false }
            }
        }
        sceneTableView.reloadData()
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
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(gateway.location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnZoneAction(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnAdd(_ sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                
                var levelId:Int?
                if let levelIdNumber = level?.id { levelId = Int(levelIdNumber) }
                
                var zoneId:Int?
                if let zoneIdNumber = zoneSelected?.id { zoneId = Int(zoneIdNumber) }
                
                var categoryId:Int?
                if let categoryIdNumber = category?.id { categoryId = Int(categoryIdNumber) }
                
                DatabaseScenesController.shared.createScene(sceneId, sceneName: sceneName, moduleAddress: address, gateway: gateway, levelId: levelId, zoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)

            }
        } else {
            self.view.makeToast(message: "Please check fields: name, id and address")
        }
        refreshSceneList()
        dismissEditing()
    }
    
    @IBAction func scanScenes(_ sender: AnyObject) {
        findScenes()
    }
    
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all scenes?") { (action) in
            if action == ReturnedValueFromAlertView.delete {
                DatabaseScenesController.shared.deleteAllScenes(self.gateway)
                self.refreshSceneList()
                dismissEditing()
            }
        }
    }
    
    
    // MARK: - FINDING SCENES
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var scenesTimer:Foundation.Timer?
    var timesRepeatedCounter:Int = 0
    var arrayOfScenesToBeSearched = [Int]()
    var indexOfScenesToBeSearched = 0
    var progressBarScreenScenes: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findScenes() {
        arrayOfScenesToBeSearched = [Int]()
        indexOfScenesToBeSearched = 0
        
        guard let address1Text = devAddressOne.text else { return }
        guard let address1 = Int(address1Text) else { return }
        addressOne = address1
        
        guard let address2Text = devAddressTwo.text else { return }
        guard let address2 = Int(address2Text) else { return }
        addressTwo = address2
        
        guard let address3Text = devAddressThree.text else { self.view.makeToast(message: "Address can't be empty"); return }
        guard let address3 = Int(address3Text) else { self.view.makeToast(message: "Address can be only number"); return }
        addressThree = address3
        
        guard let rangeFromText = fromTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeFrom = Int(rangeFromText) else { self.view.makeToast(message: "Range can be only number"); return }
        let from = rangeFrom
        
        guard let rangeToText = toTextField.text else { self.view.makeToast(message: "Range can't be empty"); return }
        guard let rangeTo = Int(rangeToText) else { self.view.makeToast(message: "Range can be only number"); return }
        let to = rangeTo
        
        if rangeTo < rangeFrom { self.view.makeToast(message: "Range is not properly set"); return }
        for i in from...to { arrayOfScenesToBeSearched.append(i) }
        
        UIApplication.shared.isIdleTimerDisabled = true
        if arrayOfScenesToBeSearched.count != 0 {
            let firstSceneIndexThatDontHaveName = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
            timesRepeatedCounter = 0
            progressBarScreenScenes = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfScenesToBeSearched.count), howMuchOf: "1 / \(arrayOfScenesToBeSearched.count)")
            progressBarScreenScenes?.delegate = self
            self.present(progressBarScreenScenes!, animated: true, completion: nil)
            scenesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: firstSceneIndexThatDontHaveName, repeats: false)
            NSLog("func findNames \(firstSceneIndexThatDontHaveName)")
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningSceneNameAndParameters)
            sendCommandWithSceneAddress(firstSceneIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }
    }
    // Called from findScenes or from it self.
    // Checks which scene ID should be searched for and calls sendCommandWithSceneAddress for that specific scene id.
    func checkIfSceneDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let sceneIndex = timer.userInfo as? Int else { return }
        
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            scenesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfSceneDidGetName(_:)), userInfo: sceneIndex, repeats: false)
            NSLog("func checkIfSceneDidGetName \(sceneIndex)")
            sendCommandWithSceneAddress(sceneIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        } else {
            if let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.index(of: sceneIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfScenesToBeSearched+1 < arrayOfScenesToBeSearched.count { // if next exists
                    indexOfScenesToBeSearched = indexOfSceneIndexInArrayOfNamesToBeSearched+1
                    let nextSceneIndexToBeSearched = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                    timesRepeatedCounter = 0
                    scenesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkIfSceneDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                    NSLog("func checkIfSceneDidGetName \(nextSceneIndexToBeSearched)")
                    sendCommandWithSceneAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                } else {
                    dismissScaningControls()
                }
            } else {
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next scene ID to search for. If there is not, dismiss progres bar and end the search.
    func nameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSceneNameAndParameters) {
            guard let info = notification.userInfo! as? [String:Int] else { return }
            guard let sceneIndex = info["sceneId"] else { return }
            guard let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.index(of: sceneIndex) else { return } // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            
            if indexOfSceneIndexInArrayOfNamesToBeSearched+1 < arrayOfScenesToBeSearched.count { // if next exists
                indexOfScenesToBeSearched = indexOfSceneIndexInArrayOfNamesToBeSearched+1
                let nextSceneIndexToBeSearched = arrayOfScenesToBeSearched[indexOfScenesToBeSearched]
                
                timesRepeatedCounter = 0
                scenesTimer?.invalidate()
                scenesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanScenesViewController.checkIfSceneDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextSceneIndexToBeSearched)")
                sendCommandWithSceneAddress(nextSceneIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            } else {
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandWithSceneAddress(_ sceneId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(sceneId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getSceneNameAndParametar(address, sceneId: UInt8(sceneId)) , gateway: self.gateway)
    }
    
    func setProgressBarParametars (_ sceneId:Int) {
        if let indexOfSceneIndexInArrayOfNamesToBeSearched = arrayOfScenesToBeSearched.index(of: sceneId){
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
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningSceneNameAndParameters)
        progressBarScreenScenes!.dissmissProgressBar()
        
        arrayOfScenesToBeSearched = [Int]()
        indexOfScenesToBeSearched = 0
        UIApplication.shared.isIdleTimerDisabled = false
        refreshSceneList()
    }
}

extension ScanScenesViewController: SceneGalleryDelegate {
    
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

extension ScanScenesViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanScenesViewController:  UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "scenesCell") as? ScenesCell {
            
            cell.setCell(scene: scenes[indexPath.row])
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(scene: scenes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.sceneTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseScenesController.shared.deleteScene(scenes[indexPath.row])
            scenes.remove(at: indexPath.row)
            sceneTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func didSelect(scene: Scene) {
        IDedit.text = "\(scene.sceneId)"
        nameEdit.text = "\(scene.sceneName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(scene.address)))"
        broadcastSwitch.isOn = scene.isBroadcast.boolValue
        localcastSwitch.isOn = scene.isLocalcast.boolValue
        
        if let levelId = scene.entityLevelId as? Int { level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location); btnLevel.setTitle(level?.name, for: UIControlState())
        } else { btnLevel.setTitle("All", for: UIControlState()) }
        
        if let zoneId = scene.sceneZoneId as? Int { zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location); btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        } else { btnZone.setTitle("All", for: UIControlState()) }
        
        if let categoryId = scene.sceneCategoryId as? Int { category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location); btnCategory.setTitle(category?.name, for: UIControlState())
        } else { btnCategory.setTitle("All", for: UIControlState()) }
        
        defaultImageOne = scene.sceneImageOneDefault
        customImageOne = scene.sceneImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = scene.sceneImageTwoDefault
        customImageTwo = scene.sceneImageTwoCustom
        imageDataTwo = nil
        
        if let id = scene.sceneImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data = image.imageData { imageSceneOne.image = UIImage(data: data)
                } else { if let defaultImage = scene.sceneImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = scene.sceneImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = scene.sceneImageOneDefault { imageSceneOne.image = UIImage(named: defaultImage) } }
        
        if let id = scene.sceneImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data = image.imageData { imageSceneTwo.image = UIImage(data: data)
                } else { if let defaultImage = scene.sceneImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage) } }
                
            } else { if let defaultImage = scene.sceneImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage) } }
        } else { if let defaultImage = scene.sceneImageTwoDefault { imageSceneTwo.image = UIImage(named: defaultImage) } }
        
    }
}


