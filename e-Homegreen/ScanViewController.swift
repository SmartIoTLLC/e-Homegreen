//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit

enum ChoosedTab:String {
    case Devices = "Devices", Scenes = "Scenes", Events = "Events", Sequences = "Sequences", Timers = "Timers", Flags = "Flags", Cards = "Cards"
    
    static let allItem:[ChoosedTab] = [Devices, Scenes, Events, Sequences, Timers, Flags, Cards]
}

class ScanViewController: PopoverVC {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var senderButton:UIButton!
    
    var scanSceneViewController: ScanScenesViewController!
    var scanDeviceViewController: ScanDevicesViewController!
    var scanSequencesViewController: ScanSequencesesViewController!
    var scanEventsViewController: ScanEventsViewController!
    var scanTimersViewController: ScanTimerViewController!
    var scanFlagsViewController: ScanFlagViewController!
    var scanCardsViewController: ScanCardsViewController!
    
    var scrollView = ScanFilterPullDown()
    
    
    var toViewController:UIViewController = UIViewController()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    var isPresenting:Bool = true
    var gateway:Gateway!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.scanFilterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view, location: gateway.location)
        scrollView.hidden = true

        searchBar.barTintColor = UIColor.clearColor()
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = UIColor.lightGrayColor()
        searchBar.returnKeyType = .Done
        searchBar.delegate = self
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanScenesViewController)) as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanDevicesViewController)) as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanSequencesesViewController)) as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanEventsViewController)) as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanTimerViewController)) as! ScanTimerViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanFlagViewController)) as! ScanFlagViewController
        scanCardsViewController = storyboard.instantiateViewControllerWithIdentifier(String(ScanCardsViewController)) as! ScanCardsViewController
        
        toViewController = scanDeviceViewController
        
        scanSceneViewController.gateway = gateway
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanEventsViewController.gateway = gateway
        scanTimersViewController.gateway = gateway
        scanFlagsViewController.gateway = gateway
        scanCardsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMoveToParentViewController(self)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Scan", subtitle: gateway.location.name! + ", All, All")

    }
    
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        scrollView.hidden = false
    }
    
    override func viewDidLayoutSubviews() {
        if scrollView.contentOffset.y > 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Scan", subtitle: location + ", " + level + ", " + zone)
    }
    
    //popup controller
    @IBAction func btnScenes(sender: UIButton) {
        senderButton = sender
        var popoverList:[PopOverItem] = []
        for item in ChoosedTab.allItem{
            popoverList.append(PopOverItem(name: item.rawValue, id: ""))
        }
        openPopover(sender, popOverList:popoverList)
    }
    
    override func nameAndId(name: String, id: String) {
        
        if let to = ChoosedTab(rawValue: name){
            searchBar.text = ""
            senderButton.setTitle(name, forState: .Normal)
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
            case .Cards:
                toViewController = scanCardsViewController
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
        }else{
            scrollView.setButtonTitle(name, id: id)
        }
    }

}

extension ScanViewController: ScanFilterPullDownDelegate{
    func scanFilterParametars(filterItem: FilterItem) {
        toViewController.sendFilterParametar(filterItem)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
    }

}

extension ScanViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true  // show cancel buttton when search bar being active
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false // hide cancel buttton when search bar being inactive
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        toViewController.sendSearchBarText(searchText)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}

class PopoverVC: UIViewController, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate{
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func openPopover(sender: AnyObject, popOverList:[PopOverItem]) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
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
    
    func openPopoverWithTwoRows(sender: AnyObject, popOverList:[PopOverItem]) {
        let storyboard = UIStoryboard(name: "Popover", bundle: nil)
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.popOverList = popOverList
        popoverVC.cellWithTwoTextRows = true
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
    
    func nameAndId(name : String, id:String){
        
    }
}