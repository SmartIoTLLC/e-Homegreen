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
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimersViewController.refreshTimerList), name: NSNotification.Name(rawValue: NotificationKey.RefreshTimer), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerUsers), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Users", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.users)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        usersCollectionView.isUserInteractionEnabled = true
        
        refreshTimerList()
        refreshTimersStatus()
        changeFullscreenImage(fullscreenButton: fullScreenButton)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { usersCollectionView.reloadData() })
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let cells = self.usersCollectionView.visibleCells as? [TimerUserCell]{
            for cell in cells { cell.time?.invalidate() }
        }
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.users)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func refreshTimersStatus(){
        for timer in timers{
            var address:[UInt8] = []
            if timer.isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if timer.isLocalcast.boolValue {
                address = [getByte(timer.gateway.addressOne), getByte(timer.gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(timer.gateway.addressOne), getByte(timer.gateway.addressTwo), getByte(timer.address)]
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
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), getByte(timers[tag].address)]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: getByte(timers[tag].timerId), command: 0xEE), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedStart (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), getByte(timers[tag].address)]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: getByte(timers[tag].timerId), command: 0x01), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedResume (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), getByte(timers[tag].address)]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: getByte(timers[tag].timerId), command: 0xED), gateway: timers[tag].gateway)
        changeImageInCell(button)
    }
    
    func pressedCancel (_ button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timers[tag].isLocalcast.boolValue {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(timers[tag].gateway.addressOne), getByte(timers[tag].gateway.addressTwo), getByte(timers[tag].address)]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: getByte(timers[tag].timerId), command: 0xEF), gateway: timers[tag].gateway)
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
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
}

// Parametar from filter and relaod data
extension UsersViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Users)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        updateSubtitle(headerTitleSubtitleView, title: "Users", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
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
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        if position == .left { usersCollectionView.isUserInteractionEnabled = true } else { usersCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == .left { usersCollectionView.isUserInteractionEnabled = true } else { usersCollectionView.isUserInteractionEnabled = false }
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usersCell", for: indexPath) as? TimerUserCell {
            
            cell.setItem(timers[indexPath.row], filterParametar:filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.titleLabel.addGestureRecognizer(longPress)
                        
            //   ===   Default   ===
            cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), for: .touchUpInside)
            
            if timers[indexPath.row].timerState == 1 {
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), for: .touchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), for: .touchUpInside)
            }
            
            if timers[indexPath.row].timerState == 240 {
                cell.playButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), for: .touchUpInside)
            }
            
            if timers[indexPath.row].timerState == 238 {
                cell.pauseButton.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), for: .touchUpInside)
                cell.stopButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), for: .touchUpInside)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}



