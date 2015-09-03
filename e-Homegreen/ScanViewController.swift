//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit
import CoreData

class ScanViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, SceneGalleryDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    var choosedTab:ChoosedTab = .Devices
    var senderButton:UIButton?
    enum ChoosedTab {
        case Devices
        case Scenes
        case Events
        case Sequences
    }

    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sceneView: UIView!
    @IBOutlet weak var deviceView: UIView!
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var isPresenting:Bool = true
    var gateway:Gateway?
    var devices:[Device] = []
    var choosedTabArray:[AnyObject] = []
    var loader : ViewControllerUtils = ViewControllerUtils()
    
    @IBOutlet weak var deviceTableView: UITableView!
    @IBOutlet weak var sceneTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        sceneView.hidden = true
        devAddressOne.text = "\(gateway?.addressOne)"
        devAddressTwo.text = "\(gateway?.addressTwo)"
        devAddressThree.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width {
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        } else {
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        rangeFrom.text = "\(Int(gateway!.addressThree) + 1)"
        rangeTo.text = "\(Int(gateway!.addressThree) + 1)"
        rangeFrom.delegate = self
        rangeTo.delegate = self
        refreshDeviceList()
        
        IDedit.delegate = self
        nameEdit.delegate = self
        refreshSceneList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: "PLCdidFindNameForDevice", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceReceivedFromPLC:", name: "PLCDidFindDevice", object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            self.imageHeight.constant = 50
        }else{
            
            self.imageHeight.constant = 120
            
        }
    }
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index).delegate = self
        }
    }
    
    func backString(strText: String, imageIndex:Int) {
        if imageIndex == 1 {
            self.imageSceneOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            self.imageSceneTwo.image = UIImage(named: strText)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var btnScreenMode: UIButton!
    @IBAction func btnScreenMode(sender: AnyObject) {
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            btnScreenMode.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            btnScreenMode.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func updateSceneList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Scene")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Scene]
        if let results = fetResults {
            choosedTabArray = results
        } else {
            println("Nije htela...")
        }
    }
    func updateListFetchingFromCD (entity:String, entityId:String, entityName:String) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: entity)
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: entityId, ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: entityName, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        switch entity {
        case "Scene":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Scene] {
                choosedTabArray = fetResults
            }
        case "Event":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Event] {
                choosedTabArray = fetResults
            }
        case "Sequence":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Sequence] {
                choosedTabArray = fetResults
            }
        default:
            println()
        }
    }
    func updateDeviceList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        var sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
    }
    func refreshSceneList() {
        updateSceneList()
        sceneTableView.reloadData()
    }
    func refreshDeviceList() {
        updateDeviceList()
        deviceTableView.reloadData()
    }
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        self.performSegueWithIdentifier("scanUnwind", sender: self)
    }
    
    
    @IBAction func btnAdd(sender: AnyObject) {
        if choosedTab == .Scenes {
            if let sceneId = IDedit.text.toInt(), let sceneName = nameEdit.text {
                if sceneId <= 32767 {
                    var scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
                    scene.sceneId = sceneId
                    scene.sceneName = sceneName
                    scene.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image)
                    scene.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
                    scene.gateway = gateway!
                    saveChanges()
                    refreshSceneList()
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
                }
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if choosedTab == .Scenes {
            if let scene = selected as? Scene{
                appDel.managedObjectContext!.deleteObject(scene)
            }
            IDedit.text = ""
            nameEdit.text = ""
            refreshSceneList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
        }
    }
    
    // ======================= *** FINDING DEVICES FOR GATEWAY *** =======================
    
    var searchDeviceTimer:NSTimer?
    var searchForDeviceWithId:Int?
    var fromAddress:Int?
    var toAddress:Int?

    @IBAction func findDevice(sender: AnyObject) {
        if rangeFrom.text != "" && rangeTo.text != "" {
            if let numberOne = rangeFrom.text.toInt(), let numberTwo = rangeTo.text.toInt() {
                if numberTwo >= numberOne {
                    fromAddress = numberOne
                    toAddress = numberTwo
                    searchForDeviceWithId = numberOne
                    timesRepeatedCounter = 0
                    loader.showActivityIndicator(self.view)
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                }
            }
        }
    }
    
    func checkIfGatewayDidGetDevice (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            updateDeviceList()
            if (timesRepeatedCounter + 1) != 4 {
                timesRepeatedCounter = timesRepeatedCounter + 1
                var deviceFound = false
                // OVDE JE PUKLO JEDNOM!!!
                if devices.count > 0 {
                for i in 0...devices.count-1 {
                    if Int(devices[i].address) == index {
                        deviceFound = true
                        break
                    }
                }
                }
                if deviceFound {
                    if toAddress >= (searchForDeviceWithId!+1) {
                        timesRepeatedCounter = 0
                        searchForDeviceWithId = searchForDeviceWithId! + 1
                        searchDeviceTimer?.invalidate()
                        searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                        var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                        SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                    } else {
                        loader.hideActivityIndicator()
                    }
                } else {
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                }
            } else {
                if toAddress >= searchForDeviceWithId {
                    timesRepeatedCounter = 0
                    searchForDeviceWithId = searchForDeviceWithId! + 1
                    searchDeviceTimer?.invalidate()
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                } else {
                    loader.hideActivityIndicator()
                }
            }
        }
    }
    
    func deviceReceivedFromPLC (notification:NSNotification) {
                if toAddress >= (searchForDeviceWithId!+1) {
                    timesRepeatedCounter = 0
                    searchForDeviceWithId = searchForDeviceWithId! + 1
                    searchDeviceTimer?.invalidate()
                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
                } else {
                    searchForDeviceWithId = 0
                    timesRepeatedCounter = 0
                    searchDeviceTimer?.invalidate()
                    loader.hideActivityIndicator()
                }
    }
    
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
    
    // ======================= *** FINDING NAMES FOR DEVICE *** =======================
    
    var deviceNameTimer:NSTimer?
    
    @IBAction func findNames(sender: AnyObject) {
        var index:Int
        if devices.count != 0 {
            index = 0
            timesRepeatedCounter = 0
            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: 0, repeats: false)
            sendCommandForFindingName(index: 0)
        }
    }
    
    var index:Int = 0
    var timesRepeatedCounter:Int = 0
    
    func nameReceivedFromPLC (notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Int] {
            if let deviceIndex = info["deviceIndexForFoundName"] {
                if deviceIndex == devices.count-1 {
                    index = 0
                    timesRepeatedCounter = 0
                } else {
                    index = deviceIndex + 1
                    timesRepeatedCounter = 0
                    deviceNameTimer?.invalidate()
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: index, repeats: false)
                    sendCommandForFindingName(index: index)
                }
            }
        }
    }
    
    func checkIfDeviceDidGetName (timer:NSTimer) {
        if let deviceIndex = timer.userInfo as? Int {
            if index != 0 || deviceIndex < index {
                //                index = index + 1
                timesRepeatedCounter += 1
                if timesRepeatedCounter < 4 {
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: deviceIndex, repeats: false)
                    sendCommandForFindingName(index: deviceIndex)
                } else {
                    var newIndex = deviceIndex + 1
                    timesRepeatedCounter = 0
                    deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: newIndex, repeats: false)
                    sendCommandForFindingName(index: newIndex)
                }
            }
        }
    }
    
    func sendCommandForFindingName (#index:Int) {
        if devices[index].type == "Dimmer" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "curtainsRelay" || devices[index].type == "appliance" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "hvac" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "sensor" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Function.getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            SendingHandler(byteArray: Function.getSensorZone(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
    }
    
    func getDevicesNames (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            sendCommandForFindingName(index: index)
        }
    }
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    @IBAction func btnScenes(sender: AnyObject) {
        
            senderButton = sender as? UIButton
            
            popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.preferredContentSize = CGSizeMake(300, 200)
            popoverVC.delegate = self
            popoverVC.indexTab = 6
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.delegate = self
                popoverController.permittedArrowDirections = .Any
                popoverController.sourceView = sender as! UIView
                popoverController.sourceRect = sender.bounds
                popoverController.backgroundColor = UIColor.lightGrayColor()
                presentViewController(popoverVC, animated: true, completion: nil)
                
            }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func saveText(strText: String) {
        println(reverse(strText))
        senderButton?.setTitle(strText, forState: .Normal)
        if strText == "Devices" {
            choosedTab = .Devices
            sceneTableView.reloadData()
            sceneView.hidden = true
            deviceView.hidden = false
        }
        if strText == "Scenes" {
            choosedTab = .Scenes
            updateListFetchingFromCD("Scene", entityId: "sceneId", entityName: "sceneName")
            sceneTableView.reloadData()
            sceneView.hidden = false
            deviceView.hidden = true
        }
        if strText == "Events" {
            choosedTab = .Events
            updateListFetchingFromCD("Event", entityId: "eventId", entityName: "eventName")
            sceneTableView.reloadData()
            sceneView.hidden = false
            deviceView.hidden = true
        }
        if strText == "Sequences" {
            choosedTab = .Sequences
            updateListFetchingFromCD("Sequence", entityId: "sequenceId", entityName: "sequenceName")
            sceneTableView.reloadData()
            sceneView.hidden = false
            deviceView.hidden = true
        }
    }
    
    
    // ======================= *** DELETING DEVICES FOR GATEWAY *** =======================
    
    @IBAction func deleteAll(sender: AnyObject) {
        for var item = 0; item < devices.count; item++ {
            if devices[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(devices[item])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    // ======================= *** TABLE VIEW *** =======================
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == deviceTableView {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblRow.text = "\(indexPath.row+1)."
            cell.lblDesc.text = "\(devices[indexPath.row].name)"
            cell.lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
            cell.lblType.text = "Type: \(devices[indexPath.row].type)"
            return cell
        }
        }
        if tableView == sceneTableView {
            if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
                cell.backgroundColor = UIColor.clearColor()
                cell.labelID.text = "\(choosedTabArray[indexPath.row].sceneId)"
                cell.labelName.text = "\(choosedTabArray[indexPath.row].sceneName)"
                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
                    cell.imageOne.image = sceneImage
                }
                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
                    cell.imageTwo.image = sceneImage
                }
                return cell
            }
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sceneTableView{
            return choosedTabArray.count
        }
        return devices.count
    }
    var selected:AnyObject?
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == sceneTableView {
            if choosedTab == .Scenes {
                selected = choosedTabArray[indexPath.row]
                IDedit.text = "\(choosedTabArray[indexPath.row].sceneId)"
                nameEdit.text = "\(choosedTabArray[indexPath.row].sceneName)"
                devAddressThree.text = "\(choosedTabArray[indexPath.row].address)"
                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
                    imageSceneOne.image = sceneImage
                }
                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
                    imageSceneTwo.image = sceneImage
                }
            }
        }
    }
    
}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    
}

class SceneCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!

    
}
