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
    let collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var myView:Array<UIView> = []
    var mySecondView:Array<UIView> = []
    
    var timer:NSTimer = NSTimer()
    var receivingSocket:InSocket!
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD
        println(UIDevice.currentDevice().SSID)
        receivingSocket = InSocket(ip: "192.168.0.7", port: 5001)
=======
//        outSocketTwo = OutSocket(ip: "192.168.0.23", port: 5001)
        receivingSocket = InSocket(ip: "e-home.dyndns.org", port: 5001)
//        let timerOS = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("joj"), userInfo: nil, repeats: true)
        commonConstruct()
//        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
//        socket.bindToPort(5001, error: &error)
//        //                socket.enableBroadcast(true, error: &error)
//        //        socket.joinMulticastGroup(ip, error: &error)
//        socket.beginReceiving(&error)
//        //        socket.enableBroadcast(true, error: &error)
>>>>>>> origin/master
        
        commonConstruct()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
        updateDeviceList()
    }
    var inSocket:InSocket!
    var outSocket:OutSocket!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    func updateDeviceList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptor1 = NSSortDescriptor(key: "type", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
        }
    }
    
    func longTouch(gestureRecognizer: UILongPressGestureRecognizer){
        // Light
        var tag = gestureRecognizer.view?.tag
        if devices[tag!].type == "Dimmer" {
            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update:"), userInfo: tag, repeats: true)
            }
            if gestureRecognizer.state == UIGestureRecognizerState.Ended {
                timer.invalidate()

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
            SendingHandler(byteArray: Functions().setLightRelayStatus(UInt8(Int(devices[tag!].address)), channel: UInt8(Int(devices[tag!].channel)), value: setDeviceValue, runningTime: 0x00), ip: devices[tag!].gateway.localIp, port: Int(devices[tag!].gateway.localPort))
//            outSocket.sendByte()
        }
        // Appliance?
        if devices[tag!].type == "curtainsRelay" {
            SendingHandler(byteArray: Functions().setLightRelayStatus(UInt8(Int(devices[tag!].address)), channel: UInt8(Int(devices[tag!].channel)), value: 0xF1, runningTime: 0x00), ip: devices[tag!].gateway.localIp, port: Int(devices[tag!].gateway.localPort))
//            outSocket.sendByte(Functions().setLightRelayStatus(UInt8(Int(devices[tag!].address)), channel: UInt8(Int(devices[tag!].channel)), value: 0xF1, runningTime: 0x00))
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
            println(deviceValue*100)
            SendingHandler(byteArray: Functions().setLightRelayStatus(UInt8(Int(devices[tag].address)), channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(deviceValue*100)), runningTime: 0x00), ip: devices[tag].gateway.localIp, port: Int(devices[tag].gateway.localPort))
//            self.outSocket.sendByte(Functions().setLightRelayStatus(UInt8(Int(self.devices[tag].address)), channel: UInt8(Int(self.devices[tag].channel)), value: UInt8(Int(deviceValue*100)), runningTime: 0x00))
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
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
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
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
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
        locationButton.layer.borderWidth = 0.5
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
        levelButton.layer.borderWidth = 0.5
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
        zoneButton.layer.borderWidth = 0.5
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
        categoryButton.layer.borderWidth = 0.5
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
        if devices[tag].type == "Dimmer" {
            SendingHandler(byteArray: Functions().setLightRelayStatus(UInt8(Int(devices[tag].address)), channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(sender.value * 100)), runningTime: 0x00), ip: devices[tag].gateway.localIp, port: Int(devices[tag].gateway.localPort))
//            outSocket.sendByte(Functions().setLightRelayStatus(UInt8(Int(devices[tag].address)), channel: UInt8(Int(devices[tag].channel)), value: UInt8(Int(sender.value * 100)), runningTime: 0x00))
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
        if devices[tag].type == "curtainsRelay" {
            SendingHandler(byteArray: Functions().setLightRelayStatus(UInt8(Int(devices[tag].address)), channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00), ip: devices[tag].gateway.localIp, port: Int(devices[tag].gateway.localPort))
//            outSocket.sendByte(Functions().setLightRelayStatus(UInt8(Int(devices[tag].address)), channel: UInt8(Int(devices[tag].channel)), value: 0xF1, runningTime: 0x00))
        }
    }
    func refreshDeviceList() {
        updateDeviceList()
        self.deviceCollectionView.reloadData()
    }
}
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if devices[indexPath.row].type == "hvac" {
            showClimaSettings(indexPath.row, devices: devices)
        }
