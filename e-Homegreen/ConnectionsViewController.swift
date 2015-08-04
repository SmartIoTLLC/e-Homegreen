//
//  ConnectionsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ConnectionsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    var backgroundImageView = UIImageView()
    var gateways:[Gateway] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var gatewayTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    var isPresenting:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }
    
    @IBAction func btnAddNewConnection(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: "updateGatewayListNotification", object: nil)
        self.showConnectionSettings(-1)
        
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
        if sender.identifier == "scanUnwind" {
            println("nesto adadad")
        }
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            if id == "scanUnwind" {
                let unwindSegue = SegueUnwind(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                    
                })
                return unwindSegue
            }
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonConstruct()
        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        
        // Do any additional setup after loading the view.
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        fetchGateways()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshGatewayListWithNewData", name: "refreshDeviceListNotification", object: nil)
        
    }
    func refreshGatewayListWithNewData () {
        fetchGateways()
        gatewayTableView.reloadData()
    }
    func updateNewGatewayList () {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateGatewayListNotification", object: nil)
        fetchGateways()
    }
    func fetchGateways () {
        var fetchRequest = NSFetchRequest(entityName: "Gateway")
        var sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Gateway]
        if let results = fetResults {
            gateways = results
            refreshGatewayList()
        } else {
        }
    }
    func refreshGatewayList () {
        gatewayTableView.reloadData()
    }
    func commonConstruct() {
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 64, Common().screenWidth , Common().screenHeight-64)
        self.view.insertSubview(backgroundImageView, atIndex: 0)
    }
    @IBAction func btnSaveConnection(sender: AnyObject) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    func changeValue(sender:UISwitch){
        if sender.on == true {
            gateways[sender.tag].turnedOn = true
        }else {
            gateways[sender.tag].turnedOn = false
        }
        saveChanges()
        gatewayTableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}
extension ConnectionsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println(indexPath.section)
        if let cell = tableView.dequeueReusableCellWithIdentifier("gatewayCell") as? GatewayCell {
            
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = CGRectMake(0, 0, 1024, 128)
            gradientLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
            gradientLayer.locations = [0.0, 1.0]
//            cell.gradientLayer = gradientLayer
            cell.backgroundView = UIView()
            cell.backgroundView?.layer.insertSublayer(gradientLayer, atIndex: 0)
            cell.layer.cornerRadius = 5
            println(indexPath.section)
            cell.lblGatewayName.text = gateways[indexPath.section].name
            cell.lblGatewayDescription.text = gateways[indexPath.section].gatewayDescription
            cell.lblGatewayDeviceNumber.text = "\(gateways[indexPath.section].device.count) device(s)"
            cell.add1.text = "\(gateways[indexPath.section].addressOne)"
            cell.add2.text = "\(gateways[indexPath.section].addressTwo)"
            cell.add3.text = "\(gateways[indexPath.section].addressThree)"
            cell.switchGatewayState.on = gateways[indexPath.section].turnedOn.boolValue
            cell.switchGatewayState.tag = indexPath.section
            cell.switchGatewayState.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
            cell.add1.layer.cornerRadius = 3
            cell.add2.layer.cornerRadius = 3
            cell.add3.layer.cornerRadius = 3
            cell.add1.clipsToBounds = true
            cell.add2.clipsToBounds = true
            cell.add3.clipsToBounds = true
            if UIScreen.mainScreen().scale > 2.5{
                cell.add1.layer.borderWidth = 1
                cell.add2.layer.borderWidth = 1
                cell.add3.layer.borderWidth = 1
                cell.buttonGatewayScan.layer.borderWidth = 1
            }else{
                cell.add1.layer.borderWidth = 0.5
                cell.add2.layer.borderWidth = 0.5
                cell.add3.layer.borderWidth = 0.5
                cell.buttonGatewayScan.layer.borderWidth = 0.5
            }
            cell.add1.layer.borderColor = UIColor.whiteColor().CGColor
            cell.add2.layer.borderColor = UIColor.whiteColor().CGColor
            cell.add3.layer.borderColor = UIColor.whiteColor().CGColor
            cell.buttonGatewayScan.layer.borderColor = UIColor.whiteColor().CGColor
            cell.buttonGatewayScan.layer.cornerRadius = 5
            cell.buttonGatewayScan.addTarget(self, action: "scanDevice:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.buttonGatewayScan.tag = indexPath.section
            
            if gateways[indexPath.section].turnedOn.boolValue {
                cell.buttonGatewayScan.enabled = true
            } else {
                cell.buttonGatewayScan.enabled = false
            }
            
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return gateways.count
    }
    func scanDevice(button:UIButton){
        performSegueWithIdentifier("scan", sender: button)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scan" {
            if let button = sender as? UIButton {
                if let vc = segue.destinationViewController as? ScanViewController {
                        vc.gateway = gateways[button.tag]
                }
            }
        }
    }
    
}

extension ConnectionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: "updateGatewayListNotification", object: nil)
        
        dispatch_async(dispatch_get_main_queue(),{
            self.showConnectionSettings(indexPath.section)
        })
    }
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.gatewayTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                presentationController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                presentationController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
            }
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.deleteObject(gateways[indexPath.section])
            saveChanges()
            fetchGateways()
        }
        
    }
}

// Gateway cell
class GatewayCell: UITableViewCell {
    
    @IBOutlet weak var lblGatewayName: UILabel!
    @IBOutlet weak var lblGatewayDeviceNumber: UILabel!
    @IBOutlet weak var lblGatewayDescription: UILabel!
    
    
    @IBOutlet weak var buttonGatewayScan: UIButton!
    
    @IBOutlet weak var switchGatewayState: UISwitch!
    
    @IBOutlet weak var add1: UILabel!
    @IBOutlet weak var add2: UILabel!
    @IBOutlet weak var add3: UILabel!
    
}

