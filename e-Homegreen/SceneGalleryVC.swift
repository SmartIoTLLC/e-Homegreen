//
//  SceneGalleryVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
//import ALCameraViewController
import CoreData

@objc protocol SceneGalleryDelegate{
    // Returns string for image and index
    optional func backString(strText: String, imageIndex:Int)
    // Returns data for image and index
    optional func backImageFromGallery(data:NSData, imageIndex:Int)
    // Returns Image for image and index
    optional func backImage(image:Image, imageIndex:Int)
}

class SceneGalleryVC: CommonXIBTransitionVC, UICollectionViewDataSource {
    
    var delegate : SceneGalleryDelegate?
    
    var galleryList:[String] = ["04 Climate Control - Air Freshener - 00",
"04 Climate Control - Air Freshener - 01",
"04 Climate Control - HVAC - 00",
"04 Climate Control - HVAC - 01", 
"11 Lighting - Bulb - 00", 
"11 Lighting - Bulb - 01", 
"11 Lighting - Bulb - 02", 
"11 Lighting - Bulb - 03", 
"11 Lighting - Bulb - 04", 
"11 Lighting - Bulb - 05", 
"11 Lighting - Bulb - 06", 
"11 Lighting - Bulb - 07", 
"11 Lighting - Bulb - 08", 
"11 Lighting - Bulb - 09", 
"11 Lighting - Bulb - 10", 
"11 Lighting - Flood Light - 00", 
"11 Lighting - Flood Light - 01", 
"12 Appliance - Bell - 00", 
"12 Appliance - Bell - 01", 
"12 Appliance - Big Bell - 00.png", 
"12 Appliance - Big Bell - 01",
"12 Appliance - Fountain - 00", 
"12 Appliance - Fountain - 01", 
"12 Appliance - Hood - 00", 
"12 Appliance - Hood - 01", 
"12 Appliance - Power - 00", 
"12 Appliance - Power - 01", 
"12 Appliance - Power - 02", 
"12 Appliance - Socket - 00", 
"12 Appliance - Socket - 01", 
"12 Appliance - Sprinkler - 00", 
"12 Appliance - Sprinkler - 01", 
"12 Appliance - Switch - 00", 
"12 Appliance - Switch - 01", 
"12 Appliance - Washing Machine - 00", 
"12 Appliance - Washing Machine - 01", 
"12 Appliance - Water Heater - 00", 
"12 Appliance - Water Heater - 01", 
"13 Curtain - Curtain - 00", 
"13 Curtain - Curtain - 01", 
"13 Curtain - Curtain - 02", 
"13 Curtain - Curtain - 03", 
"13 Curtain - Curtain - 04", 
"14 Security - Camcorder - 00", 
"14 Security - Camera - 00", 
"14 Security - Door - 00", 
"14 Security - Door - 01", 
"14 Security - Gate - 00", 
"14 Security - Gate - 01", 
"14 Security - Lock - 00", 
"14 Security - Lock - 01", 
"14 Security - Motion Sensor - 00", 
"14 Security - Motion Sensor - 01", 
"14 Security - Motion Sensor - 02", 
"14 Security - Reader - 00", 
"14 Security - Reader - 01", 
"14 Security - Reader - 02", 
"14 Security - Smoke Heat - 00", 
"14 Security - Smoke Heat - 01", 
"14 Security - Surveillance - 00", 
"14 Security - Window - 00", 
"14 Security - Window - 01", 
"15 Timer - CLock - 00", 
"15 Timer - CLock - 01", 
"16 Flag - Flag - 00", 
"16 Flag - Flag - 01", 
"17 Event - Alarm - 00", 
"17 Event - Alarm - 01", 
"17 Event - Away - 00", 
"17 Event - Away - 01", 
"17 Event - Baby - 00", 
"17 Event - Baby - 01", 
"17 Event - Baby Sleep - 00", 
"17 Event - Baby Sleep - 01", 
"17 Event - Bye - 00", 
"17 Event - Bye - 01", 
"17 Event - Chill - 00", 
"17 Event - Chill - 01", 
"17 Event - Daytime - 00", 
"17 Event - Daytime - 01", 
"17 Event - Dining - 00", 
"17 Event - Dining - 01", 
"17 Event - Earth - 00", 
"17 Event - Earth - 01", 
"17 Event - Follow Me - 00", 
"17 Event - Follow Me - 01", 
"17 Event - Guest - 00", 
"17 Event - Guest - 01", 
"17 Event - Home - 00", 
"17 Event - Home - 01", 
"17 Event - Late Night - 00", 
"17 Event - Late Night - 01", 
"17 Event - Movie - 00", 
"17 Event - Movie - 01", 
"17 Event - Night - 00", 
"17 Event - Night - 01", 
"17 Event - Ramp Down - 00", 
"17 Event - Ramp Down - 01", 
"17 Event - Ramp Up - 00", 
"17 Event - Ramp Up - 01", 
"17 Event - Relax - 00", 
"17 Event - Relax - 01", 
"17 Event - Up Down - 00", 
"17 Event - Up Down - 01", 
"17 Event - Vacation - 00", 
"17 Event - Vacation - 01", 
"18 Media - 5.1 Speakers - 00", 
"18 Media - CD - 00", 
"18 Media - Ceiling Speaker - 00", 
"18 Media - Ceiling Speaker - 01", 
"18 Media - Chat - 00", 
"18 Media - Fax - 00", 
"18 Media - Game Pad - 00", 
"18 Media - Handset - 00.png", 
"18 Media - Hi Fi - 00", 
"18 Media - LCD Screen - 00", 
"18 Media - LCD TV - 00", 
"18 Media - LCD TV - 01", 
"18 Media - Mail - 00", 
"18 Media - Microphone - 00", 
"18 Media - Mobile - 00.png", 
"18 Media - Music Note - 00", 
"18 Media - PC - 00", 
"18 Media - Photo - 00.png", 
"18 Media - Projector - 00", 
"18 Media - Projector - 01", 
"18 Media - Projector Lift - 00", 
"18 Media - Projector Lift - 01", 
"18 Media - Projector Screen - 00", 
"18 Media - Projector Screen - 01", 
"18 Media - Radio - 00", 
"18 Media - Remote - 00", 
"18 Media - SMS - 00", 
"18 Media - Setup Box - 00", 
"18 Media - Speaker - 00", 
"18 Media - Speaker - 01", 
"18 Media - Telephone - 00", 
"18 Media - iPod - 00", 
"19 Blind - Blind - 00", 
"19 Blind - Blind - 01", 
"19 Blind - Blind - 02", 
"19 Blind - Blind - 03", 
"19 Blind - Blind - 04", 
"19 Blind - Blind - 05", 
"19 Blind - Blind - 06", 
"19 Blind - Blind - Down", 
"19 Blind - Blind - Stop", 
"19 Blind - Blind - Up", 
"19 Blind - Venitian Blind - 00", 
"19 Blind - Venitian Blind - 01", 
"Others - Admin - 00", 
"Others - Arab - 00", 
"Others - Boy - 00", 
"Others - Employee - 00", 
"Others - Info - 00", 
"Others - Pi Chart - 00", 
"Others - Question - 00", 
"Others - Receptionest - 00", 
"Others - Refresh - 00", 
"Others - Setting - 00", 
"Others - Windows - 00", 
"Others - Wireless - 00.png",
"Others - Young Arab - 00", 
"Others - e-Home - 00", 
"Others - e-Homegreen - 00", 
"Scene - All High - 00", 
"Scene - All High - 01", 
"Scene - All Low - 00", 
"Scene - All Low - 01", 
"Scene - All Medium - 00", 
"Scene - All Medium - 01", 
"Scene - All Off - 00", 
"Scene - All Off - 01", 
"Scene - All On - 00", 
"Scene - All On - 01", 
"Scene - Movie - 00", 
"Scene - Movie - 01"]
    
