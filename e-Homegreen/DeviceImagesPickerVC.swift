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
    var oldPoint:CGPoint? = .zero
    var device:Device
    var isPresenting: Bool = true
    var appDel:AppDelegate
    
    var deviceImages:[DeviceImage]
    
    @IBAction func btnBack(_ sender: AnyObject) {
        dismissModal()
    }
    @IBAction func addNewImage(_ sender: AnyObject) {
        showGallery(-1, user: device.gateway.location.user!).delegate = self
    }
    @IBOutlet weak var tableView: UITableView!

    init(device:Device, point:CGPoint){
        self.device = device
        self.point = point
        appDel = UIApplication.shared.delegate as! AppDelegate
        let sort = NSSortDescriptor(key: "state", ascending: true)
        deviceImages = device.deviceImages!.sortedArray(using: [sort]) as! [DeviceImage]
        super.init(nibName: "DeviceImagesPickerVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
 
}

// MARK: - TableView Delegate
extension DeviceImagesPickerVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showGallery(indexPath.row, user: device.gateway.location.user).delegate = self
    }
}

// MARK: - TableView Data Source
extension DeviceImagesPickerVC {
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return makeRowAction(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { deleteDevices(indexPath: indexPath) }
    }
}

// MARK: - Setup views
extension DeviceImagesPickerVC {
    fileprivate func setupViews() {
        tableView.register(UINib(nibName: "DeviceImagePickerTVC", bundle: nil), forCellReuseIdentifier: "deviceImageCell")
        tableView.reloadData()
    }
    
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

extension Notification.Name {
    static let deviceShouldResetImages = Notification.Name("deviceShouldResetImages")
}

// MARK: - Logic
extension DeviceImagesPickerVC {
    fileprivate func deleteDevices(indexPath: IndexPath) {
        // Here needs to be deleted even devices that are from gateway that is going to be deleted
        if let moc = appDel.managedObjectContext {
            moc.delete(deviceImages[indexPath.row])
            deviceImages.remove(at: indexPath.row)
            let deviceId: [String: NSManagedObjectID] = ["deviceId": device.objectID]
            NotificationCenter.default.post(name: .deviceShouldResetImages, object: deviceId)
            appDel.saveContext()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshDevice), object: self, userInfo: nil)
            tableView.reloadData()
        }
        
    }
    
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
            
            do { try moc.save() } catch {}
        }
        
        tableView.reloadData()
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
            
            do { try moc.save() } catch {}
        }
        
        tableView.reloadData()
    }
    
    func backImage(_ image:Image, imageIndex:Int) {
        if let moc = appDel.managedObjectContext {
            if imageIndex == -1 {
                // This could be a problem because it doesn't have default image. So default image was putt in this case:
                let deviceImage = DeviceImage(context: moc)
                deviceImage.state = NSNumber(value: (Int(deviceImages[deviceImages.count-1].state!) + 1))
                deviceImage.defaultImage = "12 Appliance - Power - 02"
                deviceImage.device = device
                deviceImage.customImageId = image.imageId
                deviceImages.append(deviceImage)
            } else {
                deviceImages[imageIndex].customImageId = image.imageId
            }
            
            do { try moc.save() } catch {}
        }

        
        tableView.reloadData()
    }
}

extension DeviceImagesPickerVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
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
                
                if let data = image.imageData { return UIImage(data: data)!
                } else { return UIImage(named:deviceImage.defaultImage!)! }
                
            } else { return UIImage(named:deviceImage.defaultImage!)! }
        } else { return UIImage(named:deviceImage.defaultImage!)! }
    }
}
