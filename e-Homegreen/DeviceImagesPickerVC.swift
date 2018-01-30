//
//  PickImagesVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 2/26/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DeviceImagesPickerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var device:Device
    var isPresenting: Bool = true
    var appDel:AppDelegate
    
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
        deviceImages = device.deviceImages!.sortedArray(using: [NSSortDescriptor(key: "state", ascending: true)]) as! [DeviceImage]
        super.init(nibName: "DeviceImagesPickerVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "DeviceImagePickerTVC", bundle: nil), forCellReuseIdentifier: "deviceImageCell")

        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "deviceImageCell", for: indexPath) as? DeviceImagePickerTVC {
            cell.setCell(deviceImages: deviceImages, indexPathRow: indexPath.row)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showGallery((indexPath as NSIndexPath).row, user: device.gateway.location.user).delegate = self
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return makeRowAction(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { deleteDevices(indexPath: indexPath) }
    }
}

// MARK: - Scene Gallery Delegate
extension DeviceImagesPickerVC: SceneGalleryDelegate {
    func backString(_ strText: String, imageIndex:Int) {
        if let moc = appDel.managedObjectContext {
            if imageIndex == -1 {
                let deviceImage = DeviceImage(context: moc)
                deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
                deviceImage.defaultImage = strText
                deviceImage.device = device
                deviceImage.customImageId = nil
                deviceImages.append(deviceImage)
            } else {
                deviceImages[imageIndex].defaultImage = strText
                deviceImages[imageIndex].customImageId = nil
            }
            do { try moc.save() } catch { }
            
            tableView.reloadData()
        }
    }
    
    func backImageFromGallery(_ data: Data, imageIndex: Int) {
        if let moc = appDel.managedObjectContext {
            if imageIndex == -1 {
                // This coudl be a problem because it doesn't have default image. So default image was putt in this case:
                let deviceImage = DeviceImage(context: moc)
                deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
                deviceImage.defaultImage = "12 Appliance - Power - 02"
                deviceImage.device = device
                
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: moc) as? Image {
                    image.imageData = data
                    image.imageId = UUID().uuidString
                    deviceImage.customImageId = image.imageId
                    if let user  = deviceImage.device?.gateway.location.user { user.addImagesObject(image) }
                }
                
                deviceImages.append(deviceImage)
            } else {
                if let image = NSEntityDescription.insertNewObject(forEntityName: "Image", into: moc) as? Image {
                    image.imageData = data
                    image.imageId = UUID().uuidString
                    deviceImages[imageIndex].customImageId = image.imageId
                    
                    if let user  = deviceImages[imageIndex].device?.gateway.location.user { user.addImagesObject(image) }
                }
            }
            do { try moc.save() } catch { }
            
            tableView.reloadData()
        }
    }
    
    func backImage(_ image:Image, imageIndex:Int) {
        if let moc = appDel.managedObjectContext {
            if imageIndex == -1 {
                // This coudl be a problem because it doesn't have default image. So default image was putt in this case:
                let deviceImage = DeviceImage(context: moc)
                deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
                deviceImage.defaultImage = "12 Appliance - Power - 02"
                deviceImage.device = device
                deviceImage.customImageId = image.imageId
                deviceImages.append(deviceImage)
            } else {
                deviceImages[imageIndex].customImageId = image.imageId
            }
            
            do { try moc.save() } catch { }
            
            tableView.reloadData()
        }
    }
}

// MARK: - View setup
extension DeviceImagesPickerVC {
    fileprivate func makeRowAction(at indexPath: IndexPath) -> [UITableViewRowAction] {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let delete = UIAlertAction(title: "Delete", style: .destructive){(action) -> Void in
                self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    presentationController.sourceView = cell
                    presentationController.sourceRect = cell.bounds
                }
            }
            self.present(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
}

// MARK: - Logic
extension DeviceImagesPickerVC {
    fileprivate func deleteDevices(indexPath: IndexPath) {
        // Here needs to be deleted even devices that are from gateway that is going to be deleted
        if let moc = appDel.managedObjectContext {
            moc.delete(deviceImages[indexPath.row])
            deviceImages.remove(at: indexPath.row)
            let deviceId: [String:NSManagedObjectID] = ["deviceId": device.objectID]
            NotificationCenter.default.post(name: .deviceShouldResetImages, object: deviceId)
            appDel.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
            tableView.reloadData()
        }
        
    }
}

extension Notification.Name {
    static let deviceShouldResetImages = Notification.Name("deviceShouldResetImages")
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
        if dismissed == self { return self } else { return nil }
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
        
        if let id = deviceImage.customImageId {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    return UIImage(data: data)!
                    
                } else { return UIImage(named:deviceImage.defaultImage!)! }
            } else { return UIImage(named:deviceImage.defaultImage!)! }
        } else { return UIImage(named:deviceImage.defaultImage!)! }
    }
}

extension Notification.Name {
    static let imageFromSceneGalleryPicked = Notification.Name("deviceImagePicked")
}
