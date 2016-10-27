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
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    var sequences:[Sequence] = []
    
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
        
        refreshSequenceList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        editCycle.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.isUserInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        imageSceneTwo.isUserInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.isOn = false
        broadcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.isOn = false
        localcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), for: UIControlEvents.valueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanSequencesesViewController.nameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveSequenceFromGateway), object: nil)
    }
    
    override func sendFilterParametar(_ filterParametar: FilterItem) {
        self.filterParametar = filterParametar
        refreshSequenceList()
    }
    
    override func sendSearchBarText(_ text: String) {
        searchBarText = text
        refreshSequenceList()
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
    
    func refreshSequenceList() {
        sequences = DatabaseSequencesController.shared.updateSequenceList(gateway, filterParametar: filterParametar)
        if !searchBarText.isEmpty{
            sequences = self.sequences.filter() {
                sequence in
                if sequence.sequenceName.lowercased().range(of: searchBarText.lowercased()) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        sequencesTableView.reloadData()
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
        if let sequenceId = Int(IDedit.text!), let sequenceName = nameEdit.text, let address = Int(devAddressThree.text!), let cycles = Int(editCycle.text!) {
            if sequenceId <= 32767 && address <= 255 {
                
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
                
                DatabaseSequencesController.shared.createSequence(sequenceId, sequenceName: sequenceName, moduleAddress: address, gateway: gateway, levelId: levelId, zoneId: zoneId, categoryId: categoryId, isBroadcast: broadcastSwitch.isOn, isLocalcast: localcastSwitch.isOn, sceneImageOneDefault: defaultImageOne, sceneImageTwoDefault: defaultImageTwo, sceneImageOneCustom: customImageOne, sceneImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo, sequenceCycles: cycles)
            }
            refreshSequenceList()
            self.view.endEditing(true)
        }else{
            self.view.makeToast(message: "Please check fields: name, id and address")
        }
    }
    
    @IBAction func scanSequences(_ sender: AnyObject) {
        findSequences()
    }
    
    @IBAction func clearRangeFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    @IBAction func btnRemove(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all sequences?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseSequencesController.shared.deleteAllSequences(self.gateway)
                self.refreshSequenceList()
                self.view.endEditing(true)
            }
        }
    }

    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var sequencesTimer:Foundation.Timer?
    var timesRepeatedCounter:Int = 0
    var arrayOfSequencesToBeSearched = [Int]()
    var indexOfSequencesToBeSearched = 0
    var progressBarScreenSequences: ProgressBarVC?
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findSequences() {
            arrayOfSequencesToBeSearched = [Int]()
            indexOfSequencesToBeSearched = 0
            
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
                self.view.makeToast(message: "Range is not properly set")
                return
            }
            for i in from...to{
                arrayOfSequencesToBeSearched.append(i)
            }
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfSequencesToBeSearched.count != 0{
                let firstSequenceIndexThatDontHaveName = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                timesRepeatedCounter = 0
                progressBarScreenSequences = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfSequencesToBeSearched.count), howMuchOf: "1 / \(arrayOfSequencesToBeSearched.count)")
                progressBarScreenSequences?.delegate = self
                self.present(progressBarScreenSequences!, animated: true, completion: nil)
                sequencesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: firstSequenceIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstSequenceIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningSequencesNameAndParameters)
                sendCommandWithSequenceAddress(firstSequenceIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
    }
    // Called from findSequences or from it self.
    // Checks which sequence ID should be searched for and calls sendCommandWithSequenceAddress for that specific sequence id.
    func checkIfSequenceDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let sequenceIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounter += 1
        if timesRepeatedCounter < 3 {
            sequencesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: sequenceIndex, repeats: false)
            NSLog("func checkIfSceneDidGetName \(sequenceIndex)")
            sendCommandWithSequenceAddress(sequenceIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.index(of: sequenceIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfSequencesToBeSearched+1 < arrayOfSequencesToBeSearched.count{ // if next exists
                    indexOfSequencesToBeSearched = indexOfSequenceIndexInArrayOfNamesToBeSearched+1
                    let nextSceneIndexToBeSearched = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                    timesRepeatedCounter = 0
                    sequencesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: nextSceneIndexToBeSearched, repeats: false)
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
    func nameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningSequencesNameAndParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            // 1. Data that is received through notification is: sequenceAddress and sequenceId
            // 2. We need to search sequences and find that sequence, and get it's index
            // 3. then, we find that index in "indexOfSequenceIndexInArrayOfNamesToBeSearched".
            //NOTE: indexOfSequenceIndexInArrayOfNamesToBeSearched is the array of all sequences that user defined to be scanned. (sequence indexes in sequences)
            //1.
            guard let sequenceAddress  = info["sequenceAddress"] else{
                return
            }
            guard let sequenceId  = info["sequenceId"] else{
                return
            }
            let sequenceTemp = self.sequences.filter({ (s) -> Bool in
                return (Int(s.address) == sequenceAddress && Int(s.sequenceId) == sequenceId)
            })
            
            if sequenceTemp.count > 0 {
                //2.
                guard let sequenceIndex = self.sequences.index(of: sequenceTemp.first!) else{
                    return
                }
                //3.
                guard let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.index(of: sequenceIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                    return
                }
                if indexOfSequenceIndexInArrayOfNamesToBeSearched+1 < arrayOfSequencesToBeSearched.count{ // if next exists
                    indexOfSequencesToBeSearched = indexOfSequenceIndexInArrayOfNamesToBeSearched+1
                    let nextSequenceIndexToBeSearched = arrayOfSequencesToBeSearched[indexOfSequencesToBeSearched]
                    
                    timesRepeatedCounter = 0
                    sequencesTimer?.invalidate()
                    sequencesTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanSequencesesViewController.checkIfSequenceDidGetName(_:)), userInfo: nextSequenceIndexToBeSearched, repeats: false)
                    NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextSequenceIndexToBeSearched)")
                    sendCommandWithSequenceAddress(nextSequenceIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }
        }
    }
    func sendCommandWithSequenceAddress(_ sequenceId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametars(sequenceId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getSequenceNameAndParametar(address, sequenceId: UInt8(sequenceId)) , gateway: self.gateway)
    }
    func setProgressBarParametars (_ sequenceId:Int) {
        if let indexOfSequenceIndexInArrayOfNamesToBeSearched = arrayOfSequencesToBeSearched.index(of: sequenceId){
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
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningSequencesNameAndParameters)
        progressBarScreenSequences!.dissmissProgressBar()
        
        arrayOfSequencesToBeSearched = [Int]()
        indexOfSequencesToBeSearched = 0
        UIApplication.shared.isIdleTimerDisabled = false
        refreshSequenceList()
    }
}

