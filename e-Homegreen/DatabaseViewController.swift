//
//  DatabaseViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {

    @IBOutlet weak var databaseTable: UITableView!
    var inSocket:InSocket!
    var outSocket:OutSocket!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var gateways:[Gateway] = []
    var gatewaysNames:[String] = []
    var error:NSError? = nil
    var backgroundImageView = UIImageView()
    
    @IBOutlet weak var btnChooseGateway: UIButton!
    var isPresenting:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    @IBAction func btnDeleteAll(sender: AnyObject) {
        for var i = 0; i < gateways.count; ++i {
            println("\(gateways[i].ipInUse) \(gateways[i].portInUse)")
            gateways[i].ipInUse = "a"
            gateways[i].portInUse = NSNumber(int: 123)
        }
//        SendingHandler(byteArray: [0xAA, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x00, 0x05, 0x10], ip: "2.50.32.208", port: 5001)
    }
    
    var testSocketOne:OutSocket?
    var testSocketTwo:InSocket?
    @IBAction func btnFindNames(sender: AnyObject) {
//        if choosedGatewayIndex != -1 {
//            var number:Int = 1
//            if let numberOne = idRangeFrom.text.toInt()! as? Int, let numberTwo = idRangeTo.text.toInt()! as? Int {
//                for var i = numberOne; i <= numberTwo; ++i {
//                    var number:NSTimeInterval = NSTimeInterval(i)
//                    NSTimer.scheduledTimerWithTimeInterval(number, target: self, selector: "searchNames:", userInfo: i, repeats: false)
//                }
//            }
//        }
    }
    func searchNames (timer:NSTimer) {
        // treba svaki posebno proveriti
//        if let deviceNumber = timer.userInfo as? Int {
//            SendingHandler(byteArray: Functions().getSensorName(0x05, channel: UInt8(timerSensorNumber)), ip: gateways[choosedGatewayIndex].localIp, port: Int(gateways[choosedGatewayIndex].localPort))
//        }
    }
    var popoverVC:PopOverViewController = PopOverViewController()
    var choosedGatewayIndex:Int = -1
    func clickedOnGatewayWithIndex(index: Int) {
        println(index)
        btnChooseGateway.setTitle("\(gateways[index].name)", forState: UIControlState.Normal)
        choosedGatewayIndex = index
    }
    @IBAction func btnChooseGateway(sender: UIButton) {
        gatewaysNames = []
        for item in gateways {
            gatewaysNames.append("\(item.name) \(item.device.count)")
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
            self.presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    override func viewWillDisappear(animated: Bool) {
//        testSocketOne?.socket.close()
//        testSocketTwo?.socket.close()
    }
    @IBOutlet weak var idRangeFrom: UITextField!
    @IBOutlet weak var idRangeTo: UITextField!
    var receivingSocket:InSocket?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonConstruct()
//        testSocketTwo = InSocket(ip: "192.168.0.7", port: 5001)
//        testSocketOne = OutSocket(ip: "192.168.0.7", port: 5001)
//        testSocketTwo = InSocket(ip: "e-home.dyndns.org", port: 5001)
//        testSocketOne = OutSocket(ip: "e-home.dyndns.org", port: 5001)
//        testSocketTwo = InSocket(ip: "2.50.32.208", port: 5001)
//        testSocketOne = OutSocket(ip: "255.255.255.255", port: 5001)
        
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
        
        
        var fetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
        for item in devices {
            databaseArray.append("\(item.name)")
            println(item.name)
        }
        fetchAllGateways()
        
        // Do any additional setup after loading the view.
    }
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
    func refreshDeviceList () {
        updateDeviceList()
        databaseTable.reloadData()
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
    var deviceNumber = 0
    var touched = false
    @IBAction func btnRefresTableView(sender: AnyObject) {
//        outSocket.sendByte(Functions().searchForDevices(0x05))
        var fetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
        println("")
        databaseArray = []
        for item in devices {
            databaseArray.append("\(item.name); \(item.address); \(item.channel)")
            println("name: \(item.name) address: \(item.address) channel: \(item.channel) type: \(item.type) current: \(item.current) currentValue: \(item.currentValue) gateway: \(item.gateway) amp: \(item.amp) numberOfDevices: \(item.numberOfDevices) runningTime: \(item.runningTime)")
        }
        databaseTable.reloadData()
    }
    var loader : ViewControllerUtils = ViewControllerUtils()
    var quitLoader:Int = 0
    @IBAction func findDevices(sender: AnyObject) {
        if choosedGatewayIndex != -1 {
            var number:Int = 1
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
    func hideActivitIndicator () {
        loader.hideActivityIndicator()
    }
    var timerSensorNumber = 0
//    func getSensorName () {
//        outSocket.sendByte(Functions().getSensorName(0x05, channel: UInt8(timerSensorNumber)))
//        timerSensorNumber = timerSensorNumber + 1
//    }
    var databaseArray:[String] = []
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func searchIds(timer:NSTimer) {
//        var sendSocket = OutSocket(ip: gateways[in], port: <#UInt16#>)
//        outSocket.sendByte(Functions().searchForDevices(UInt8(deviceNumber)))
        if let deviceNumber = timer.userInfo as? Int {
            SendingHandler(byteArray: Functions().searchForDevices(UInt8(deviceNumber)), ip: gateways[choosedGatewayIndex].localIp, port: Int(gateways[choosedGatewayIndex].localPort))
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
        return databaseArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("databaseCell") as? DatabaseTableViewCell {
            cell.foundItem.text = databaseArray[indexPath.row]
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