    var galleryImages:[AnyObject] = []
    var imageIndex:Int!
    var imagePicker = UIImagePickerController()
    var appDel:AppDelegate
    var images:[Image] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var changeLibrarySC: UISegmentedControl!
    var user:User?
    
    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backview: UIView!
    
    init(){
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        super.init(nibName: "SceneGalleryVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gallery.registerNib(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    
        images = returnImages()
        for item in galleryList {
            galleryImages.append(item)
        }

    }
    
    override func viewWillAppear(animated: Bool) {

        if let offset = defaults.valueForKey(UserDefaults.GalleryContentOffset) as? CGFloat  {
            self.gallery.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backview){
            return false
        }
        return true
    }
    
    func returnImages () -> [Image] {
        if let user = user{
            let fetchRequest = NSFetchRequest(entityName: "Image")
            let predicateArray:[NSPredicate] = [NSPredicate(format: "user == %@", user)]
            let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
            fetchRequest.predicate = compoundPredicate
            do {
                let fetchResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Image]
                return fetchResults!
            } catch let error as NSError {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return []
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        defaults.setValue(scrollView.contentOffset.y, forKey: UserDefaults.GalleryContentOffset)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        defaults.setValue(scrollView.contentOffset.y, forKey: UserDefaults.GalleryContentOffset)
    }
    
    func updateWithImage (image:UIImage) {
        let newImage = Image(context: appDel.managedObjectContext!)
        newImage.imageData = UIImageJPEGRepresentation(RBResizeImage(image, targetSize: CGSize(width: 150, height: 150)), 0.5)
        galleryImages.append(newImage)
        gallery.reloadData()
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    @IBAction func openGallery(sender: AnyObject) {
//        let libraryViewController = ALCameraViewController.imagePickerViewController(true) { [weak self] (image) -> Void in
//            if let backImage = image{
////                self?.updateWithImage(backImage)
//                self?.delegate?.backImageFromGallery!(UIImageJPEGRepresentation(self!.RBResizeImage(backImage, targetSize: CGSize(width: 200, height: 200)), 0.5)!, imageIndex: self!.imageIndex)
//                self?.dismissViewControllerAnimated(true, completion: { () -> Void in
//                    self?.dismissViewControllerAnimated(true, completion: nil)
//                })
//            }else{
//                self?.dismissViewControllerAnimated(true, completion:nil)
//            }
//        }
//        presentViewController(libraryViewController, animated: true, completion: nil)
    }
    
    @IBAction func changeGallery(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            galleryImages = []
            for item in galleryList {
                galleryImages.append(item)
            }
        }else{
            galleryImages = []
            images = returnImages()
            for item in images {
                galleryImages.append(item)
            }
        }
        gallery.reloadData()
    }
    
    @IBAction func closeGallery(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func takePhoto(sender: AnyObject) {
//        let cameraViewController = ALCameraViewController(croppingEnabled: true) { (image) -> Void in
//            if let backImage = image{
//                self.delegate?.backImageFromGallery!(UIImageJPEGRepresentation(self.RBResizeImage(backImage, targetSize: CGSize(width: 200, height: 200)), 0.5)!, imageIndex: self.imageIndex)
//                self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                    self.dismissViewControllerAnimated(true, completion: nil)
//                })
//            }else{
//                self.dismissViewControllerAnimated(true, completion:nil)
//            }
//        }
//        presentViewController(cameraViewController, animated: true, completion: nil)

    }
    
}

extension SceneGalleryVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = gallery.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! GalleryCollectionViewCell
        if let image = galleryImages[indexPath.row] as? Image {
            cell.cellImage.image = UIImage(data: image.imageData!)
        }
        if let string = galleryImages[indexPath.row] as? String {
            cell.cellImage.image = UIImage(named:string)
        }

        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 5        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let image = galleryImages[indexPath.row] as? Image {
            delegate?.backImage?(image, imageIndex: imageIndex)
            //            delegate?.backImageFromGallery?(image.imageData!, imageIndex: imageIndex)
        }
        if let string = galleryImages[indexPath.row] as? String {
            delegate?.backString?(string, imageIndex: imageIndex)
            //            delegate?.backImageFromGallery?(UIImageJPEGRepresentation(UIImage(named: string)!, 0.5)!, imageIndex: imageIndex)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func handleTap(gesture:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UIViewController {
    func showGallery(index:Int, user: User?) -> SceneGalleryVC {
        let galleryVC = SceneGalleryVC()
        galleryVC.imageIndex = index
        galleryVC.user = user
        self.presentViewController(galleryVC, animated: true, completion: nil)
        return galleryVC
    }
}

