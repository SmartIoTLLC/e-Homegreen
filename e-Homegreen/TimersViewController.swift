//
//  TimersViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class TimersViewController: PopoverVC {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "TimersCell"
    var timers:[Timer] = []
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem!
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var timersCollectionView: UICollectionView!
    @IBAction func refreshTimers(_ sender: UIButton) {
        refreshTimersStatus()
        sender.rotate(1)
    }
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
        
        loadFilter()
        
        setupConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { timersCollectionView.reloadData() })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        timersCollectionView.isUserInteractionEnabled = true
        
        refreshTimerList()
        refreshTimersStatus()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let cells = self.timersCollectionView.visibleCells as? [TimerCollectionViewCell] {
            for cell in cells { cell.time?.invalidate() }
        }
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - Parametar from filter and relaod data
extension TimersViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Timers", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)        
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.timers)
        FilterItem.saveFilter(filterItem, type: .Timers)
        refreshTimerList()
        TimerForFilter.shared.counterTimers = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.timers)
        TimerForFilter.shared.startTimer(type: Menu.timers)
    }
    
    func saveDefaultFilter(){
        view.makeToast(message: "Default filter parametar saved!")
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            scrollView.setDefaultFilterItem(Menu.timers)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @objc func refreshTimerList() {
        timers = DatabaseTimersController.shared.getTimers(filterParametar)
        timersCollectionView.reloadData()
    }
    
    @objc func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.timers)
    }
}

// MARK: - View setup
extension TimersViewController {
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Timers", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.timers)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTimerList), name: NSNotification.Name(rawValue: NotificationKey.RefreshTimer), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerTimers), object: nil)
    }
}

// MARK: - Logic
extension TimersViewController {
    @objc func pressedPause (_ button:UIButton) {
        let tag = button.tag
        
        sendTimerCommand(.pause, timerTag: tag)
        changeImageInCell(button)
    }
    @objc func pressedStart (_ button:UIButton) {
        let tag = button.tag
        
        sendTimerCommand(.start, timerTag: tag)
        changeImageInCell(button)
    }
    @objc func pressedResume (_ button:UIButton) {
        let tag = button.tag
        
        sendTimerCommand(.resume, timerTag: tag)
        changeImageInCell(button)
    }
    @objc func pressedCancel (_ button:UIButton) {
        let tag = button.tag
        
        sendTimerCommand(.cancel, timerTag: tag)
        changeImageInCell(button)
    }
    
    private func sendTimerCommand(_ command: TimerCommand, timerTag tag: Int) {
        let timer   = timers[tag]
        let command = command.rawValue
        var address: [Byte] = []
        
        if timer.isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if timer.isLocalcast.boolValue {
            address = [getByte(timer.gateway.addressOne), getByte(timer.gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(timer.gateway.addressOne), getByte(timer.gateway.addressTwo), getByte(timer.address)]
        }
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCancelTimerStatus(address, id: getByte(timer.timerId), command: command), gateway: timer.gateway)
    }
    
    enum TimerCommand: Byte {
        case cancel = 0xEF
        case resume = 0xED
        case start  = 0x01
        case pause  = 0xEE
    }
    
    func changeImageInCell(_ button:UIButton) {
        let pointInTable = button.convert(button.bounds.origin, to: timersCollectionView)
        let indexPath = timersCollectionView.indexPathForItem(at: pointInTable)
        if let cell = timersCollectionView.cellForItem(at: indexPath!) as? TimerCollectionViewCell {
            cell.commandSentChangeImage()
        }
    }
    
    func refreshTimersStatus() {
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
    
    private func loadFilter() {
        if let filter = FilterItem.loadFilter(type: .Timers) {
            filterParametars(filter)
        }
    }
}

// MARK: - Collection View Delegate Flow Layout
extension TimersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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

// MARK: - Collection View Data Source
extension TimersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return timers.count
    }
    
    @objc func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == UIGestureRecognizer.State.began {
                let location = gestureRecognizer.location(in: timersCollectionView)
                if let index = timersCollectionView.indexPathForItem(at: location) {
                    let cell = timersCollectionView.cellForItem(at: index)
                    showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - timersCollectionView.contentOffset.y), timer: timers[tag])
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TimerCollectionViewCell {
            
            let timer = timers[indexPath.row]
            cell.setItem(timer, filterParametar: filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.timerTitle.addGestureRecognizer(longPress)
            
            if Int(timer.type) == TimerType.timer.rawValue || Int(timer.type) == TimerType.stopwatch.rawValue {
                //   ===   Default   ===
                cell.timerButton.addTarget(self, action: #selector(pressedStart(_:)), for: .touchUpInside)
                
                if timer.timerState == 1 {
                    cell.timerButtonRight.addTarget(self, action: #selector(pressedPause(_:)), for: .touchUpInside)
                    cell.timerButtonLeft.addTarget(self, action: #selector(pressedCancel(_:)), for: .touchUpInside)
                }
                
                if timer.timerState == 240 {
                    cell.timerButton.addTarget(self, action: #selector(pressedStart(_:)), for: .touchUpInside)
                }
                
                if timer.timerState == 238 {
                    cell.timerButtonRight.addTarget(self, action: #selector(pressedResume(_:)), for: .touchUpInside)
                    cell.timerButtonLeft.addTarget(self, action: #selector(pressedCancel(_:)), for: .touchUpInside)
                }
                
            } else {
                
                if timer.timerState == 240 {
                    cell.timerButton.addTarget(self, action: #selector(pressedCancel(_:)), for: .touchUpInside)
                } else {
                    cell.timerButton.addTarget(self, action: #selector(pressedCancel(_:)), for: .touchUpInside)
                }
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

// MARK: - Reveal View Controller Delegate
extension TimersViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { timersCollectionView.isUserInteractionEnabled = true } else { timersCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { timersCollectionView.isUserInteractionEnabled = true } else { timersCollectionView.isUserInteractionEnabled = false }
    }
}
