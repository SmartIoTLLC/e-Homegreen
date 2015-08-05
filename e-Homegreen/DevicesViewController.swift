//
//  DevicesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DeviceImage:NSObject{
    var image:UIImage!
    var text:String!
    var open:Bool!
    var value:Float!
    var stateOpening:Bool!
    var info:Bool!
    
    init(image:UIImage, text:String) {
        self.image = image
        self.text = text
        self.open = false
        self.value = 0
        self.stateOpening = true
        self.info = false
    }
}

class DevicesViewController: CommonViewController, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate, UIGestureRecognizerDelegate {
    
    private var sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    private let reuseIdentifier = "deviceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var myView:Array<UIView> = []
    var mySecondView:Array<UIView> = []
    
    var timer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        commonConstruct()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
        updateDeviceList()
        var byteArray = [12, 78, 111, 105, 115, 101, 32, 83, 101, 110, 115, 111, 114]
        var string:String = ""
        for var i = 0; i < byteArray.count; i++ {
            string = string + "\(Character(UnicodeScalar(Int(byteArray[i]))))" //  device name
        }
        println("NEKI TEST: \(string)")
        
    }
    
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    
    func updateDeviceList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        var sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
//            for item in devices {
//                println("!\(item.gateway.turnedOn)!")
//            }
        } else {
        }
    }
    override func viewDidAppear(animated: Bool) {
        if let indexPaths = deviceCollectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
            for indexPath in indexPaths {
                if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as NSDate? {
                    if NSDate().timeIntervalSinceDate(stateUpdatedAt.dateByAddingTimeInterval(60)) >= 0 {
                        updateDeviceStatus (indexPathRow: indexPath.row)
                    }
                } else {
                    updateDeviceStatus (indexPathRow: indexPath.row)
                }
            }
        }
    }
    func cellParametarLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        var tag = gestureRecognizer.view?.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItemAtPoint(location){
                var cell = deviceCollectionView.cellForItemAtIndexPath(index)
                if devices[index.row].type == "Dimmer" {
                    showDimmerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].type == "sensor" {
                    showDigitalInputParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].type == "hvac" {
                    showClimaParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                    showRelayParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                if devices[index.row].type == "curtainsRS485" {
                    showCellParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                
//                showCellParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))

//                showAccessParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))



                println("nistaa")
            }
        }
    }
    
    func longTouch(gestureRecognizer: UILongPressGestureRecognizer){
        // Light
        var tag = gestureRecognizer.view?.tag
        if devices[tag!].type == "Dimmer" {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag!].opening == true {
                    devices[tag!].opening = false
                }else {
                    devices[tag!].opening = true
                }
                return
            }
        }
        if devices[tag!].type == "curtainsRS485" {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurtain:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag!].opening == true {
                    devices[tag!].opening = false
                }else {
                    devices[tag!].opening = true
                }
                return
            }
        }
    }
    
    func oneTap(gestureRecognizer:UITapGestureRecognizer){
        var tag = gestureRecognizer.view?.tag
        // Light
        if devices[tag!].type == "Dimmer" {
            var setDeviceValue:UInt8 = 0
            if devices[tag!].currentValue == 100 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            devices[tag!].currentValue = Int(setDeviceValue)
            var address = [UInt8(Int(devices[tag!].gateway.addressOne)),UInt8(Int(devices[tag!].gateway.addressTwo)),UInt8(Int(devices[tag!].address))]
            SendingHandler(byteArray: Functions().setLightRelayStatus(address, channel: UInt8(Int(devices[tag!].channel)), value: setDeviceValue, runningTime: 0x00), gateway: devices[tag!].gateway)
        }
        // Appliance?
        if devices[tag!].type == "curtainsRelay" || devices[tag!].type == "appliance" {
            var address = [UInt8(Int(devices[tag!].gateway.addressOne)),UInt8(Int(devices[tag!].gateway.addressTwo)),UInt8(Int(devices[tag!].address))]
            SendingHandler(byteArray: Functions().setLightRelayStatus(address, channel: UInt8(Int(devices[tag!].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag!].gateway)
        }
        // Curtain?
        if devices[tag!].type == "curtainsRS485" {
            var setDeviceValue:UInt8 = 0
            if devices[tag!].currentValue == 100 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            var address = [UInt8(Int(devices[tag!].gateway.addressOne)),UInt8(Int(devices[tag!].gateway.addressTwo)),UInt8(Int(devices[tag!].address))]
            SendingHandler(byteArray: Functions().setCurtainStatus(address, channel:  UInt8(Int(devices[tag!].channel)), value: setDeviceValue), gateway: devices[tag!].gateway)
            
        }
        
        deviceCollectionView.reloadData()
    }
    
    func update(timer: NSTimer){
        if let tag = timer.userInfo as? Int {
            var deviceValue = Double(devices[tag].currentValue)/100
            if devices[tag].opening == true{
                if deviceValue < 1 {
                    deviceValue += 0.05
                }
            } else {
                if deviceValue >= 0.05 {
                    deviceValue -= 0.05
                }
            }
            var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            SendingHandler(byteArray: Functions().setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(deviceValue*100)), runningTime: 0x00), gateway: devices[tag].gateway)
            self.devices[tag].currentValue = Int(deviceValue*100)
            UIView.setAnimationsEnabled(false)
            self.deviceCollectionView.performBatchUpdates({
                var indexPath = NSIndexPath(forItem: tag, inSection: 0)
                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
                }, completion:  {(completed: Bool) -> Void in
                    UIView.setAnimationsEnabled(true)
            })
        }
    }
    func updateCurtain(timer: NSTimer){
        if let tag = timer.userInfo as? Int {
            var deviceValue = Double(devices[tag].currentValue)/100
            if devices[tag].opening == true{
                if deviceValue < 1 {
                    deviceValue += 0.20
                }
            } else {
                if deviceValue >= 0.20 {
                    deviceValue -= 0.20
                }
            }
            var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            SendingHandler(byteArray: Functions().setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(deviceValue*100))), gateway: devices[tag].gateway)
            self.devices[tag].currentValue = Int(deviceValue*100)
            UIView.setAnimationsEnabled(false)
            self.deviceCollectionView.performBatchUpdates({
                var indexPath = NSIndexPath(forItem: tag, inSection: 0)
                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
                }, completion:  {(completed: Bool) -> Void in
                    UIView.setAnimationsEnabled(true)
            })
        }
    }
    
    override func viewWillLayoutSubviews() {
        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            
            drawMenu()
            
            deviceCollectionView.reloadData()
            
        } else {
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
            
            
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            
            drawMenu()
            
            deviceCollectionView.reloadData()
        }
    }
    
    func drawMenu(){
        var locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(locationLabel)
        
        var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(levelLabel)
        
        var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
        zoneLabel.text = "Zone"
        zoneLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(zoneLabel)
        
        var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
        categoryLabel.text = "Category"
        categoryLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(categoryLabel)
        
        var locationButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
        locationButton.backgroundColor = UIColor.grayColor()
        locationButton.titleLabel?.tintColor = UIColor.whiteColor()
        locationButton.setTitle("All", forState: UIControlState.Normal)
        locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationButton.layer.borderWidth = 1
        locationButton.tag = 1
        locationButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(locationButton)
        
        var levelButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
        levelButton.backgroundColor = UIColor.grayColor()
        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        levelButton.setTitle("All", forState: UIControlState.Normal)
        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        levelButton.layer.cornerRadius = 5
        levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        levelButton.layer.borderWidth = 1
        levelButton.tag = 2
        levelButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(levelButton)
        
        var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
        zoneButton.backgroundColor = UIColor.grayColor()
        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        zoneButton.setTitle("All", forState: UIControlState.Normal)
        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        zoneButton.layer.cornerRadius = 5
        zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        zoneButton.layer.borderWidth = 1
        zoneButton.tag = 3
        zoneButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(zoneButton)
        
        var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
        categoryButton.backgroundColor = UIColor.grayColor()
        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        categoryButton.setTitle("All", forState: UIControlState.Normal)
        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        categoryButton.layer.cornerRadius = 5
        categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        categoryButton.layer.borderWidth = 1
        categoryButton.tag = 4
        categoryButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(categoryButton)
    }
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    func menuTable(sender : UIButton){
        senderButton = sender
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = sender.tag
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
            
        }
    }
    
    func saveText(strText: String) {
        senderButton?.setTitle(strText, forState: .Normal)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func infoView() -> UIView {
        var info:UIView = UIView(frame: CGRectMake(0, 0, collectionViewCellSize.width, collectionViewCellSize.height))
        info.backgroundColor = UIColor.grayColor()
        var idLabel:UILabel = UILabel(frame: CGRectMake(10, 10, 100, 30))
        idLabel.textColor = UIColor.whiteColor()
        idLabel.text = "hakhdakhdj"
        info.addSubview(idLabel)
        info.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
        //        let gradientLayer = CAGradientLayer()
        //        gradientLayer.frame = info.bounds
        //        gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        //        gradientLayer.locations = [0.0, 1.0]
        //        info.layer.insertSublayer(gradientLayer, atIndex: 0)
        return info
    }
    
    func handleTap (gesture:UIGestureRecognizer) {
        println("nesto")
        UIView.transitionFromView(gesture.view!, toView: infoView(), duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
        //        UIView.transitionWithView(mySecondView, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: nil, completion: nil)
    }
    
    func handleTap2 (gesture:UIGestureRecognizer) {
        println("drugo")
        //        device.info = false
        UIView.transitionFromView(gesture.view!, toView: infoView(), duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeSliderValue(sender: UISlider){
        // Light
        var tag = sender.tag
        deviceInControlMode = true
        if devices[tag].type == "Dimmer" {
            var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            SendingHandler(byteArray: Functions().setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(sender.value * 100)), runningTime: 0x00), gateway: devices[tag].gateway)
            devices[tag].currentValue = Int(sender.value * 100)
            if sender.value == 1{
                devices[tag].opening = false
            }
            if sender.value == 0{
                devices[tag].opening = true
            }
            
        }
        if devices[tag].type == "curtainsRS485" {
            var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            SendingHandler(byteArray: Functions().setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(sender.value * 100))), gateway: devices[tag].gateway)
            devices[tag].currentValue = Int(sender.value * 100)
            if sender.value == 1{
                devices[tag].opening = false
            }
            if sender.value == 0{
                devices[tag].opening = true
            }
            
        }
        UIView.setAnimationsEnabled(false)
        self.deviceCollectionView.performBatchUpdates({
            var indexPath = NSIndexPath(forItem: tag, inSection: 0)
            self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
            }, completion:  {(completed: Bool) -> Void in
                UIView.setAnimationsEnabled(true)
        })
    }
    func buttonTapped(sender:UIButton){
        var tag = sender.tag
        println(devices[tag].type)
        // Appliance?
        if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
            var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            SendingHandler(byteArray: Functions().setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag].gateway)
        }
    }
    func refreshDeviceList() {
        println(deviceInControlMode.boolValue)
        if !deviceInControlMode {
            updateDeviceList()
            self.deviceCollectionView.reloadData()
        }
    }
    var deviceInControlMode = false
    func deviceDidEndControlMode () {
        deviceInControlMode = false
    }
}
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if devices[indexPath.row].type == "hvac" {
            showClimaSettings(indexPath.row, devices: devices)
        }
        deviceCollectionView.reloadData()
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}
extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func updateDeviceStatus (#indexPathRow: Int) {
        devices[indexPathRow].stateUpdatedAt = NSDate()
        saveChanges()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)), UInt8(Int(devices[indexPathRow].gateway.addressTwo)), UInt8(Int(devices[indexPathRow].address))]
        if devices[indexPathRow].type == "Dimmer" {
            SendingHandler(byteArray: Functions().getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "curtainsRelay" || devices[indexPathRow].type == "appliance" {
            SendingHandler(byteArray: Functions().getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "hvac" {
            SendingHandler(byteArray: Functions().getACStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "sensor" {
            SendingHandler(byteArray: Functions().getSensorState(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "curtainsRS485" {
            SendingHandler(byteArray: Functions().getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            if let indexPaths = collectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
                for indexPath in indexPaths {
                    if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as NSDate? {
                        if let hourValue = NSUserDefaults.standardUserDefaults().valueForKey("hourRefresh") as? Int, let minuteValue = NSUserDefaults.standardUserDefaults().valueForKey("minRefresh") as? Int {
                            var minutes = hourValue * 60 + minuteValue
                            if NSDate().timeIntervalSinceDate(stateUpdatedAt.dateByAddingTimeInterval(NSTimeInterval(NSNumber(integer: minutes)))) >= 0 {
                                updateDeviceStatus (indexPathRow: indexPath.row)
                            }
                        }
                    } else {
                        updateDeviceStatus (indexPathRow: indexPath.row)
                    }
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if devices[indexPath.row].type == "Dimmer" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DeviceCollectionCell
                if cell.gradientLayer == nil {
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.frame = cell.bounds
                    gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                    gradientLayer.locations = [0.0, 1.0]
                    cell.gradientLayer = gradientLayer
                    cell.layer.insertSublayer(gradientLayer, atIndex: 0)
                }
                cell.layer.cornerRadius = 5
                cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
                cell.layer.borderWidth = 1
                cell.typeOfLight.text = devices[indexPath.row].name
                cell.typeOfLight.userInteractionEnabled = true
            var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPress.minimumPressDuration = 0.5
//            longPress.delegate = self
            cell.typeOfLight.addGestureRecognizer(longPress)
//                cell.typeOfLight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                cell.typeOfLight.tag = indexPath.row
            cell.lightSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
            cell.lightSlider.addTarget(self, action: "deviceDidEndControlMode", forControlEvents: .TouchUpInside)
                cell.lightSlider.tag = indexPath.row
                var deviceValue = Double(devices[indexPath.row].currentValue) / 100
                if deviceValue >= 0 && deviceValue < 0.1 {
                    cell.picture.image = UIImage(named: "lightBulb1")
                } else if deviceValue >= 0.1 && deviceValue < 0.2{
                    cell.picture.image = UIImage(named: "lightBulb2")
                    
                } else if deviceValue >= 0.2 && deviceValue < 0.3 {
                    cell.picture.image = UIImage(named: "lightBulb3")
                    
                } else if deviceValue >= 0.3 && deviceValue < 0.4 {
                    cell.picture.image = UIImage(named: "lightBulb4")
                    
                } else if deviceValue >= 0.4 && deviceValue < 0.5 {
                    cell.picture.image = UIImage(named: "lightBulb5")
                    
                } else if deviceValue >= 0.5 && deviceValue < 0.6 {
                    cell.picture.image = UIImage(named: "lightBulb6")
                    
                } else if deviceValue >= 0.6 && deviceValue < 0.7 {
                    cell.picture.image = UIImage(named: "lightBulb7")
                    
                } else if deviceValue >= 0.7 && deviceValue < 0.8 {
                    cell.picture.image = UIImage(named: "lightBulb8")
                    
                } else if deviceValue >= 0.8 && deviceValue < 0.9{
                    cell.picture.image = UIImage(named: "lightBulb9")
                }else{
                    cell.picture.image = UIImage(named: "lightBulb10")
                }
                cell.lightSlider.value = Float(deviceValue)
                var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                var lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                cell.picture.userInteractionEnabled = true
                cell.picture.tag = indexPath.row
                cell.picture.addGestureRecognizer(lpgr)
                cell.picture.addGestureRecognizer(tap)
            return cell
        } else if devices[indexPath.row].type == "curtainsRS485" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("curtainCell", forIndexPath: indexPath) as! CurtainCollectionCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.layer.borderWidth = 1
            cell.curtainSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
            cell.curtainSlider.addTarget(self, action: "deviceDidEndControlMode", forControlEvents: .ValueChanged)
            cell.curtainSlider.tag = indexPath.row
            var deviceValue = Double(devices[indexPath.row].currentValue) / 100
            if deviceValue >= 0 && deviceValue < 0.2{
                cell.curtainImage.image = UIImage(named: "curtain0")
                
            }else if deviceValue >= 0.2 && deviceValue < 0.4{
                cell.curtainImage.image = UIImage(named: "curtain1")
                
            }else if deviceValue >= 0.4 && deviceValue < 0.6 {
                cell.curtainImage.image = UIImage(named: "curtain2")
                
            }else if deviceValue >= 0.6 && deviceValue < 0.8 {
                cell.curtainImage.image = UIImage(named: "curtain3")
                
            }else {
                cell.curtainImage.image = UIImage(named: "curtain4")
            }
            cell.curtainSlider.value = Float(deviceValue)
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            var lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
            lpgr.minimumPressDuration = 0.5
            lpgr.delegate = self
            cell.curtainImage.userInteractionEnabled = true
            cell.curtainImage.tag = 1
            cell.curtainImage.addGestureRecognizer(lpgr)
            cell.curtainImage.addGestureRecognizer(tap)
            //        cell.addSubview(myView[indexPath.row])
            //        cell.addSubview(mySecondView[indexPath.row])
            //            println("Broj: \(indexPath.row)")
            return cell
        } else if devices[indexPath.row].type == "curtainsRelay" || devices[indexPath.row].type == "appliance" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.layer.borderWidth = 1
            cell.name.userInteractionEnabled = true
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            cell.image.tag = indexPath.row
            cell.image.userInteractionEnabled = true
            cell.image.addGestureRecognizer(tap)
//            cell.tag = indexPath.row
//            cell.addGestureRecognizer(tap)
            cell.name.text = devices[indexPath.row].name
            var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPress.minimumPressDuration = 0.5
            cell.name.addGestureRecognizer(longPress)
            if devices[indexPath.row].currentValue == 255 {
                cell.image.image = UIImage(named: "applianceon")
                cell.onOffLabel.text = "ON"
            }
            if devices[indexPath.row].currentValue == 0{
                cell.image.image = UIImage(named: "applianceoff")
                cell.onOffLabel.text = "OFF"
            }
            var tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            cell.onOffLabel.userInteractionEnabled = true
            cell.onOffLabel.addGestureRecognizer(tap1)
            cell.onOffLabel.tag = indexPath.row
            return cell
            
        } else if devices[indexPath.row].type == "hvac" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("climaCell", forIndexPath: indexPath) as! ClimateCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.climateName.userInteractionEnabled = true
            cell.climateName.text = devices[indexPath.row].name
            var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPress.minimumPressDuration = 0.5
            cell.climateName.addGestureRecognizer(longPress)
            cell.temperature.text = "\(devices[indexPath.row].roomTemperature) C"
            
            cell.climateMode.text = devices[indexPath.row].mode
            cell.climateSpeed.text = devices[indexPath.row].speed
            
            var fanSpeed = 0.0
            var speedState = devices[indexPath.row].speedState
            if devices[indexPath.row].currentValue == 255 {
                switch speedState {
                case "Low":
                    cell.fanSpeedImage.image = UIImage(named: "fanlow")
                    fanSpeed = 1
                case "Med" :
                    cell.fanSpeedImage.image = UIImage(named: "fanmedium")
                    fanSpeed = 0.3
                case "High":
                    cell.fanSpeedImage.image = UIImage(named: "fanhigh")
                    fanSpeed = 0.1
                default:
                    cell.fanSpeedImage.image = UIImage(named: "fanoff")
                    fanSpeed = 0.0
                }
                
                let animationImages:[AnyObject] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
                var modeState = devices[indexPath.row].modeState
                switch modeState {
                case "Cool":
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = UIImage(named: "cool")
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                case "Heat":
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = UIImage(named: "heat")
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) C"
                case "Fan":
                    cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                    if fanSpeed == 0 {
                        cell.modeImage.image = UIImage(named: "fanauto")
                        cell.modeImage.stopAnimating()
                    } else {
                        cell.modeImage.animationImages = animationImages
                        cell.modeImage.animationDuration = NSTimeInterval(fanSpeed)
                        cell.modeImage.animationRepeatCount = 0
                        cell.modeImage.startAnimating()
                    }
                default:
                    println("\(devices[indexPath.row].name)")
                    println("\(devices[indexPath.row].mode)")
                    println("\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)")
                    println("\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)")
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = nil
                    var mode = devices[indexPath.row].mode
                    switch mode {
                    case "Cool":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                    case "Heat":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) C"
                    case "Fan":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                    default:
                        cell.temperatureSetPoint.text = "\(modeState) C"
                    }
                }
            } else {
                cell.fanSpeedImage.image = UIImage(named: "fanoff")
                cell.modeImage.stopAnimating()
            }
            if devices[indexPath.row].currentValue == 0 {
                cell.imageOnOff.image = UIImage(named: "poweroff")
                cell.modeImage.image = nil
            } else {
                cell.imageOnOff.image = UIImage(named: "poweron")
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.layer.borderWidth = 1
            return cell
        } else if devices[indexPath.row].type == "sensor" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("multiSensorCell", forIndexPath: indexPath) as! MultiSensorCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.layer.borderWidth = 1
            cell.sensorTitle.userInteractionEnabled = true
            cell.sensorTitle.text = devices[indexPath.row].name
            var longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
            longPress.minimumPressDuration = 0.5
            cell.sensorTitle.addGestureRecognizer(longPress)
            if devices[indexPath.row].numberOfDevices == 10 {
                switch devices[indexPath.row].channel {
                case 1:
                    cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                case 2:
                    cell.sensorImage.image = UIImage(named: "sensor")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 3:
                    cell.sensorImage.image = UIImage(named: "sensor")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 4:
                    cell.sensorImage.image = UIImage(named: "sensor")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)%"
                case 5:
                    cell.sensorImage.image = UIImage(named: "sensor_temperature")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                case 6:
                    cell.sensorImage.image = UIImage(named: "sensor_brightness")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue) LUX"
                case 7:
                    if devices[indexPath.row].currentValue == 1 {
                        cell.sensorImage.image = UIImage(named: "sensor_motion")
                        cell.sensorState.text = "Motion"
                    } else {
                        cell.sensorImage.image = UIImage(named: "sensor_idle")
                        cell.sensorState.text = "Idle"
                    }
                case 8:
                    cell.sensorImage.image = UIImage(named: "sensor_ir_receiver")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 9:
                    if devices[indexPath.row].currentValue == 1 {
                        cell.sensorImage.image = UIImage(named: "tamper_on")
                    } else {
                        cell.sensorImage.image = UIImage(named: "tamper_off")
                    }
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 10:
                    if devices[indexPath.row].currentValue == 1 {
                        cell.sensorImage.image = UIImage(named: "sensor_noise")
                    } else {
                        cell.sensorImage.image = UIImage(named: "sensor_no_noise")
                    }
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                default:
                    cell.sensorState.text = "..."
                }
            }
            if devices[indexPath.row].numberOfDevices == 6 {
                switch devices[indexPath.row].channel {
                case 1:
                    cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                case 2:
                    cell.sensorImage.image = UIImage(named: "sensor")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 3:
                    cell.sensorImage.image = UIImage(named: "sensor")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                case 4:
                    cell.sensorImage.image = UIImage(named: "sensor_cpu_temperature")
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue) C"
                case 5:
                    if devices[indexPath.row].currentValue == 1 {
                        cell.sensorImage.image = UIImage(named: "sensor_motion")
                        cell.sensorState.text = "Motion"
                    } else {
                        cell.sensorImage.image = UIImage(named: "sensor_idle")
                        cell.sensorState.text = "Idle"
                    }
                case 6:
                    if devices[indexPath.row].currentValue == 1 {
                        cell.sensorImage.image = UIImage(named: "tamper_on")
                    } else {
                        cell.sensorImage.image = UIImage(named: "tamper_off")
                    }
                    cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
                default:
                    cell.sensorState.text = "..."
                }
            }
            
            return cell
        }
        else {
            // OVDE NESTO TREBA DA SE ODRADI ALI MI NIJE BAS NAJJASNIJE STA!!?!?!?!?!?!
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("accessCell", forIndexPath: indexPath) as! AccessControllCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.layer.borderWidth = 1
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            cell.accessImage.addGestureRecognizer(tap)
            cell.accessImage.userInteractionEnabled = true
            cell.accessImage.tag = 4
            if devices[indexPath.row].currentValue == 255 {
                cell.accessImage.image = UIImage(named: "dooropen")
            } else {
                cell.accessImage.image = UIImage(named: "doorclosed")
            }
            return cell
        }
    }
}

//Light
class DeviceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var typeOfLight: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    var gradientLayer: CAGradientLayer?
    
}
//Appliance on/off
class ApplianceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOffLabel: UILabel!

    var gradientLayer: CAGradientLayer?
    
}
//curtain
class CurtainCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    var gradientLayer: CAGradientLayer?
    
}
//Door
class AccessControllCell: UICollectionViewCell {
    
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
    var gradientLayer: CAGradientLayer?
    
}
//Clima
class ClimateCell: UICollectionViewCell {

    @IBOutlet weak var imageOnOff: UIImageView!
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    var gradientLayer: CAGradientLayer?
}
//Multisensor 10 in 1 and 6 in 1
class MultiSensorCell: UICollectionViewCell {
    
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    
    var gradientLayer: CAGradientLayer?
}
//extension NSData {
//    public func convertToBytes() -> [UInt8] {
//        let count = self.length / sizeof(UInt8)
//        var bytesArray = [UInt8](count: count, repeatedValue: 0)
//        self.getBytes(&bytesArray, length:count * sizeof(UInt8))
//        return bytesArray
//    }
//}
