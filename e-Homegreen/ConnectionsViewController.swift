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
    
    var isPresenting:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        transitioningDelegate = self
    }
    
    @IBAction func btnAddNewConnection(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: "updateGatewayListNotification", object: nil)
        self.showConnectionSettings(-1)
        
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
        if sender.identifier == "scanUnwind" {
            print("nesto adadad")
        }
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
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            if id == "scanUnwind" {
                let unwindSegue = SegueUnwind(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                    
                })
                return unwindSegue
            }
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        self.commonConstruct()
        
        let gradient:CAGradientLayer = CAGradientLayer()
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
        let fetchRequest = NSFetchRequest(entityName: "Gateway")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
            gateways = fetResults!
            refreshGatewayList()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
//        if let results = fetResults {
//            gateways = results
//            refreshGatewayList()
//        } else {
//        }
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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
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
    
//    override func viewWillLayoutSubviews() {
//        gatewayTableView.reloadData()
//    }
    
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
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func returnThreeCharactersForByte (number:Int) -> String {
        //        var string = ""
        //        var numberLength = "\(number)"
        //        if count(numberLength) == 1 {
        //            string = "00\(number)"
        //        } else if count(numberLength) == 2 {
        //            string = "0\(number)"
        //        } else {
        //            string = "\(number)"
        //        }gateways
        //        return string
        return String(format: "%03d",number)
    }
    

}

extension ConnectionsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("gatewayCell") as? GatewayCell {
            
//            let gradientLayer = CAGradientLayer()
////            if cell.gradientLayer == nil {
////                gradientLayer!.frame = CGRectMake(0, 0, self.view.frame.size.width, 128)
////            }else{
//                gradientLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 128)
////            }
//            gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
//            gradientLayer.locations = [0.0, 1.0]
//            gradientLayer.borderWidth = 1
//            gradientLayer.borderColor = UIColor.grayColor().CGColor
//            gradientLayer.cornerRadius = 10
////            cell.gradientLayer = gradientLayer
//            cell.layer.insertSublayer(gradientLayer, atIndex: 0)
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = UIColor.grayColor().CGColor
//            cell.layer.cornerRadius = 10
            cell.lblGatewayName.text = gateways[indexPath.section].name
            cell.lblGatewayDescription.text = gateways[indexPath.section].gatewayDescription
            cell.lblGatewayDeviceNumber.text = "\(gateways[indexPath.section].devices.count) device(s)"
            cell.add1.text = returnThreeCharactersForByte(Int(gateways[indexPath.section].addressOne))
            cell.add2.text = returnThreeCharactersForByte(Int(gateways[indexPath.section].addressTwo))
            cell.add3.text = returnThreeCharactersForByte(Int(gateways[indexPath.section].addressThree))
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
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 128
//    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
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
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
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
    var gradientLayer: CAGradientLayer?
    
    
    @IBOutlet weak var buttonGatewayScan: UIButton!
    
    @IBOutlet weak var switchGatewayState: UISwitch!
    
    @IBOutlet weak var add1: UILabel!
    @IBOutlet weak var add2: UILabel!
    @IBOutlet weak var add3: UILabel!
    
    override func drawRect(rect: CGRect) {
        let width = rect.width
        let height = rect.height
        
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

