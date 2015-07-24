//
//  DatabaseViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData


class DatabaseViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var databaseTable: UITableView!
    var inSocket:InSocket!
    var outSocket:OutSocket!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var gatewaysNames:[String] = []
    var error:NSError? = nil
    var backgroundImageView = UIImageView()
    
    
    @IBOutlet weak var idRangeFrom: UITextField!
    @IBOutlet weak var idRangeTo: UITextField!
    var receivingSocket:InSocket?
    
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var btnChooseGateway: UIButton!
    var isPresenting:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.commonConstruct()
        //        var validUrl = NSURL().URLW
        //        returnIpAddress("heeej")
        //        returnIpAddress("e-Home.dyndns.org")
        //        returnIpAddress("2.50.32.208")
        //        returnIpAddress("192.168.0.7")
        //        returnIpAddress("khalifaaljaziri.dyndns.org")
        //        returnIpAddress("31.215.238.180")
        btnChooseGateway.setTitle("Choose your connection", forState: UIControlState.Normal)
        //        returnIpAddress("heeej")
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList:", name: "refreshDeviceListNotification", object: nil)
        
        //        updateDeviceList()
        idRangeFrom.delegate = self
        idRangeTo.delegate = self
        fetchAllGateways()
        idRangeFrom.text = "\(1)"
        idRangeTo.text = "\(1)"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnDeleteAll(sender: AnyObject) {
        if choosedGatewayIndex != -1 {
            for item in devices {
                if item.gateway.objectID == gateways[choosedGatewayIndex].objectID {
                    appDel.managedObjectContext!.deleteObject(item)
                }
            }
            saveChanges()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
        }
    }
    @IBAction func btnFindNames(sender: AnyObject) {
        if choosedGatewayIndex != -1 {
            var index:Int
            for index in 0...devices.count-1 {
                var number:NSTimeInterval = NSTimeInterval(index)
                NSTimer.scheduledTimerWithTimeInterval(number*0.1, target: self, selector: "getDevicesNames:", userInfo: index, repeats: false)
            }
        }
    }
    func getDevicesNames (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            if devices[index].type == "Dimmer" {
                var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
                SendingHandler(byteArray: Functions().getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            }
            if devices[index].type == "curtainsRelay" {
                var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
                SendingHandler(byteArray: Functions().getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            }
            
            if devices[index].type == "hvac" {
                var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
                SendingHandler(byteArray: Functions().getACName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            }
            if devices[index].type == "sensor" {
                var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
                SendingHandler(byteArray: Functions().getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            }
        }
    }
    var popoverVC:PopOverViewController = PopOverViewController()
    var choosedGatewayIndex:Int = -1
    func clickedOnGatewayWithIndex(index: Int) {
        btnChooseGateway.setTitle("\(gateways[index].name)", forState: UIControlState.Normal)
        choosedGatewayIndex = index
        refreshDeviceListOnDatabasVC()
        // hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm
    }
    @IBAction func btnChooseGateway(sender: UIButton) {
        gatewaysNames = []
        for item in gateways {
            gatewaysNames.append("\(item.name)")
        }
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.gatewayList = gatewaysNames
        popoverVC.indexTab = 4
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.whiteColor()
            self.presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func returnIpAddress (url:String) -> String {
        let host = CFHostCreateWithName(nil,url).takeRetainedValue();
        CFHostStartInfoResolution(host, .Addresses, nil);
        var success: Boolean = 0;
        if let test = CFHostGetAddressing(host, &success) {
            let addresses = test.takeUnretainedValue() as NSArray
            if (addresses.count > 0){
                let theAddress = addresses[0] as! NSData;
                var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                    &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        if let numAddress = String.fromCString(hostname) {
                            println(numAddress)
                            return numAddress
                        }
                }
            }
        }
        return ""
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
        let predicate = NSPredicate(format: "gateway == %@", gateways[choosedGatewayIndex].objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
    }
    func refreshDeviceListOnDatabasVC () {
        if gateways != [] {
            updateDeviceList()
            databaseTable.reloadData()
        }
    }
    func refreshDeviceList (notification:NSNotification) {
        if gateways != [] {
            updateDeviceList()
            databaseTable.reloadData()
        }
    }
    func fetchAllGateways () {
        var fetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicate = NSPredicate(format: "turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        let sortDescriptor1 = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Gateway]
        if let results = fetResults {
            gateways = results
        } else {
            println("Nije htela...")
        }
    }
    func commonConstruct() {
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 64, Common().screenWidth , Common().screenHeight-64)
        self.view.insertSubview(backgroundImageView, atIndex: 0)
    }
    var loader : ViewControllerUtils = ViewControllerUtils()
    var quitLoader:Int = 0
    @IBAction func findDevices(sender: AnyObject) {
        if choosedGatewayIndex != -1 {
            var number:Int = 1
            if idRangeFrom.text != "" && idRangeFrom.text != "" {
                if let numberOne = idRangeFrom.text.toInt()! as? Int, let numberTwo = idRangeTo.text.toInt()! as? Int {
                    loader.showActivityIndicator(self.view)
                    for var i = numberOne; i <= numberTwo; ++i {
                        var number:NSTimeInterval = NSTimeInterval((numberOne-numberTwo+i))
                        NSTimer.scheduledTimerWithTimeInterval(number, target: self, selector: "searchIds:", userInfo: i, repeats: false)
                    }
                    NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval((numberTwo-numberOne+1)), target: self, selector: "hideActivitIndicator", userInfo: nil, repeats: false)
                }
            }
        }
    }
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
    var timerSensorNumber = 0
    //    func getSensorName () {
    //        outSocket.sendByte(Functions().getSensorName(0x05, channel: UInt8(timerSensorNumber)))
    //        timerSensorNumber = timerSensorNumber + 1
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func searchIds(timer:NSTimer) {
        if let deviceNumber = timer.userInfo as? Int {
            var address = [UInt8(Int(gateways[choosedGatewayIndex].addressOne)), UInt8(Int(gateways[choosedGatewayIndex].addressTwo)), UInt8(deviceNumber)]
            SendingHandler(byteArray: Functions().searchForDevices(address), gateway: gateways[choosedGatewayIndex])
        }
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView.bounds.size.width
            //            presentedControllerView.center.y += containerView.bounds.size.height
            //            presentedControllerView.alpha = 0
            //            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView.bounds.size.width
                //                presentedControllerView.center.y -= containerView.bounds.size.height
                //                presentedControllerView.alpha = 1
                //                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView.bounds.size.width
                //                presentedControllerView.center.y += containerView.bounds.size.height
                //                presentedControllerView.alpha = 0
                //                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}
extension DatabaseViewController: UITableViewDataSource {
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 44
    //    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("databaseCell") as? DatabaseTableViewCell {
            cell.foundItem.text = "{GW Adr: \(devices[indexPath.row].gateway.addressOne):\(devices[indexPath.row].gateway.addressTwo):\(devices[indexPath.row].address), Ch:\(devices[indexPath.row].channel)} \(devices[indexPath.row].name)"
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
}
extension DatabaseViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
class DatabaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foundItem: UILabel!
    //    @IBOutlet weak var tableCellTitle: UILabel!
}