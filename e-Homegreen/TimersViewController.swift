//
//  TimersViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class TimersViewController: PopoverVC, PullDownViewDelegate {
    
    var timers:[Timer] = []
    
    var scrollView = FilterPullDown()
    
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
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
        refreshTimersStatus()
        changeFullScreeenImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimersViewController.refreshTimerList), name: NotificationKey.RefreshTimer, object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        if let cells = self.timersCollectionView.visibleCells() as? [TimerCollectionViewCell]{
            for cell in cells{
                cell.time?.invalidate()
            }
        }        
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
        timersCollectionView.reloadData()
        
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
    
//    override func viewWillLayoutSubviews() {
//        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            var rect = self.pullDown.frame
//            pullDown.removeFromSuperview()
//            rect.size.width = self.view.frame.size.width
//            rect.size.height = self.view.frame.size.height
//            pullDown.frame = rect
//            pullDown = PullDownView(frame: rect)
//            pullDown.customDelegate = self
//            self.view.addSubview(pullDown)
//            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
//            
//        } else {
//            var rect = self.pullDown.frame
//            pullDown.removeFromSuperview()
//            rect.size.width = self.view.frame.size.width
//            rect.size.height = self.view.frame.size.height
//            pullDown.frame = rect
//            pullDown = PullDownView(frame: rect)
//            pullDown.customDelegate = self
//            self.view.addSubview(pullDown)
//            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
//        }
//        var size:CGSize = CGSize()
//        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
//        collectionViewCellSize = size
//        timersCollectionView.reloadData()
//        pullDown.drawMenu(filterParametar)
//    }
    
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
    
    @IBAction func refreshTimers(sender: UIButton) {
        refreshTimersStatus()
        sender.rotate(1)
    }
    
    func refreshTimersStatus(){
        for timer in timers{
            var address:[UInt8] = []
            if timer.isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if timer.isLocalcast.boolValue {
                address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(timer.gateway.addressOne)), UInt8(Int(timer.gateway.addressTwo)), UInt8(Int(timer.address))]
            }
            SendingHandler.sendCommand(byteArray: Function.refreshTimerStatus(address), gateway: timer.gateway)
            SendingHandler.sendCommand(byteArray: Function.refreshTimerStatusCountApp(address), gateway: timer.gateway)
        }
    }
    
    
//    func pullDownSearchParametars (filterItem:FilterItem) {
//        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Timers)
//        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
//        refreshTimerList()
//    }
    
    func refreshTimerList() {
        timers = DatabaseTimersController.shared.getTimers(filterParametar)
        timersCollectionView.reloadData()
    }
    
    //cell action
    
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

}

// Parametar from filter and relaod data
extension TimersViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Timers)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        refreshTimerList()
    }
}

extension TimersViewController: SWRevealViewControllerDelegate{
    
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
}

extension TimersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
        
        cell.setItem(timers[indexPath.row], filterParametar: filterParametar)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TimersViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.timerTitle.userInteractionEnabled = true
        cell.timerTitle.addGestureRecognizer(longPress)
        
        cell.getImagesFrom(timers[indexPath.row])
        
        cell.timerButton.tag = indexPath.row
        cell.timerButtonLeft.tag = indexPath.row
        cell.timerButtonRight.tag = indexPath.row
        if timers[indexPath.row].type == "Timer" || timers[indexPath.row].type == "Stopwatch/User" {
            //   ===   Default   ===
            cell.timerButton.hidden = false
            cell.timerButtonLeft.hidden = true
            cell.timerButtonRight.hidden = true
            cell.timerButton.enabled = true
            cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
            cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)

            if timers[indexPath.row].timerState == 1 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.startTimer()
                cell.timerButtonRight.setTitle("Pause", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.stopTimer()
                cell.timerButton.enabled = true
                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 238 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.stopTimer()
                cell.timerButtonRight.setTitle("Resume", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            cell.timerCOuntingLabel.text = ""
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
        
        return cell
    }
}

