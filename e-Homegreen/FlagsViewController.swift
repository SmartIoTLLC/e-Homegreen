//
//  FlagsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class FlagsViewController: PopoverVC {
    
    var flags:[Flag] = []
    var sidebarMenuOpen : Bool!
    
    var scrollView = FilterPullDown()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "FlagCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var flagsCollectionView: UICollectionView!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Flags)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()        
        scrollView.setItem(self.view)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        reloadFlagsList()
        changeFullScreeenImage()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        flagsCollectionView.reloadData()
        
    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }

    func reloadFlagsList(){
        flags = DatabaseFlagsController.shared.getFlags(filterParametar)
        flagsCollectionView.reloadData()
    }
    
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
//        pullDown.drawMenu(filterParametar)
//        updateFlagsList()
        flagsCollectionView.reloadData()
    }


}

extension FlagsViewController: SWRevealViewControllerDelegate {
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            flagsCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            flagsCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            flagsCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(FlagsViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            flagsCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
}

// Parametar from filter and relaod data
extension FlagsViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Flags)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
        reloadFlagsList()
    }
}

extension FlagsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let flagId = flags[indexPath.row].flagId as? Int {
            var address:[UInt8] = []
            if flags[indexPath.row].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if flags[indexPath.row].isLocalcast.boolValue {
                address = [UInt8(Int(flags[indexPath.row].gateway.addressOne)), UInt8(Int(flags[indexPath.row].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(flags[indexPath.row].gateway.addressOne)), UInt8(Int(flags[indexPath.row].gateway.addressTwo)), UInt8(Int(flags[indexPath.row].address))]
            }
            if flags[indexPath.row].setState.boolValue {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[indexPath.row].gateway)
            } else {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[indexPath.row].gateway)
            }
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}

extension FlagsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flags.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(flagsCollectionView)
            if let index = flagsCollectionView.indexPathForItemAtPoint(location){
                let cell = flagsCollectionView.cellForItemAtIndexPath(index)
                showFlagParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - flagsCollectionView.contentOffset.y), flag: flags[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlagCollectionViewCell
        
        var flagLevel = ""
        var flagZone = ""
        let flagLocation = flags[indexPath.row].gateway.location.name!
        
        if let level = flags[indexPath.row].entityLevel{
            flagLevel = level
        }
        if let zone = flags[indexPath.row].flagZone{
            flagZone = zone
        }
        
        if filterParametar.location == "All" {
            cell.flagTitle.text = flagLocation + " " + flagLevel + " " + flagZone + " " + flags[indexPath.row].flagName
        }else{
            var flagTitle = ""
            if filterParametar.levelName == "All"{
                flagTitle += " " + flagLevel
            }
            if filterParametar.zoneName == "All"{
                flagTitle += " " + flagZone
            }
            flagTitle += " " + flags[indexPath.row].flagName
            cell.flagTitle.text = flagTitle
        }
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FlagsViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.flagTitle.userInteractionEnabled = true
        cell.flagTitle.addGestureRecognizer(longPress)
        
        cell.getImagesFrom(flags[indexPath.row])
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlagsViewController.setFlag(_:)))
        cell.flagImageView.tag = indexPath.row
        cell.flagImageView.userInteractionEnabled = true
        cell.flagImageView.addGestureRecognizer(set)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlagsViewController.buttonPressed(_:)))
        cell.flagButton.tag = indexPath.row
        cell.flagButton.addGestureRecognizer(tap)
        if flags[indexPath.row].setState.boolValue {
            cell.flagButton.setTitle("Set False", forState: UIControlState.Normal)
        } else {
            cell.flagButton.setTitle("Set True", forState: UIControlState.Normal)
        }
        
        cell.flagImageView.layer.cornerRadius = 5
        cell.flagImageView.clipsToBounds = true
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func setFlag (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            if let flagId = flags[tag].flagId as? Int {
                var address:[UInt8] = []
                if flags[tag].isBroadcast.boolValue {
                    address = [0xFF, 0xFF, 0xFF]
                } else if flags[tag].isLocalcast.boolValue {
                    address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), 0xFF]
                } else {
                    address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), UInt8(Int(flags[tag].address))]
                }
                if flags[tag].setState.boolValue {
                    SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
                } else {
                    SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
                }
            }
        }
    }
    
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let flagId = Int(flags[tag].flagId)
        var address:[UInt8] = []
        if flags[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), UInt8(Int(flags[tag].address))]
        }
        if flags[tag].setState.boolValue {
            SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
        }
    }
}

