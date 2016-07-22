//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit

enum ChoosedTab:String {
    case Devices = "Devices", Scenes = "Scenes", Events = "Events", Sequences = "Sequences", Timers = "Timers", Flags = "Flags"
    
    static let allItem:[ChoosedTab] = [Devices, Scenes, Events, Sequences, Timers, Flags]
}

class ScanViewController: PopoverVC, PullDownViewDelegate{
    
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
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanScenesViewController)) as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanDevicesViewController)) as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanSequencesesViewController)) as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanEventsViewController)) as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanTimerViewController)) as! ScanTimerViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanFlagViewController)) as! ScanFlagViewController
        
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
    
    override func viewWillLayoutSubviews() {
        var rect = self.pullDown.frame
        pullDown.removeFromSuperview()
        rect.size.width = self.view.frame.size.width
        rect.size.height = self.view.frame.size.height
        pullDown.frame = rect
        pullDown = PullDownView(frame: rect)
        pullDown.customDelegate = self
        self.view.addSubview(pullDown)
        pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)

        pullDown.drawMenu(filterParametar)
    }

    func pullDownSearchParametars(filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Database)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        toViewController.sendFilterParametar(filterItem)
        pullDown.drawMenu(filterParametar)
    }
    
    //popup controller
    @IBAction func btnScenes(sender: UIButton) {
        senderButton = sender
        var popoverList:[PopOverItem] = []
        for item in ChoosedTab.allItem{
            popoverList.append(PopOverItem(name: item.rawValue, id: ""))
        }
        openFilterPopover(sender, popOverList:popoverList)
    }
    
    override func nameAndId(name: String, id: String) {
        senderButton?.setTitle(name, forState: .Normal)
        if let to = ChoosedTab(rawValue: name){
            
            switch to {
            case .Devices:
                toViewController = scanDeviceViewController
            case .Scenes:
                toViewController = scanSceneViewController
            case .Events:
                toViewController = scanEventsViewController
            case .Sequences:
                toViewController = scanSequencesViewController
            case .Timers:
                toViewController = scanTimersViewController
            case .Flags:
                toViewController = scanFlagsViewController
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

}

class PopoverVC: UIViewController, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate{
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func openFilterPopover(sender: AnyObject, popOverList:[PopOverItem]) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 200
        popoverVC.popOverList = popOverList
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    func openParametarPopover(sender: AnyObject, indexTab:Int, location:Location?, device:Device){
        let mainStoryBoard = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle())
        popoverVC = mainStoryBoard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = indexTab
        popoverVC.device = device
        popoverVC.filterLocation = location
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func saveText(text: String, id: Int) {
        
    }
    
    func nameAndId(name : String, id:String){
        
    }
}