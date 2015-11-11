//
//  SceneGalleryVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc protocol SceneGalleryDelegate{
    optional func backString(strText: String, imageIndex:Int)
    optional func backImageFromGallery(data:NSData, imageIndex:Int)
}

class SceneGalleryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var imageIndex:Int!
    
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!

    var imagePicker = UIImagePickerController()
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var gallery: UICollectionView!
    
    @IBOutlet weak var backview: UIView!
    
    init(){
        super.init(nibName: "SceneGalleryVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(gallery){
            return false
        }
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        self.gallery.registerNib(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func openGallery(sender: AnyObject) {
        
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
//        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        delegate?.backImageFromGallery!(UIImageJPEGRepresentation(RBResizeImage(image, targetSize: CGSize(width: 150, height: 150))!, 0.5)!, imageIndex: imageIndex)
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func RBResizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
            } else {
                newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            return nil
        }
    }

    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeight.constant = 300
                
            }else if self.view.frame.size.height == 375{
                backViewHeight.constant = 340
            }else if self.view.frame.size.height == 414{
                backViewHeight.constant = 390
            }else{
                backViewHeight.constant = 420
            }
        }else{
            
            self.backViewHeight.constant = 400
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return galleryList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = gallery.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! GalleryCollectionViewCell
        
        cell.cellImage.image = UIImage(named: galleryList[indexPath.row])
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.backString!(galleryList[indexPath.row], imageIndex: imageIndex)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension SceneGalleryVC : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
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
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension SceneGalleryVC :  UIViewControllerTransitioningDelegate{
    
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
    func showGallery(index:Int) -> SceneGalleryVC {
        let galleryVC = SceneGalleryVC()
        galleryVC.imageIndex = index
        self.presentViewController(galleryVC, animated: true, completion: nil)
        return galleryVC
    }
}

