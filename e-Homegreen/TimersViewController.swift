//
//  TimersViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class TimersViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
        
    var appDel:AppDelegate!
    var timers:[Timer] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    var senderButton:UIButton?
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "TimerCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var timersCollectionView: UICollectionView!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Timers)
    
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
        refreshTimerList()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
    }
    
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Timers)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        refreshTimerList()
    }
    
    func refreshTimerList() {
        timers = DatabaseTimersController.shared.getTimers(filterParametar)
        timersCollectionView.reloadData()
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
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        timersCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func pressedPause (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEE), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedStart (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0x01), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedResume (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xED), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedCancel (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEF), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func changeImageInCell(button:UIButton) {
        let pointInTable = button.convertPoint(button.bounds.origin, toView: timersCollectionView)
        let indexPath = timersCollectionView.indexPathForItemAtPoint(pointInTable)
        if let cell = timersCollectionView.cellForItemAtIndexPath(indexPath!) as? TimerCollectionViewCell {
            cell.commandSentChangeImage()
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            timersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            timersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            timersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(TimersViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            timersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
    }
        
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }

}

extension TimersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension TimersViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timers.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(timersCollectionView)
            if let index = timersCollectionView.indexPathForItemAtPoint(location){
                let cell = timersCollectionView.cellForItemAtIndexPath(index)
                showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - timersCollectionView.contentOffset.y), timer: timers[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TimerCollectionViewCell
        
        var timerLevel = ""
        var timerZone = ""
        let timerLocation = timers[indexPath.row].gateway.name
        
        if let level = timers[indexPath.row].entityLevel{
            timerLevel = level
        }
        if let zone = timers[indexPath.row].timeZone{
            timerZone = zone
        }
        
        if filterParametar.location == "All" {
            cell.timerTitle.text = timerLocation + " " + timerLevel + " " + timerZone + " " + timers[indexPath.row].timerName
        }else{
            var timerTitle = ""
            if filterParametar.levelName == "All"{
                timerTitle += " " + timerLevel
            }
            if filterParametar.zoneName == "All"{
                timerTitle += " " + timerZone
            }
            timerTitle += " " + timers[indexPath.row].timerName
            cell.timerTitle.text = timerTitle
        }
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TimersViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.timerTitle.userInteractionEnabled = true
        cell.timerTitle.addGestureRecognizer(longPress)
        
        cell.getImagesFrom(timers[indexPath.row])
        
        cell.timerButton.tag = indexPath.row
        cell.timerButtonLeft.tag = indexPath.row
        cell.timerButtonRight.tag = indexPath.row
        if timers[indexPath.row].type == "Countdown" {
            //   ===   Default   ===
            cell.timerButton.hidden = false
            cell.timerButtonLeft.hidden = true
            cell.timerButtonRight.hidden = true
            cell.timerButton.enabled = true
            cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
            cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            //   ===================
            if timers[indexPath.row].timerState == 1 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Pause", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.enabled = true
                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 238 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Resume", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
//                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = false
            } else {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = true
            }
        }
        
        // cancel start pause resume
        cell.timerImageView.layer.cornerRadius = 5
        cell.timerImageView.clipsToBounds = true
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}

