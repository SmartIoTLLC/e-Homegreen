//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit

    enum ChoosedTab {
        case Devices, Scenes, Events, Sequences
        func returnStringDescription() -> String {
            switch self {
            case .Devices:
                return ""
            case .Scenes:
                return "Scene"
            case .Events:
                return "Event"
            case .Sequences:
                return "Sequence"
            }
        }
    }

class ScanViewController: UIViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, PullDownViewDelegate{
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var container: UIView!
    
    var scanSceneViewController: ScanScenesViewController!
    var scanDeviceViewController: ScanDevicesViewController!
    var scanSequencesViewController: ScanSequencesesViewController!
    var scanEventsViewController: ScanEventsViewController!
    var scanTimersViewController: ScanTimerViewController!
    var scanFlagsViewController: ScanFlagViewController!
    
    var pullDown = PullDownView()
    
    var toViewController:UIViewController = UIViewController()

    var senderButton:UIButton?
    
    var isPresenting:Bool = true
    var gateway:Gateway?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier("ScanScenes") as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier("ScanDevices") as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewControllerWithIdentifier("ScanSequences") as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanEvents") as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewControllerWithIdentifier("ScanTimers") as! ScanTimerViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanFlags") as! ScanFlagViewController
        
        toViewController = scanDeviceViewController
        
        scanSceneViewController.gateway = gateway
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanEventsViewController.gateway = gateway
        scanTimersViewController.gateway = gateway
        scanFlagsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMoveToParentViewController(self)
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)

    }
    //FIXME: Radi i sada ali mozda da se promeni na toViewController.sendFilterParametar(filterItem)
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)
    
    func pullDownSearchParametars(filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Database)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        toViewController.sendFilterParametar(filterItem)
        pullDown.drawMenu(filterParametar)
    }
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            
        } else {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
        }
        pullDown.drawMenu(filterParametar)
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
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
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
    
    func saveText(text: String, id: Int) {
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

}