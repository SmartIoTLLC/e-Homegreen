//
//  SurveillanceSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/24/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SurveillanceSettingsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    @IBOutlet weak var topView: UIView!
    
    var isPresenting:Bool = false
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        }else{
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnAddNewCamera(sender: AnyObject) {
        showSurveillanceSettings()
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

}

extension SurveillanceSettingsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCellWithIdentifier("vlada") as? VladaCell {
//        print("Unresolved error")
        
//            let gradientLayer = CAGradientLayer()
//            gradientLayer.frame = CGRectMake(0, 0, 320, 128)
//            gradientLayer.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
//            gradientLayer.locations = [0.0, 1.0]
//            gradientLayer.borderWidth = 1
//            gradientLayer.borderColor = UIColor.grayColor().CGColor
//            gradientLayer.cornerRadius = 10
//            
//            cell.layer.insertSublayer(gradientLayer, atIndex: 0)
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = UIColor.grayColor().CGColor
//            cell.layer.cornerRadius = 10
            
//            return cell
//        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    //    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return 128
    //    }
    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 5
//    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
////        return gateways.count
//        return 3
//    }
    
}

extension SurveillanceSettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: "updateGatewayListNotification", object: nil)
//        
//        dispatch_async(dispatch_get_main_queue(),{
//            self.showConnectionSettings(indexPath.section)
//        })
    }
    
//    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
//            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
//                self.tableView(self.gatewayTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
//            }
//            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//            deleteMenu.addAction(delete)
//            deleteMenu.addAction(cancelDelete)
//            if let presentationController = deleteMenu.popoverPresentationController {
//                presentationController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
//                presentationController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
//            }
//            self.presentViewController(deleteMenu, animated: true, completion: nil)
//        })
//        
//        button.backgroundColor = UIColor.redColor()
//        return [button]
//    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
//        if editingStyle == .Delete {
//            // Here needs to be deleted even devices that are from gateway that is going to be deleted
//            appDel.managedObjectContext?.deleteObject(gateways[indexPath.section])
//            saveChanges()
//            fetchGateways()
//        }
        
//    }
}


class VladaCell: UITableViewCell{
    
}
