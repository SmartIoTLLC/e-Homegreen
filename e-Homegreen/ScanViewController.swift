//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit
import CoreData

class ScanViewController: UIViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var container: UIView!
    
    var scanSceneViewController: ScanScenesViewController!
    var scanDeviceViewController: ScanDevicesViewController!
    var scanSequencesViewController: ScanSequencesesViewController!
    var scanEventsViewController: ScanEventsViewController!
    var scanTimersViewController: ScanTimerViewController!
    var importZoneViewController:ImportZoneViewController!
    var importCategoryViewController: ImportCategoryViewController!
    var scanFlagsViewController: ScanFlagViewController!
    
    
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
        importZoneViewController = storyboard.instantiateViewControllerWithIdentifier("ImportZone") as! ImportZoneViewController
        importCategoryViewController = storyboard.instantiateViewControllerWithIdentifier("ImportCategory") as! ImportCategoryViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanFlags") as! ScanFlagViewController
        
        scanSceneViewController.gateway = gateway
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanEventsViewController.gateway = gateway
        scanTimersViewController.gateway = gateway
        importZoneViewController.gateway = gateway
        importCategoryViewController.gateway = gateway
        scanFlagsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
    }
    
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
        var toViewController:UIViewController = UIViewController()
        switch text {
        case "Devices":
            toViewController = scanDeviceViewController
        case "Scenes":
            toViewController = scanSceneViewController
        case "Events":
            toViewController = scanEventsViewController
        case "Sequences":
            toViewController = scanSequencesViewController
        case "Zones":
            toViewController = importZoneViewController
        case "Categories":
            toViewController = importCategoryViewController
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
                toViewController.didMoveToParentViewController(self)
                toViewController.view.frame = self.container.bounds
            })
        } else {
            childViewControllers.last!.viewWillAppear(true)
            childViewControllers.last!.viewDidAppear(true)
        }
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
}