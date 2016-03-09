//
//  SurveillanceSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SurveillanceSettingsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var surveillanceTableView: UITableView!
    
    var isPresenting:Bool = false
    
    var surveillance:[Surveillance] = []
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let lgpr = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        lgpr.minimumPressDuration =  1.0
        lgpr.delegate = self
        self.surveillanceTableView.addGestureRecognizer(lgpr)
        
        fetchSurveillance()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSurveillanceList", name: NotificationKey.RefreshSurveillance, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func handleLongPress (gesture:UILongPressGestureRecognizer) {
        let p = gesture.locationInView(self.surveillanceTableView)
        let indexPath = self.surveillanceTableView.indexPathForRowAtPoint(p)
        if let index = indexPath?.section {
            showSurveillanceSettings(surveillance[index], isNew: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddNewCamera(sender: AnyObject) {
        showSurveillanceSettings(nil, isNew:false)
    }
    
    @IBAction func btnUrls(sender: AnyObject) {
        if let button = sender as? UIButton {
            showCameraUrls(CGPoint(x: button.frame.origin.x, y: button.frame.origin.y), surveillance: surveillance[button.tag])
        }
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
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func fetchSurveillance () {
        let fetchRequest = NSFetchRequest(entityName: "Surveillance")
        let sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "port", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptorTwo]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Surveillance]
            surveillance = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func refreshSurveillanceList(){
        fetchSurveillance()
        surveillanceTableView.reloadData()
    }

}

extension SurveillanceSettingsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("survCell") as? SurvCell {

            cell.backgroundColor = UIColor.clearColor()
            
//            cell.lblID.text = surveillance[indexPath.section].ip
//            cell.lblPort.text = "\(surveillance[indexPath.section].port!)"
            cell.lblLocation.text = "\(surveillance[indexPath.section].locationDELETETHIS!)"
            cell.lblName.text = "\(surveillance[indexPath.section].name!)"
//            cell.switchVisible.tag = indexPath.section
//            cell.switchVisible.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
            cell.btnUrl.tag = indexPath.section
//            if surveillance[indexPath.section].isVisible == true {
//                cell.switchVisible.on = true
//            }else{
//                cell.switchVisible.on = false
//            }
            
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func changeValue(sender:UISwitch){
        if sender.on == true {
            surveillance[sender.tag].isVisible = true
        }else {
            surveillance[sender.tag].isVisible = false
        }
        saveChanges()
        surveillanceTableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSurveillance, object: self, userInfo: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return surveillance.count
    }
    
}

extension SurveillanceSettingsViewController: UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: NotificationKey.Gateway.Refresh, object: nil)        
        dispatch_async(dispatch_get_main_queue(),{
            self.showSurveillanceSettings(self.surveillance[indexPath.section], isNew: false)
        })
    }
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.surveillanceTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(surveillance[indexPath.section])
            saveChanges()
            refreshSurveillanceList()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshSurveillance, object: self, userInfo: nil)

        }
        
    }
}


class SurvCell: UITableViewCell{
    
//    @IBOutlet weak var lblID: UILabel!
//    @IBOutlet weak var lblPort: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var switchVisible: UISwitch!
    @IBOutlet weak var btnUrl: CustomGradientButton!
    
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
