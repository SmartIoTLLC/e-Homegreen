//
//  PickImagesVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceImagesPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device
//    var appDel:AppDelegate!
    var isPresenting: Bool = true
    var appDel:AppDelegate
    
    
    @IBAction func btnBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    @IBOutlet weak var tableView: UITableView!
        var deviceImages:[DeviceImage]
    init(device:Device, point:CGPoint){
        self.device = device
        self.point = point
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let sort = NSSortDescriptor(key: "state", ascending: true)
        deviceImages = device.deviceImages!.sortedArrayUsingDescriptors([sort]) as! [DeviceImage]
        super.init(nibName: "DeviceImagesPickerVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
//        deviceImages = device.deviceImages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "DeviceImagePickerTVC", bundle: nil), forCellReuseIdentifier: "deviceImageCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceImageCell", forIndexPath: indexPath) as! DeviceImagePickerTVC
        if deviceImages.count == 2 {
            if indexPath.row == 0 {
                cell.deviceState.text = "\(0)"
            }
            if indexPath.row == deviceImages.count-1 {
                cell.deviceState.text = "\(100)"
            }
        }
        if deviceImages.count > 2 {
            if indexPath.row == 0 {
                cell.deviceState.text = "\(0)"
            } else if indexPath.row == deviceImages.count-1 {
                cell.deviceState.text = "\(100)"
            } else {
                let part:Double = Double(100) / Double(deviceImages.count-2)
                let number1 = String.localizedStringWithFormat("%.01f", part*Double(indexPath.row-1))
                let number2 = String.localizedStringWithFormat("%.01f", part*Double(indexPath.row))
                cell.deviceState.text = number1 + " - " + number2
            }
        }
        cell.deviceImage.image = UIImage().returnImage(forDeviceImage: deviceImages[indexPath.row])
//        if let deviceImage = deviceImages[indexPath.row].image?.imageData {
//            cell.deviceImage.image = UIImage(data: deviceImage)
//        } else {
//            cell.deviceImage.image = UIImage(named:deviceImages[indexPath.row].defaultImage!)
//        }
//        if let deviceImage = UIImage(data: (deviceImages[indexPath.row].image!.imageData)!) {
//            cell.deviceImage.image = deviceImage
//        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(deviceImages[indexPath.row])
            deviceImages.removeAtIndex(indexPath.row)
            appDel.saveContext()
            tableView.reloadData()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension DeviceImagesPickerVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            containerView!.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
}
extension DeviceImagesPickerVC : UIViewControllerTransitioningDelegate {
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
extension UIViewController {
    func showDeviceImagesPicker(device:Device, point:CGPoint) {
        let dip = DeviceImagesPickerVC(device:device, point:point)
        self.presentViewController(dip, animated: true, completion: nil)
    }
}
extension UIImage {
    func returnImage (forDeviceImage deviceImage:DeviceImage) -> UIImage {
        if let deviceImageUnwrapped = deviceImage.image?.imageData {
            return UIImage(data: deviceImageUnwrapped)!
        } else {
            return UIImage(named:deviceImage.defaultImage!)!
        }
    }
}