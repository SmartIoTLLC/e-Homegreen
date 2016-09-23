//
//  PickImagesVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DeviceImagesPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SceneGalleryDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device
//    var appDel:AppDelegate!
    var isPresenting: Bool = true
    var appDel:AppDelegate
//    var imags = [DeviceImageState]()
    
    @IBAction func btnBack(_ sender: AnyObject) {
        self.dismiss(animated: true) { () -> Void in
        }
    }
    
    @IBAction func addNewImage(_ sender: AnyObject) {
        showGallery(-1, user: device.gateway.location.user!).delegate = self
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var deviceImages:[DeviceImage]

    init(device:Device, point:CGPoint){
        self.device = device
        self.point = point
        appDel = UIApplication.shared.delegate as! AppDelegate
        let sort = NSSortDescriptor(key: "state", ascending: true)
        deviceImages = device.deviceImages!.sortedArray(using: [sort]) as! [DeviceImage]
        super.init(nibName: "DeviceImagesPickerVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
//        deviceImages = device.deviceImages
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceImagePickerTVC", bundle: nil), forCellReuseIdentifier: "deviceImageCell")
//        imags = DefaultDeviceImages().getNewImagesForDevice(device)
        // Do any additional setup after loading the view.
        tableView.reloadData()
    }
    
    func backString(_ strText: String, imageIndex:Int) {
        if imageIndex == -1 {
            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
            deviceImage.defaultImage = strText
            deviceImage.device = device
            deviceImage.customImageId = nil
            deviceImages.append(deviceImage)
        } else {
            deviceImages[imageIndex].defaultImage = strText
            deviceImages[imageIndex].customImageId = nil
        }
        do {
            try appDel.managedObjectContext?.save()
        } catch _ {
            
        }
        tableView.reloadData()
    }
    
    func backImageFromGallery(_ data: Data, imageIndex: Int) {
        if imageIndex == -1 {
            // This coudl be a problem because it doesn't have default image. So default image was putt in this case:
            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
            deviceImage.defaultImage = "12 Appliance - Power - 02"
            deviceImage.device = device
            
            if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                image.imageData = data
                image.imageId = UUID().uuidString
                deviceImage.customImageId = image.imageId
                
                
                if let user  = deviceImage.device?.gateway.location.user{
                    user.addImagesObject(image)
                }
            }
            
            deviceImages.append(deviceImage)
        } else {
            if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: appDel.managedObjectContext!) as? Image{
                image.imageData = data
                image.imageId = UUID().uuidString
                deviceImages[imageIndex].customImageId = image.imageId
                
                if let user  = deviceImages[imageIndex].device?.gateway.location.user{
                    user.addImagesObject(image)
                }
//                image.user = deviceImages[imageIndex].device?.gateway.location.user
            }
        }
        do {
            try appDel.managedObjectContext?.save()
        } catch _ {
            
        }
        tableView.reloadData()

    }
    
    func backImage(_ image:Image, imageIndex:Int) {
        if imageIndex == -1 {
            // This coudl be a problem because it doesn't have default image. So default image was putt in this case:
            let deviceImage = DeviceImage(context: appDel.managedObjectContext!)
            deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
            deviceImage.defaultImage = "12 Appliance - Power - 02"
            deviceImage.device = device
            deviceImage.customImageId = image.imageId
            deviceImages.append(deviceImage)
        } else {
            deviceImages[imageIndex].customImageId = image.imageId
            
        }
        do {
            try appDel.managedObjectContext?.save()
        } catch _ {
            
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceImageCell", for: indexPath) as! DeviceImagePickerTVC
        cell.backgroundColor = UIColor.clear

        cell.deviceState.text = ""
        if let stateText = deviceImages[(indexPath as NSIndexPath).row].text {
            cell.deviceState.text = stateText
        }else{
            let av = Int(100/(deviceImages.count-1))
            
            if (indexPath as NSIndexPath).row == 0 {
                cell.deviceState.text = "0"
            }else if (indexPath as NSIndexPath).row == deviceImages.count-1{
                cell.deviceState.text = "\(((indexPath as NSIndexPath).row-1)*av+1) - 100"
            }else{
                cell.deviceState.text = "\(((indexPath as NSIndexPath).row-1)*av+1) - \(((indexPath as NSIndexPath).row-1)*av + av)"
            }

        }
        
        if let id = deviceImages[(indexPath as NSIndexPath).row].customImageId{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    cell.deviceImage.image = UIImage(data: data)
                }else{
                    cell.deviceImage.image = UIImage(named: deviceImages[(indexPath as NSIndexPath).row].defaultImage!)
                }
            }else{
                cell.deviceImage.image = UIImage(named: deviceImages[(indexPath as NSIndexPath).row].defaultImage!)
            }
        }else{
            cell.deviceImage.image = UIImage(named: deviceImages[(indexPath as NSIndexPath).row].defaultImage!)
        }

        return cell


        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showGallery((indexPath as NSIndexPath).row, user: device.gateway.location.user).delegate = self
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive){(action) -> Void in
                self.tableView(self.tableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                presentationController.sourceView = tableView.cellForRow(at: indexPath)
                presentationController.sourceRect = tableView.cellForRow(at: indexPath)!.bounds
            }
            self.present(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.delete(deviceImages[(indexPath as NSIndexPath).row])
            deviceImages.remove(at: (indexPath as NSIndexPath).row)
            appDel.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
            tableView.reloadData()
        }
        
    }
}
extension DeviceImagesPickerVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
}
extension DeviceImagesPickerVC : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
}
extension UIViewController {
    func showDeviceImagesPicker(_ device:Device, point:CGPoint) {
        let dip = DeviceImagesPickerVC(device:device, point:point)
        self.present(dip, animated: true, completion: nil)
    }
}
extension UIImage {
    func returnImage (forDeviceImage deviceImage:DeviceImage) -> UIImage {
        
        if let id = deviceImage.customImageId{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    return UIImage(data: data)!
                }else{
                    return UIImage(named:deviceImage.defaultImage!)!
                }
            }else{
                return UIImage(named:deviceImage.defaultImage!)!
            }
        }else{
            return UIImage(named:deviceImage.defaultImage!)!
        }
    }
}
