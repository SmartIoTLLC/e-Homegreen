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
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var isPresenting:Bool = true
    var gateway:Gateway!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Database)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.scanFilterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view, location: gateway.location)
        scrollView.isHidden = true

        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = UIColor.lightGray
        searchBar.returnKeyType = .done
        searchBar.delegate = self
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewController(withIdentifier: "ScanScenesViewController") as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewController(withIdentifier: "ScanDevicesViewController") as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewController(withIdentifier: "ScanSequencesesViewController") as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewController(withIdentifier: "ScanEventsViewController") as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewController(withIdentifier: "ScanTimerViewController") as! ScanTimerViewController
        scanFlagsViewController = storyboard.instantiateViewController(withIdentifier: "ScanFlagViewController") as! ScanFlagViewController
        scanCardsViewController = storyboard.instantiateViewController(withIdentifier: "ScanCardsViewController") as! ScanCardsViewController
        
        toViewController = scanDeviceViewController
        
        scanSceneViewController.gateway = gateway
        scanSceneViewController.filterParametar = filterParametar
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanSequencesViewController.filterParametar = filterParametar
        scanEventsViewController.gateway = gateway
        scanEventsViewController.filterParametar = filterParametar
        scanTimersViewController.gateway = gateway
        scanTimersViewController.filterParametar = filterParametar
        scanFlagsViewController.gateway = gateway
        scanFlagsViewController.filterParametar = filterParametar
        scanCardsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRect(x: 0, y: 0, width: self.container.frame.size.width, height: self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMove(toParentViewController: self)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Database)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Scan", subtitle: gateway.location.name! + " All All")

    }
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        scrollView.isHidden = false
    }
    override func viewDidLayoutSubviews() {
        if scrollView.contentOffset.y > 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        
    }
    override func nameAndId(_ name: String, id: String) {
        
        if let to = ChoosedTab(rawValue: name){
            searchBar.text = ""
            senderButton.setTitle(name, for: UIControlState())
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
                self.transition(from: fromViewController, to: toViewController, duration: 0.0, options: UIViewAnimationOptions.transitionFlipFromRight, animations: nil, completion: {finished in
                    fromViewController.removeFromParentViewController()
                    self.toViewController.didMove(toParentViewController: self)
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
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Scan", subtitle: location + " " + level + " " + zone)
    }
    
    //popup controller
    @IBAction func btnScenes(_ sender: UIButton) {
        senderButton = sender
        var popoverList:[PopOverItem] = []
        for item in ChoosedTab.allItem{
            popoverList.append(PopOverItem(name: item.rawValue, id: ""))
        }
        openPopover(sender, popOverList:popoverList)
    }
}

extension ScanViewController: ScanFilterPullDownDelegate{
    func scanFilterParametars(_ filterItem: FilterItem) {
        toViewController.sendFilterParametar(filterItem)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
    }
}

extension ScanViewController: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true  // show cancel buttton when search bar being active
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false // hide cancel buttton when search bar being inactive
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        toViewController.sendSearchBarText(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}
