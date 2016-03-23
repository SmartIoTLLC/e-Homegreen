//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit
import CoreData

class ScanViewController: UIViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, PullDownViewDelegate{
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var container: UIView!
    
    var scanSceneViewController: ScanScenesViewController!
    var scanDeviceViewController: ScanDevicesViewController!
    var scanSequencesViewController: ScanSequencesesViewController!
    var scanEventsViewController: ScanEventsViewController!
    var scanTimersViewController: ScanTimerViewController!
//    var importZoneViewController:ImportZoneViewController!
//    var importCategoryViewController: ImportCategoryViewController!
    var scanFlagsViewController: ScanFlagViewController!
    
    var pullDown = PullDownView()
    
    var toViewController:UIViewController = UIViewController()
    
//    var appDel:AppDelegate!
//    var error:NSError? = nil
//    var choosedTab:ChoosedTab = .Devices
    var senderButton:UIButton?
    
//    enum ChoosedTab {
//        case Devices, Scenes, Events, Sequences, Zones, Categories
//        func returnStringDescription() -> String {
//            switch self {
//            case .Devices:
//                return ""
//            case .Scenes:
//                return "Scene"
//            case .Events:
//                return "Event"
//            case .Sequences:
//                return "Sequence"
//            case .Zones:
//                return "Zones"
//            case .Categories:
//                return "Categories"
//            }
//        }
//    }
    
    var isPresenting:Bool = true
    var gateway:Gateway?

    override func viewDidLoad() {
        super.viewDidLoad()
//        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier("ScanScenes") as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier("ScanDevices") as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewControllerWithIdentifier("ScanSequences") as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanEvents") as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewControllerWithIdentifier("ScanTimers") as! ScanTimerViewController
//        importZoneViewController = storyboard.instantiateViewControllerWithIdentifier("ImportZone") as! ImportZoneViewController
//        importCategoryViewController = storyboard.instantiateViewControllerWithIdentifier("ImportCategory") as! ImportCategoryViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanFlags") as! ScanFlagViewController
        
        toViewController = scanDeviceViewController
        
        scanSceneViewController.gateway = gateway
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanEventsViewController.gateway = gateway
        scanTimersViewController.gateway = gateway
//        importZoneViewController.gateway = gateway
//        importCategoryViewController.gateway = gateway
        scanFlagsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMoveToParentViewController(self)
        
        pullDown = PullDownView(frame: CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        
//        let swipeDismiss = UISwipeGestureRecognizer(target: self, action: "userSwiped:")
//        swipeDismiss.direction = UISwipeGestureRecognizerDirection.Right
//        self.view.addGestureRecognizer(swipeDismiss)
        // Do any additional setup after loading the view.
    }
    //FIXME: Radi i sada ali mozda da se promeni na toViewController.sendFilterParametar(filterItem)
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)
    func pullDownSearchParametars(filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Database)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        toViewController.sendFilterParametar(filterParametar.location, level: "\(filterParametar.levelId)", zone: "\(filterParametar.zoneId)", category: "\(filterParametar.categoryId)", levelName: filterParametar.levelName, zoneName: filterParametar.zoneName, categoryName: filterParametar.categoryName)
//        toViewController.sendFilterParametar(filterItem)
        pullDown.drawMenu(filterParametar)
    }
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            //            if self.view.frame.size.width == 568{
            //                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            //            }else if self.view.frame.size.width == 667{
            //                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            //            }else{
            //                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            //            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.origin.y = 44
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height - 44
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            
        } else {
            //            if self.view.frame.size.width == 320{
            //                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            //            }else if self.view.frame.size.width == 375{
            //                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            //            }else{
            //                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            //            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.origin.y = 64
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height - 64
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
        }
        pullDown.drawMenu(filterParametar)
    }

    
//    func userSwiped (gesture:UISwipeGestureRecognizer) {
////        self.performSegueWithIdentifier("scanUnwind", sender: self)
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        self.performSegueWithIdentifier("scanUnwind", sender: self)
    }
    var popoverVC:PopOverViewController = PopOverViewController()
    
    @IBAction func btnScenes(sender: AnyObject) {
        senderButton = sender as? UIButton
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 6
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
//    if let menuItem = sender as? MenuItem {

//    }
    
    func saveText(text: String, id: Int) {
        print(Array(text.characters.reverse()))
        senderButton?.setTitle(text, forState: .Normal)
        
        switch text {
        case "Devices":
            toViewController = scanDeviceViewController
        case "Scenes":
            toViewController = scanSceneViewController
        case "Events":
            toViewController = scanEventsViewController
        case "Sequences":
            toViewController = scanSequencesViewController
//        case "Zones":
//            toViewController = importZoneViewController
//        case "Categories":
//            toViewController = importCategoryViewController
        case "Timers":
            toViewController = scanTimersViewController
        case "Flag":
            toViewController = scanFlagsViewController
        default: break
        }
        let fromViewController = childViewControllers.last!
        if toViewController != fromViewController {
            self.addChildViewController(toViewController)
            self.transitionFromViewController(fromViewController, toViewController: toViewController, duration: 0.0, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: nil, completion: {finished in
                fromViewController.removeFromParentViewController()
                self.toViewController.didMoveToParentViewController(self)
                self.toViewController.view.frame = self.container.bounds
            })
        } else {
            childViewControllers.last!.viewWillAppear(true)
            childViewControllers.last!.viewDidAppear(true)
        }
    }
    
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
}