//        deviceCollectionView.reloadData()
        
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
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if devices[indexPath.row].type == "Dimmer" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DeviceCollectionCell
                if cell.gradientLayer == nil {
                    let gradientLayer = CAGradientLayer()
                    gradientLayer.frame = cell.bounds
                    gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                    gradientLayer.locations = [0.0, 1.0]
                    cell.gradientLayer = gradientLayer
                    cell.layer.insertSublayer(gradientLayer, atIndex: 0)
                }
                cell.layer.cornerRadius = 5
                cell.layer.borderColor = UIColor.grayColor().CGColor
                cell.layer.borderWidth = 0.5
                cell.typeOfLight.text = devices[indexPath.row].name
                cell.typeOfLight.userInteractionEnabled = true
//                cell.typeOfLight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
                cell.typeOfLight.tag = indexPath.row
                cell.lightSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
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
        } else if devices[indexPath.row].type == "curtainsRS485 ILI TAKO NEKI VRAG" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("curtainCell", forIndexPath: indexPath) as! CurtainCollectionCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
//            cell.curtainName.text = device1.text
//            cell.curtainImage.image = device1.image
            cell.curtainSlider.addTarget(self, action: "changeSliderValue1:", forControlEvents: .ValueChanged)
            cell.curtainSlider.tag = indexPath.row
//            if device1.value >= 0 && device1.value < 0.2{
//                cell.curtainImage.image = UIImage(named: "curtain0")
//                
//            }else if device1.value >= 0.2 && device1.value < 0.4{
//                cell.curtainImage.image = UIImage(named: "curtain1")
//                
//            }else if device1.value >= 0.4 && device1.value < 0.6 {
//                cell.curtainImage.image = UIImage(named: "curtain2")
//                
//            }else if device1.value >= 0.6 && device1.value < 0.8 {
//                cell.curtainImage.image = UIImage(named: "curtain3")
//                
//            }else {
//                cell.curtainImage.image = UIImage(named: "curtain4")
//            }
//            cell.curtainSlider.value = device1.value
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
        } else if devices[indexPath.row].type == "curtainsRelay" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            cell.image.tag = indexPath.row
            cell.image.userInteractionEnabled = true
            cell.image.addGestureRecognizer(tap)
//            cell.name.text = device2.text
//            if device2.open == true{
//                cell.image.image = UIImage(named: "applianceon")
//                cell.button.setTitle("ON", forState: .Normal)
//            }else{
//                cell.image.image = UIImage(named: "applianceoff")
//                cell.button.setTitle("OFF", forState: .Normal)
//            }
            cell.button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button.tag = indexPath.row
            //            cell.addSubview(myView[indexPath.row])
            //            cell.addSubview(mySecondView[indexPath.row])
            //        println("Broj: \(indexPath.row)")
            return cell
            
        } else if devices[indexPath.row].type == "hvac" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("climaCell", forIndexPath: indexPath) as! ClimateCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            let animationImages:[AnyObject] = [UIImage(named: "h1")!, UIImage(named: "h2")!, UIImage(named: "h3")!, UIImage(named: "h4")!, UIImage(named: "h5")!, UIImage(named: "h6")!, UIImage(named: "h7")!, UIImage(named: "h8")!]
            cell.modeImage.animationImages = animationImages
            cell.modeImage.animationDuration = 1
            cell.modeImage.animationRepeatCount = 0
            cell.modeImage.startAnimating()
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            return cell
        } else if devices[indexPath.row].type == "sensor" {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("multiSensorCell", forIndexPath: indexPath) as! MultiSensorCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            
            cell.sensorTitle.text = devices[indexPath.row].name
            cell.sensorState.text = "\(devices[indexPath.row].currentValue)"
            
            return cell
            
        }
            
        else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("accessCell", forIndexPath: indexPath) as! AccessControllCell
            if cell.gradientLayer == nil {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = cell.bounds
                gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
                gradientLayer.locations = [0.0, 1.0]
                cell.gradientLayer = gradientLayer
                cell.layer.insertSublayer(gradientLayer, atIndex: 0)
            }
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
            cell.accessImage.addGestureRecognizer(tap)
            cell.accessImage.userInteractionEnabled = true
            cell.accessImage.tag = 4
//            cell.accessLabel.text = device3.text
//            if device3.open == false {
//                cell.accessImage.image = UIImage(named: "doorclosed")
//            }else{
//                cell.accessImage.image = UIImage(named: "dooropen")
//            }
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
    @IBOutlet weak var button: UIButton!
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
    
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var coolingSetPoint: UILabel!
    @IBOutlet weak var heatingSetPoint: UILabel!
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
