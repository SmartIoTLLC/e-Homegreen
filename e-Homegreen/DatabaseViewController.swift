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
//    var outSocket:OutSocket!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var gatewaysNames:[String] = []
    var error:NSError? = nil
    var backgroundImageView = UIImageView()
    
    
    @IBOutlet weak var idRangeFrom: UITextField!
    @IBOutlet weak var idRangeTo: UITextField!
    
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var btnChooseGateway: UIButton!
    var isPresenting:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnChooseGateway.setTitle("Choose your connection", forState: UIControlState.Normal)
        
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)

        idRangeFrom.delegate = self
        idRangeTo.delegate = self
        fetchAllGateways()
        idRangeFrom.text = "\(1)"
        idRangeTo.text = "\(1)"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnDeleteAll(sender: AnyObject) {
        if choosedGatewayIndex != -1 {
            for var item = 0; item < devices.count; item++ {
                if devices[item].gateway.objectID == gateways[choosedGatewayIndex].objectID {
                    appDel.managedObjectContext!.deleteObject(devices[item])
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
                NSTimer.scheduledTimerWithTimeInterval(number*0.5, target: self, selector: "getDevicesNames:", userInfo: index, repeats: false)
            }
        }
    }
    func getDevicesNames (timer:NSTimer) {
        if let index = timer.userInfo as? Int {
            if devices[index].type == "Dimmer" {
                var address = [UInt8(Int(devices[index].gateway.addressOne)), UInt8(Int(devices[index].gateway.addressTwo)), UInt8(Int(devices[index].address))]
                SendingHandler(byteArray: Function.getChannelName(address, channel: UInt8(Int(devices[index].channel))), gateway: devices[index].gateway)
            }
            if devices[index].type == "curtainsRelay" {
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
            }
        }
    }
    
    var popoverVC:PopOverViewController = PopOverViewController()
    var choosedGatewayIndex:Int = -1
    
    func clickedOnGatewayWithIndex(index: Int) {
        btnChooseGateway.setTitle("\(gateways[index].name)", forState: UIControlState.Normal)
        choosedGatewayIndex = index
        refreshDeviceList()
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
            popoverController.backgroundColor = UIColor.lightGrayColor()
            self.presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
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
    
    func refreshDeviceList () {
        if gateways != [] {
            if choosedGatewayIndex != -1 {
                updateDeviceList()
            }
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
                if let numberOne = idRangeFrom.text.toInt(), let numberTwo = idRangeTo.text.toInt() {
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
    }
    
    func searchIds(timer:NSTimer) {
        println("!!!   \(timer.userInfo)    !!!")
        if let deviceNumber = timer.userInfo as? Int {
            var address = [UInt8(Int(gateways[choosedGatewayIndex].addressOne)), UInt8(Int(gateways[choosedGatewayIndex].addressTwo)), UInt8(deviceNumber)]
            SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateways[choosedGatewayIndex])
        }
    }
    
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
    
    var timerSensorNumber = 0

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView.bounds.size.width
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("databaseCell") as? DatabaseTableViewCell {
            cell.foundItem.text = "\(indexPath.row+1). {GW Adr: \(devices[indexPath.row].gateway.addressOne):\(devices[indexPath.row].gateway.addressTwo):\(devices[indexPath.row].address), Ch:\(devices[indexPath.row].channel)} \(devices[indexPath.row].name)"
            cell.backgroundColor = UIColor.clearColor()
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
    
}