extension ScanSequencesesViewController: SceneGalleryDelegate{
    
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

extension ScanSequencesesViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanSequencesesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "sequencesCell") as? SequencesCell {
            cell.backgroundColor = UIColor.clear
            cell.labelID.text = "\(sequences[(indexPath as NSIndexPath).row].sequenceId)"
            cell.labelName.text = "\(sequences[(indexPath as NSIndexPath).row].sequenceName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(sequences[(indexPath as NSIndexPath).row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(sequences[(indexPath as NSIndexPath).row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(sequences[(indexPath as NSIndexPath).row].address)))"
            if let id = sequences[(indexPath as NSIndexPath).row].sequenceImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }
            }
            
            if let id = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }
                    }
                }else{
                    if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        IDedit.text = "\(sequences[(indexPath as NSIndexPath).row].sequenceId)"
        nameEdit.text = "\(sequences[(indexPath as NSIndexPath).row].sequenceName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(sequences[(indexPath as NSIndexPath).row].address)))"
        editCycle.text = "\(sequences[(indexPath as NSIndexPath).row].sequenceCycles)"
        broadcastSwitch.isOn = sequences[(indexPath as NSIndexPath).row].isBroadcast.boolValue
        localcastSwitch.isOn = sequences[(indexPath as NSIndexPath).row].isLocalcast.boolValue
        
        if let levelId = sequences[(indexPath as NSIndexPath).row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
            btnLevel.setTitle(level?.name, for: UIControlState())
        }else{
            btnLevel.setTitle("All", for: UIControlState())
        }
        if let zoneId = sequences[(indexPath as NSIndexPath).row].sequenceZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
            btnZone.setTitle(zoneSelected?.name, for: UIControlState())
        }else{
            btnZone.setTitle("All", for: UIControlState())
        }
        if let categoryId = sequences[(indexPath as NSIndexPath).row].sequenceCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
            btnCategory.setTitle(category?.name, for: UIControlState())
        }else{
            btnCategory.setTitle("All", for: UIControlState())
        }
        
        defaultImageOne = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault
        customImageOne = sequences[(indexPath as NSIndexPath).row].sequenceImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault
        customImageTwo = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoCustom
        imageDataTwo = nil
        
        if let id = sequences[(indexPath as NSIndexPath).row].sequenceImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = sequences[(indexPath as NSIndexPath).row].sequenceImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sequences.count
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.sequencesTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseSequencesController.shared.deleteSequence(sequences[(indexPath as NSIndexPath).row])
            sequences.remove(at: (indexPath as NSIndexPath).row)
            sequencesTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
}


