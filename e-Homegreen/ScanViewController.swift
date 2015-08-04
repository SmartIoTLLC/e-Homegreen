//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit
import CoreData

class ScanViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var isPresenting:Bool = true
    var gateway:Gateway?
    var devices:[Device] = []
    var loader : ViewControllerUtils = ViewControllerUtils()
    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        transitioningDelegate = self
//    }
    
    @IBOutlet weak var deviceTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        
        rangeFrom.text = "1"
        rangeTo.text = "1"
        rangeFrom.delegate = self
        rangeTo.delegate = self
        refreshDeviceList()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: "PLCdidFindNameForDevice", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceReceivedFromPLC:", name: "PLCdidFindDevice", object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    func refreshDeviceList() {
        updateDeviceList()
        deviceTableView.reloadData()
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }

    @IBAction func backButton(sender: UIStoryboardSegue) {
        self.performSegueWithIdentifier("scanUnwind", sender: self)
    }
    
    @IBAction func findDevice(sender: AnyObject) {
        var number:Int = 1
        if rangeFrom.text != "" && rangeTo.text != "" {
            if let numberOne = rangeFrom.text.toInt(), let numberTwo = rangeTo.text.toInt() {
                if numberTwo >= numberOne {
                    loader.showActivityIndicator(self.view)
                    var dictionary:[Int:Int] = [:]
                    for i in 0...(numberTwo-numberOne) {
                        dictionary[i] = numberOne + i
                    }
                    for i in 0...(numberTwo-numberOne) {
                        var calculation:NSNumber = i
                        var number:NSTimeInterval = NSTimeInterval(calculation.doubleValue)
                        println("   \(number)    ")
                        NSTimer.scheduledTimerWithTimeInterval(number, target: self, selector: "searchIds:", userInfo: dictionary[i]!, repeats: false)
                    }
                    for var i = numberOne; i <= numberTwo; ++i {
                    }
                    NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval((numberTwo-numberOne+1)), target: self, selector: "hideActivitIndicator", userInfo: nil, repeats: false)
                }
            }
        }
    }
    func searchIds(timer:NSTimer) {
        if let deviceNumber = timer.userInfo as? Int {
            var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(deviceNumber)]
            SendingHandler(byteArray: Functions().searchForDevices(address), gateway: gateway!)
        }
    }
    
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
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
                println(deviceIndex)
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
            SendingHandler(byteArray: Functions().getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "curtainsRelay" || devices[index].type == "appliance" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Functions().getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "hvac" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Functions().getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
        if devices[index].type == "sensor" {
            var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
            SendingHandler(byteArray: Functions().getSensorName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
        }
    }
    func getDevicesNames (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            sendCommandForFindingName(index: index)
        }
    }
    @IBAction func deleteAll(sender: AnyObject) {
        for var item = 0; item < devices.count; item++ {
            if devices[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(devices[item])
            }
        }
        saveChanges()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblDesc.text = "\(indexPath.row+1). {GW Adr: \(devices[indexPath.row].gateway.addressOne):\(devices[indexPath.row].gateway.addressTwo):\(devices[indexPath.row].address), Ch:\(devices[indexPath.row].channel)} \(devices[indexPath.row].name)"
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gateway!.device.count
    }
    
    
    
//    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
//        return 0.5
//    }
//    
//    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
//        if isPresenting == true{
//            isPresenting = false
//            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
//            presentedControllerView.center.x += containerView.bounds.size.width
//            //            presentedControllerView.center.y += containerView.bounds.size.height
//            //            presentedControllerView.alpha = 0
//            //            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
//            containerView.addSubview(presentedControllerView)
//            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                presentedControllerView.center.x -= containerView.bounds.size.width
//                //                presentedControllerView.center.y -= containerView.bounds.size.height
//                //                presentedControllerView.alpha = 1
//                //                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }else{
//            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
//            let containerView = transitionContext.containerView()
//            
//            // Animate the presented view off the bottom of the view
//            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
//                presentedControllerView.center.x += containerView.bounds.size.width
//                //                presentedControllerView.center.y += containerView.bounds.size.height
//                //                presentedControllerView.alpha = 0
//                //                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
//                }, completion: {(completed: Bool) -> Void in
//                    transitionContext.completeTransition(completed)
//            })
//        }
//    }
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return self
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if dismissed == self {
//            return self
//        }
//        else {
//            return nil
//        }
//    }




}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblDesc: UILabel!
    
}
