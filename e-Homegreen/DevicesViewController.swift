//
//  DevicesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

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
    var isScrolling:Bool = false
    var shouldUpdate:Bool = false
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var myView:Array<UIView> = []
    var mySecondView:Array<UIView> = []
    var timer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        print(heeeeeeej())
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
        
        //        var utterance = AVSpeechUtterance(string: "Hello world. Hello Vladimir! What about these new things? What about everything?")
        //        var synth = AVSpeechSynthesizer()
        //        synth.speakUtterance(utterance)
        
        
        
    }
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    
    func updateDeviceList () {
        print("ovde je uslo")
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Device")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        let predicateTwo = NSPredicate(format: "isVisible == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne, predicateTwo]
        //        fetchRequest.predicate = predicate
        
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
            let levelPredicate = NSPredicate(format: "parentZoneId == %@", NSNumber(integer: Int(levelSearch)!))
            predicateArray.append(levelPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "zoneId == %@", NSNumber(integer: Int(zoneSearch)!))
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "categoryId == %@", NSNumber(integer: Int(categorySearch)!))
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
            devices = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Device]
//        if let results = fetResults {
//            print("ovde je uslo 2")
//            devices = results
//        } else {
//            print("ovde je uslo 3")
//        }
//        print("ovde je izaslo")
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
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(deviceCollectionView)
            if let index = deviceCollectionView.indexPathForItemAtPoint(location){
                let cell = deviceCollectionView.cellForItemAtIndexPath(index)
                if devices[index.row].type == "Dimmer" {
                    showDimmerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
//                if devices[index.row].type == "sensor" {
//                    showDigitalInputParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
//                }
                if devices[index.row].type == "hvac" {
                    showClimaParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                    showRelayParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y), indexPathRow:tag, devices: devices)
                }
                if devices[index.row].type == "curtainsRS485" {
                    showCellParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - deviceCollectionView.contentOffset.y))
                }
                
            }
        }
    }
    var longTouchOldValue = 0
    func longTouch(gestureRecognizer: UILongPressGestureRecognizer) {
        // Light
        let tag = gestureRecognizer.view!.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        
        if devices[tag].type == "Dimmer" {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                longTouchOldValue = Int(devices[tag].currentValue)
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                longTouchOldValue = 0
                //                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue)), runningTime: 0x00), gateway: devices[tag].gateway)
//                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue)), delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue)), delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway, device: devices[tag], oldValue: longTouchOldValue)
                    })
                })
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag].opening == true {
                    devices[tag].opening = false
                }else {
                    devices[tag].opening = true
                }
                return
            }
        }
        
        if devices[tag].type == "curtainsRS485" {
            
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                longTouchOldValue = Int(devices[tag].currentValue)
                deviceInControlMode = true
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateCurtain:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                longTouchOldValue = 0
//                SendingHandler.sendCommand(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue))), gateway: devices[tag].gateway)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    dispatch_async(dispatch_get_main_queue(), {
                        RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue))), gateway: devices[tag].gateway, device: devices[tag], oldValue: longTouchOldValue)
                    })
                })
                timer.invalidate()
                deviceInControlMode = false
                if devices[tag].opening == true {
                    devices[tag].opening = false
                }else {
                    devices[tag].opening = true
                }
                return
            }
        }
    }
    
    func oneTap(gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        // Light
        if devices[tag].type == "Dimmer" {
            var setDeviceValue:UInt8 = 0
            if devices[tag].currentValue == 100 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: setDeviceValue, runningTime: 0x00), gateway: devices[tag].gateway)
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: setDeviceValue, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: setDeviceValue, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway, device: devices[tag], oldValue: deviceCurrentValue)
                })
            })
        }
        // Appliance?
        if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag!].gateway)
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
            let deviceCurrentValue = Int(devices[tag].currentValue)
            if devices[tag].currentValue == 255 {
                devices[tag].currentValue = 0
            } else {
                devices[tag].currentValue = 255
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway, device: devices[tag], oldValue: deviceCurrentValue)
                })
            })
        }
        // Curtain?
        if devices[tag].type == "curtainsRS485" {
            var setDeviceValue:UInt8 = 0
            if devices[tag].currentValue == 100 {
                setDeviceValue = UInt8(0)
            } else {
                setDeviceValue = UInt8(100)
            }
            let deviceCurrentValue = Int(devices[tag].currentValue)
            devices[tag].currentValue = Int(setDeviceValue)
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
//            SendingHandler.sendCommand(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: setDeviceValue), gateway: devices[tag].gateway)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: setDeviceValue), gateway: devices[tag].gateway, device: devices[tag], oldValue: deviceCurrentValue)
                })
            })
            
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
            devices[tag].currentValue = Int(deviceValue*100)
            UIView.setAnimationsEnabled(false)
            self.deviceCollectionView.performBatchUpdates({
                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
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
            devices[tag].currentValue = Int(deviceValue*100)
            UIView.setAnimationsEnabled(false)
            self.deviceCollectionView.performBatchUpdates({
                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
                self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
                }, completion:  {(completed: Bool) -> Void in
                    UIView.setAnimationsEnabled(true)
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("override func viewWillAppear(animated: Bool) {print(")
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
        let locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(locationLabel)
        
        let levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(levelLabel)
        
        let zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
        zoneLabel.text = "Zone"
        zoneLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(zoneLabel)
        
        let categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
        categoryLabel.text = "Category"
        categoryLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(categoryLabel)
        
        let locationButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
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
        
        let levelButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
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
        
        let zoneButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
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
        
        let categoryButton:UIButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
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
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    func saveText (text : String, id:Int) {
        let tag = senderButton!.tag
            switch tag {
            case 1:
                locationSearch = text
            case 2:
                if id == -1 {
                    levelSearch = "All"
                } else {
                    levelSearch = "\(id)"
                }
            case 3:
                if id == -1 {
                    zoneSearch = "All"
                } else {
                    zoneSearch = "\(id)"
                }
            case 4:
                if id == -1 {
                    categorySearch = "All"
                } else {
                    categorySearch = "\(id)"
                }
            default:
                print("")
            }
            updateDeviceList()
            deviceCollectionView.reloadData()
            senderButton?.setTitle(text, forState: .Normal)
        
    }
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func handleTap (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].type == "Dimmer" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "sensor" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "hvac" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            } else if devices[index.row].type == "curtainsRS485" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
                UIView.transitionFromView(cell.backView, toView: cell.infoView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews] , completion: nil)
            }
            
            devices[index.row].info = true
        }
    }
    
    func handleTap2 (gesture:UIGestureRecognizer) {
        let location = gesture.locationInView(deviceCollectionView)
        if let index = deviceCollectionView.indexPathForItemAtPoint(location){
            if devices[index.row].type == "Dimmer" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! DeviceCollectionCell
                
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            } else if devices[index.row].type == "curtainsRelay" || devices[index.row].type == "appliance" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ApplianceCollectionCell
                
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }
            else if devices[index.row].type == "sensor" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! MultiSensorCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }else if devices[index.row].type == "hvac" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! ClimateCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }else if devices[index.row].type == "curtainsRS485" {
                let cell = deviceCollectionView.cellForItemAtIndexPath(index) as! CurtainCollectionCell
                UIView.transitionFromView(cell.infoView, toView: cell.backView, duration: 0.5, options: [UIViewAnimationOptions.TransitionFlipFromBottom, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
            }
            devices[index.row].info = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func changeSliderValueStarted (sender: UISlider) {
        let tag = sender.tag
        deviceInControlMode = true
        changeSliderValueOldValue = Int(devices[tag].currentValue)
    }
    func changeSliderValueEnded (sender:UISlider) {
        print("hmmm")
        let tag = sender.tag
        let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        //   Dimmer
        if devices[tag].type == "Dimmer" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    RepeatSendingHandler(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue)), delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway, device: devices[tag], oldValue: changeSliderValueOldValue)
                })
            })
            print("poslato je \(changeSliderValueOldValue)")
        }
        //  Curtain
        if devices[tag].type == "curtainsRS485" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                dispatch_async(dispatch_get_main_queue(), {
                    RepeatSendingHandler(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue))), gateway: devices[tag].gateway, device: devices[tag], oldValue: changeSliderValueOldValue)
                })
            })
            print("poslato je \(changeSliderValueOldValue)")
        }
        changeSliderValueOldValue = 0
        deviceInControlMode = false
    }
    
    var changeSliderValueOldValue = 0
    
    func changeSliderValue(sender: UISlider){
        let tag = sender.tag
        devices[tag].currentValue = Int(sender.value * 100)
        if sender.value == 1{
            devices[tag].opening = false
        }
        if sender.value == 0{
            devices[tag].opening = true
        }
        
        UIView.setAnimationsEnabled(false)
        self.deviceCollectionView.performBatchUpdates({
            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
            self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
            }, completion:  {(completed: Bool) -> Void in
                UIView.setAnimationsEnabled(true)
        })
    }
    func buttonTapped(sender:UIButton){
        let tag = sender.tag
        print(devices[tag].type)
        // Appliance?
        if devices[tag].type == "curtainsRelay" || devices[tag].type == "appliance" {
            let address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
            //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), gateway: devices[tag].gateway)
            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: 0xF1, delay: Int(devices[tag].delay), runningTime: Int(devices[tag].runtime), skipLevel: UInt8(Int(devices[tag].skipState))), gateway: devices[tag].gateway)
        }
    }
    func refreshDeviceList() {
        print(deviceInControlMode.boolValue)
        if !deviceInControlMode {
            if isScrolling {
                shouldUpdate = true
            } else {
                updateDeviceList()
                self.deviceCollectionView.reloadData()
            }
        }
    }
    var deviceInControlMode = false
    func deviceDidEndControlMode (sender: UISlider){
        //        var tag = sender.tag
        //        var address = [UInt8(Int(devices[tag].gateway.addressOne)),UInt8(Int(devices[tag].gateway.addressTwo)),UInt8(Int(devices[tag].address))]
        //        deviceInControlMode = false
        //        println("hehehehe")
        //        if devices[tag].type == "Dimmer" {
        //            println(devices[tag].currentValue)
        //            SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue)), runningTime: 0x00), gateway: devices[tag].gateway)
        //        }
        //        //  Curtain
        //        if devices[tag].type == "curtainsRS485" {
        //            SendingHandler.sendCommand(byteArray: Function.setCurtainStatus(address, channel:  UInt8(Int(devices[tag].channel)), value: UInt8(Int(devices[tag].currentValue))), gateway: devices[tag].gateway)
        //        }
    }
}
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if devices[indexPath.row].isEnabled.boolValue {
            if devices[indexPath.row].type == "hvac" {
                showClimaSettings(indexPath.row, devices: devices)
            }
            deviceCollectionView.reloadData()
        }
        
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
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func updateDeviceStatus (indexPathRow indexPathRow: Int) {
        devices[indexPathRow].stateUpdatedAt = NSDate()
        saveChanges()
        let address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)), UInt8(Int(devices[indexPathRow].gateway.addressTwo)), UInt8(Int(devices[indexPathRow].address))]
        if devices[indexPathRow].type == "Dimmer" {
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "curtainsRelay" || devices[indexPathRow].type == "appliance" {
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "hvac" {
            SendingHandler.sendCommand(byteArray: Function.getACStatus(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "sensor" {
            SendingHandler.sendCommand(byteArray: Function.getSensorState(address), gateway: devices[indexPathRow].gateway)
        }
        if devices[indexPathRow].type == "curtainsRS485" {
            SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: devices[indexPathRow].gateway)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            if let indexPaths = collectionView.indexPathsForVisibleItems() as? [NSIndexPath] {
                for indexPath in indexPaths {
                    if let stateUpdatedAt = devices[indexPath.row].stateUpdatedAt as NSDate? {
                        if let hourValue = NSUserDefaults.standardUserDefaults().valueForKey("hourRefresh") as? Int, let minuteValue = NSUserDefaults.standardUserDefaults().valueForKey("minRefresh") as? Int {
                            let minutes = (hourValue * 60 + minuteValue) * 60
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
        if shouldUpdate {
            updateDeviceList()
            self.deviceCollectionView.reloadData()
            shouldUpdate = false
        }
        isScrolling = false
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        isScrolling = true
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
                cell.backView.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.backView.layer.cornerRadius = 5
            cell.backView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.backView.layer.borderWidth = 1
            cell.typeOfLight.text = devices[indexPath.row].name
            cell.typeOfLight.tag = indexPath.row
            cell.lightSlider.continuous = true
            cell.lightSlider.tag = indexPath.row
            let deviceValue = Double(devices[indexPath.row].currentValue) / 100
            if deviceValue >= 0 && deviceValue < 0.1 {
                cell.picture.image = UIImage(named: "lightBulb1")
            } else if deviceValue >= 0.1 && deviceValue < 0.2 {
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
            } else if deviceValue >= 0.8 && deviceValue < 0.9 {
                cell.picture.image = UIImage(named: "lightBulb9")
            } else {
                cell.picture.image = UIImage(named: "lightBulb10")
            }
            cell.lightSlider.value = Float(deviceValue)
            cell.picture.userInteractionEnabled = true
            cell.picture.tag = indexPath.row

            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            cell.labelRunningTime.text = devices[indexPath.row].runningTime
            
            cell.infoView.layer.cornerRadius = 5
            cell.infoView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.infoView.layer.borderWidth = 1
            
            if cell.infoGradientLayer == nil {
                let gradientLayerInfo = CAGradientLayer()
                gradientLayerInfo.frame = cell.bounds
                gradientLayerInfo.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayerInfo.locations = [0.0, 1.0]
                cell.infoGradientLayer = gradientLayerInfo
                cell.infoView.layer.insertSublayer(gradientLayerInfo, atIndex: 0)
            }
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                print(devices[indexPath.row].isEnabled.boolValue)
                cell.typeOfLight.userInteractionEnabled = true
                
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.typeOfLight.addGestureRecognizer(longPress)
                cell.typeOfLight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                
                cell.lightSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
                cell.lightSlider.addTarget(self, action: "changeSliderValueEnded:", forControlEvents:  UIControlEvents.TouchUpInside)
                cell.lightSlider.addTarget(self, action: "changeSliderValueStarted:", forControlEvents: UIControlEvents.TouchDown)
                
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                cell.picture.addGestureRecognizer(lpgr)
                cell.picture.addGestureRecognizer(tap)
                
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            }
            return cell
        } else if devices[indexPath.row].type == "curtainsRS485" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("curtainCell", forIndexPath: indexPath) as! CurtainCollectionCell
            
            cell.curtainImage.tag = indexPath.row
            cell.curtainSlider.tag = indexPath.row
            let deviceValue = Double(devices[indexPath.row].currentValue) / 100
            if deviceValue >= 0 && deviceValue < 0.2 {
                cell.curtainImage.image = UIImage(named: "curtain0")
                
            } else if deviceValue >= 0.2 && deviceValue < 0.4 {
                cell.curtainImage.image = UIImage(named: "curtain1")
            } else if deviceValue >= 0.4 && deviceValue < 0.6 {
                cell.curtainImage.image = UIImage(named: "curtain2")
            } else if deviceValue >= 0.6 && deviceValue < 0.8 {
                cell.curtainImage.image = UIImage(named: "curtain3")
            } else {
                cell.curtainImage.image = UIImage(named: "curtain4")
            }
            cell.curtainName.userInteractionEnabled = true
            cell.curtainSlider.value = Float(deviceValue)
            cell.curtainImage.userInteractionEnabled = true
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.curtainSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
                cell.curtainSlider.addTarget(self, action: "changeSliderValueStarted:", forControlEvents: UIControlEvents.TouchDown)
                cell.curtainSlider.addTarget(self, action: "changeSliderValueEnded:", forControlEvents:  UIControlEvents.TouchUpInside)
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                let lpgr:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longTouch:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delegate = self
                cell.curtainImage.addGestureRecognizer(lpgr)
                cell.curtainImage.addGestureRecognizer(tap)
                cell.curtainName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.curtainName.addGestureRecognizer(longPress)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            }
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            
            return cell
        } else if devices[indexPath.row].type == "curtainsRelay" || devices[indexPath.row].type == "appliance" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.backView.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.backView.layer.cornerRadius = 5
            cell.backView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.backView.layer.borderWidth = 1
            cell.name.text = devices[indexPath.row].name
            cell.name.tag = indexPath.row
            if devices[indexPath.row].currentValue == 255 {
                cell.image.image = UIImage(named: "applianceon")
                cell.onOffLabel.text = "ON"
            }
            if devices[indexPath.row].currentValue == 0{
                cell.image.image = UIImage(named: "applianceoff")
                cell.onOffLabel.text = "OFF"
            }
            cell.onOffLabel.tag = indexPath.row
            
            cell.infoView.layer.cornerRadius = 5
            cell.infoView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.infoView.layer.borderWidth = 1
            
            if cell.infoGradientLayer == nil {
                let gradientLayerInfo = CAGradientLayer()
                gradientLayerInfo.frame = cell.bounds
                gradientLayerInfo.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayerInfo.locations = [0.0, 1.0]
                cell.infoGradientLayer = gradientLayerInfo
                cell.infoView.layer.insertSublayer(gradientLayerInfo, atIndex: 0)
            }
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }

            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"

            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.name.userInteractionEnabled = true
                let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                cell.image.tag = indexPath.row
                cell.image.userInteractionEnabled = true
                cell.image.addGestureRecognizer(tap)
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.name.addGestureRecognizer(longPress)
                cell.name.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
                cell.onOffLabel.userInteractionEnabled = true
                cell.onOffLabel.addGestureRecognizer(tap1)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            }
            
            return cell
            
        } else if devices[indexPath.row].type == "hvac" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("climaCell", forIndexPath: indexPath) as! ClimateCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.backView.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.climateName.text = devices[indexPath.row].name
            cell.climateName.tag = indexPath.row
            cell.temperature.text = "\(devices[indexPath.row].roomTemperature) C"
            
            cell.climateMode.text = devices[indexPath.row].mode
            cell.climateSpeed.text = devices[indexPath.row].speed
            
            var fanSpeed = 0.0
            let speedState = devices[indexPath.row].speedState
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
                
                let animationImages:[UIImage] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
                let modeState = devices[indexPath.row].modeState
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
                    print("\(devices[indexPath.row].name)")
                    print("\(devices[indexPath.row].mode)")
                    print("\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)\(modeState)")
                    print("\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)\(speedState)")
                    cell.modeImage.stopAnimating()
                    cell.modeImage.image = nil
                    let mode = devices[indexPath.row].mode
                    switch mode {
                    case "Cool":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                    case "Heat":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].heatTemperature) C"
                    case "Fan":
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
                    default:
                        //  Hoce i tu da zezne
                        cell.temperatureSetPoint.text = "\(devices[indexPath.row].coolTemperature) C"
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
            cell.backView.layer.cornerRadius = 5
            cell.backView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.backView.layer.borderWidth = 1
            
            cell.infoView.layer.cornerRadius = 5
            cell.infoView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.infoView.layer.borderWidth = 1

            cell.labelPowrUsege.text = "\(Float(devices[indexPath.row].current) * Float(devices[indexPath.row].voltage) * 0.01)" + " W"
            
            if cell.infoGradientLayer == nil {
                let gradientLayerInfo = CAGradientLayer()
                gradientLayerInfo.frame = cell.bounds
                gradientLayerInfo.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayerInfo.locations = [0.0, 1.0]
                cell.infoGradientLayer = gradientLayerInfo
                cell.infoView.layer.insertSublayer(gradientLayerInfo, atIndex: 0)
            }
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                cell.climateName.userInteractionEnabled = true
                cell.climateName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.climateName.addGestureRecognizer(longPress)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            }
            return cell
            
        } else if devices[indexPath.row].type == "sensor" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("multiSensorCell", forIndexPath: indexPath) as! MultiSensorCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.backView.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.backView.layer.cornerRadius = 5
            cell.backView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.backView.layer.borderWidth = 1
            cell.sensorTitle.userInteractionEnabled = true
            cell.sensorTitle.text = devices[indexPath.row].name
            cell.sensorTitle.tag = indexPath.row
            print(devices[indexPath.row])
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
            
            cell.infoView.layer.cornerRadius = 5
            cell.infoView.layer.borderColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 1).CGColor
            cell.infoView.layer.borderWidth = 1
            
            cell.labelID.text = "\(indexPath.row + 1)"
            cell.labelName.text = "\(devices[indexPath.row].name)"
            cell.labelCategory.text = "\(devices[indexPath.row].categoryId)"
            cell.labelLevel.text = "\(devices[indexPath.row].parentZoneId)"
            cell.labelZone.text = "\(devices[indexPath.row].zoneId)"
            
            if cell.infoGradientLayer == nil {
//                cell.sensorTitle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                let gradientLayerInfo = CAGradientLayer()
                gradientLayerInfo.frame = cell.bounds
                gradientLayerInfo.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
                gradientLayerInfo.locations = [0.0, 1.0]
                cell.infoGradientLayer = gradientLayerInfo
                cell.infoView.layer.insertSublayer(gradientLayerInfo, atIndex: 0)
            }
            
            
            if devices[indexPath.row].info {
                cell.infoView.hidden = false
                cell.backView.hidden = true
            }else {
                cell.infoView.hidden = true
                cell.backView.hidden = false
            }
            
            // If device is enabled add all interactions
            if devices[indexPath.row].isEnabled.boolValue {
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cellParametarLongPress:")
                longPress.minimumPressDuration = 0.5
                cell.sensorTitle.addGestureRecognizer(longPress)
                cell.infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("accessCell", forIndexPath: indexPath) as! AccessControllCell
            return cell
        }
    }
}

//Light
class DeviceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var typeOfLight: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    var infoGradientLayer: CAGradientLayer?
    
    
}
//Appliance on/off
class ApplianceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOffLabel: UILabel!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    
    var infoGradientLayer: CAGradientLayer?
    
    
}
//curtain
class CurtainCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
    
    
    
}
//Door
class AccessControllCell: UICollectionViewCell {
    
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
    var gradientLayer: CAGradientLayer?
    
}
//Clima
class ClimateCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageOnOff: UIImageView!
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    
    var infoGradientLayer: CAGradientLayer?
    
    
}
//Multisensor 10 in 1 and 6 in 1
class MultiSensorCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelZone: UILabel!
    var infoGradientLayer: CAGradientLayer?
    
    
}

