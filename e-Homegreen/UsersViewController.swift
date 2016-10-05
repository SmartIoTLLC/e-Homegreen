//
//  UsersViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class UsersViewController: PopoverVC {
    var timers:[Timer] = []
    var scrollView = FilterPullDown()
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Users)
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Users", subtitle: "All All All")
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimersViewController.refreshTimerList), name: NSNotification.Name(rawValue: NotificationKey.RefreshTimer), object: nil)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UsersViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.users)
        
        NotificationCenter.default.addObserver(self, selector: #selector(UsersViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerUsers), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
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
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        usersCollectionView.reloadData()
        
    }
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    override func viewWillDisappear(_ animated: Bool) {
        if let cells = self.usersCollectionView.visibleCells as? [TimerUserCell]{
            for cell in cells{
                cell.time?.invalidate()
            }
        }
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.users)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Users", subtitle: location + " " + level + " " + zone)
    }
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
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
            SendingHandler.sendCommand(byteArray: OutgoingHandler.refreshTimerStatus(address), gateway: timer.gateway)
            SendingHandler.sendCommand(byteArray: OutgoingHandler.refreshTimerStatusCountApp(address), gateway: timer.gateway)
        }
    }
    func refreshTimerList() {
        timers = DatabaseUserTimerController.shared.getTimers(filterParametar)
        usersCollectionView.reloadData()
    }
    func pressedPause (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEE), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    func pressedStart (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0x01), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    func pressedResume (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xED), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    func pressedCancel (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEF), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    func changeImageInCell(_ button:UIButton) {
        let pointInTable = button.convert(button.bounds.origin, to: usersCollectionView)
        let indexPath = usersCollectionView.indexPathForItem(at: pointInTable)
        if let cell = usersCollectionView.cellForItem(at: indexPath!) as? TimerUserCell {
            cell.commandSentChangeImage()
        }
    }
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.users)
    }
    
    @IBAction func refreshTimers(_ sender: UIButton) {
        refreshTimersStatus()
        sender.rotate(1)
    }
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
}

// Parametar from filter and relaod data
extension UsersViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Users)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.users)
        refreshTimerList()
        TimerForFilter.shared.counterUsers = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.users)
        TimerForFilter.shared.startTimer(type: Menu.users)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension UsersViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            usersCollectionView.isUserInteractionEnabled = true
        } else {
            usersCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            usersCollectionView.isUserInteractionEnabled = true
        } else {
            usersCollectionView.isUserInteractionEnabled = false
        }
    }
    
}

extension UsersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewCellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension UsersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timers.count
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: usersCollectionView)
            if let index = usersCollectionView.indexPathForItem(at: location){
                let cell = usersCollectionView.cellForItem(at: index)
                showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - usersCollectionView.contentOffset.y), timer: timers[tag])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usersCell", for: indexPath) as! TimerUserCell
        
        cell.setItem(timers[(indexPath as NSIndexPath).row], filterParametar:filterParametar)

        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(UsersViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.titleLabel.isUserInteractionEnabled = true
        cell.titleLabel.addGestureRecognizer(longPress)

        cell.getImagesFrom(timers[(indexPath as NSIndexPath).row])
        
        
            //   ===   Default   ===
            cell.playButton.isHidden = false
            cell.pauseButton.isHidden = true
            cell.stopButton.isHidden = true
            cell.playButton.isEnabled = true
            cell.playButton.setTitle("Start", for: UIControlState())
            cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), for: UIControlEvents.touchUpInside)
            
            if timers[(indexPath as NSIndexPath).row].timerState == 1 {
                cell.playButton.isHidden = true
                cell.stopButton.isHidden = false
                cell.pauseButton.isHidden = false
                cell.startTimer()
                cell.pauseButton.setTitle("Pause", for: UIControlState())
                cell.stopButton.setTitle("Cancel", for: UIControlState())
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), for: UIControlEvents.touchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), for: UIControlEvents.touchUpInside)
            }
            if timers[(indexPath as NSIndexPath).row].timerState == 240 {
                cell.playButton.isHidden = false
                cell.pauseButton.isHidden = true
                cell.stopButton.isHidden = true
                cell.stopTimer()
                cell.playButton.isEnabled = true
                cell.playButton.setTitle("Start", for: UIControlState())
                cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), for: UIControlEvents.touchUpInside)
            }
            if timers[(indexPath as NSIndexPath).row].timerState == 238 {
                cell.playButton.isHidden = true
                cell.stopButton.isHidden = false
                cell.pauseButton.isHidden = false
                cell.stopTimer()
                cell.pauseButton.setTitle("Resume", for: UIControlState())
                cell.stopButton.setTitle("Cancel", for: UIControlState())
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), for: UIControlEvents.touchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), for: UIControlEvents.touchUpInside)
            }
        

        cell.playButton.tag = (indexPath as NSIndexPath).row
        cell.pauseButton.tag = (indexPath as NSIndexPath).row
        cell.stopButton.tag = (indexPath as NSIndexPath).row


        return cell
    }
}



