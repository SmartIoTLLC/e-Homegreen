//
//  UsersViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class UsersViewController: PopoverVC {
    
    var timers:[Timer] = []
    
    var scrollView = FilterPullDown()

    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Users)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Users", subtitle: "All, All, All")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimersViewController.refreshTimerList), name: NotificationKey.RefreshTimer, object: nil)
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
        refreshTimerList()
        refreshTimersStatus()
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
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        usersCollectionView.reloadData()
        
    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Users", subtitle: location + ", " + level + ", " + zone)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let cells = self.usersCollectionView.visibleCells() as? [TimerUserCell]{
            for cell in cells{
                cell.time?.invalidate()
            }
        }
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
    
    func refreshTimerList() {
        timers = DatabaseUserTimerController.shared.getTimers(filterParametar)
        usersCollectionView.reloadData()
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
        let pointInTable = button.convertPoint(button.bounds.origin, toView: usersCollectionView)
        let indexPath = usersCollectionView.indexPathForItemAtPoint(pointInTable)
        if let cell = usersCollectionView.cellForItemAtIndexPath(indexPath!) as? TimerUserCell {
            cell.commandSentChangeImage()
        }
    }

}

// Parametar from filter and relaod data
extension UsersViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Users)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        refreshTimerList()
    }
}

extension UsersViewController: SWRevealViewControllerDelegate{
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            usersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            usersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            usersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UsersViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            usersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
}

extension UsersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

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

extension UsersViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timers.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(usersCollectionView)
            if let index = usersCollectionView.indexPathForItemAtPoint(location){
                let cell = usersCollectionView.cellForItemAtIndexPath(index)
                showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - usersCollectionView.contentOffset.y), timer: timers[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("usersCell", forIndexPath: indexPath) as! TimerUserCell
        
        cell.setItem(timers[indexPath.row], filterParametar:filterParametar)

        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UsersViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.titleLabel.userInteractionEnabled = true
        cell.titleLabel.addGestureRecognizer(longPress)

        cell.getImagesFrom(timers[indexPath.row])
        
        
            //   ===   Default   ===
            cell.playButton.hidden = false
            cell.pauseButton.hidden = true
            cell.stopButton.hidden = true
            cell.playButton.enabled = true
            cell.playButton.setTitle("Start", forState: UIControlState.Normal)
            cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if timers[indexPath.row].timerState == 1 {
                cell.playButton.hidden = true
                cell.stopButton.hidden = false
                cell.pauseButton.hidden = false
                cell.startTimer()
                cell.pauseButton.setTitle("Pause", forState: UIControlState.Normal)
                cell.stopButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 240 {
                cell.playButton.hidden = false
                cell.pauseButton.hidden = true
                cell.stopButton.hidden = true
                cell.stopTimer()
                cell.playButton.enabled = true
                cell.playButton.setTitle("Start", forState: UIControlState.Normal)
                cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 238 {
                cell.playButton.hidden = true
                cell.stopButton.hidden = false
                cell.pauseButton.hidden = false
                cell.stopTimer()
                cell.pauseButton.setTitle("Resume", forState: UIControlState.Normal)
                cell.stopButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        

        cell.playButton.tag = indexPath.row
        cell.pauseButton.tag = indexPath.row
        cell.stopButton.tag = indexPath.row


        return cell
    }
}



