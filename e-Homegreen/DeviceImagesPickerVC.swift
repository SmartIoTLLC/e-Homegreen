//
//  PickImagesVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceImagesPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SceneGalleryDelegate {
    
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
    @IBAction func addNewImage(sender: AnyObject) {
        showGallery(-1).delegate = self
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
    
    func backString(strText: String, imageIndex:Int) {
        if imageIndex == -1 {
            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            deviceImage.state = Int(deviceImages[deviceImages.count-1].state!) + 1
            deviceImage.defaultImage = strText
            deviceImage.device = device
            deviceImage.image = nil
            deviceImages.append(deviceImage)
        } else {
            deviceImages[imageIndex].defaultImage = strText
            deviceImages[imageIndex].image = nil
        }
        do {
            try appDel.managedObjectContext?.save()
        } catch let error {
            
        }
        tableView.reloadData()
    }
    func backImage(image:Image, imageIndex:Int) {
        if imageIndex == -1 {
            // This coudl be a problem because it doesn't have default image. So default image was putt in this case:
            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            deviceImage.state = Int(deviceImages[deviceImages.count-1].state!) + 1
            deviceImage.defaultImage = "12 Appliance - Power - 02"
            deviceImage.device = device
            deviceImage.image = image
            deviceImages.append(deviceImage)
        } else {
            deviceImages[imageIndex].image = image
        }
        do {
            try appDel.managedObjectContext?.save()
        } catch let error {
            
        }
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceImages.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceImageCell", forIndexPath: indexPath) as! DeviceImagePickerTVC
        
        if device.controlType == ControlType.Curtain {
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Open"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "Stop"
            }
            if imags[indexPath.row].state == 2{
                cell.deviceState.text = "Close"
            }
        }else if device.controlType == ControlType.Relay{
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Off"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "On"
            }
            
        }else if device.controlType == ControlType.HumanInterfaceSeries && device.channel.intValue == 2{ // Digitl input 1
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Off"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "On"
            }
        }else if device.controlType == ControlType.HumanInterfaceSeries && device.channel.intValue == 3{ // Digital input 2
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Off"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "On"
            }
        }else if device.controlType == ControlType.HumanInterfaceSeries && device.channel.intValue == 4{ // Temperature
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Off"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "On"
            }
        }else if device.controlType == ControlType.HumanInterfaceSeries && device.channel.intValue == 5{ // IR Receiver
            let imags = device.deviceImages?.allObjects as! [DeviceImage]
            cell.deviceState.text = ""
            if imags[indexPath.row].state == 0{
                cell.deviceState.text = "Locked"
            }
            if imags[indexPath.row].state == 1{
                cell.deviceState.text = "Unlocked"
            }
        }else{
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
        }
        
        cell.deviceImage.image = UIImage().returnImage(forDeviceImage: deviceImages[indexPath.row])
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showGallery(indexPath.row).delegate = self
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
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
        }
        
    }
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