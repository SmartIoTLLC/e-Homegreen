//
//  EventsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class EventsViewController: PopoverVC{
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "EventCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem!
    var events:[Event] = []
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { eventCollectionView.reloadData() })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        eventCollectionView.isUserInteractionEnabled = true
        
        updateEventsList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }

}

// Parametar from filter and relaod data
extension EventsViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Events", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.events)
        updateEventsList()
        
        TimerForFilter.shared.counterEvents = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.events)
        TimerForFilter.shared.startTimer(type: Menu.events)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
    
    func updateEventsList(){
        events = DatabaseEventsController.shared.getEvents(filterParametar)
        eventCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        eventCollectionView.reloadData()
    }
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.events)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.events)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

// MARK: - Collection View Delegate Flow Layout
extension EventsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
extension EventsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? EventsCollectionViewCell {
            cell.setItem(events[indexPath.row], filterParametar: filterParametar, tag: indexPath.row)
            cell.getImagesFrom(events[indexPath.row])
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(rotateCell(_:)))
            longPress.minimumPressDuration = 0.5
            
            cell.eventTitle.addGestureRecognizer(longPress)
            cell.eventImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setEvent(_:))))
            cell.eventButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCancel(_:))))
            
            return cell
        }
        
        return UICollectionViewCell()
    }

}

// MARK: - View setup
extension EventsViewController {
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Events", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.events)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEvents), object: nil)
    }
    
    func rotateCell(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: eventCollectionView)
            if let indexPath = eventCollectionView.indexPathForItem(at: location) {
                if let cell = eventCollectionView.cellForItem(at: indexPath) as? EventsCollectionViewCell {
                    UIView.transition(from: cell.frontView, to: cell.backView, duration: 0.5, options: [.showHideTransitionViews, .transitionFlipFromBottom, ], completion: nil)
                    cell.parametersAreShowing = true
                }
            }
        }
    }
    
}

// MARK: - Logic
extension EventsViewController {
    
    func setEvent (_ gesture:UIGestureRecognizer) {
        sendEventCommand(from: gesture, eventType: .run)
    }
    func tapCancel (_ gesture:UITapGestureRecognizer) {
        sendEventCommand(from: gesture, eventType: .cancel)
    }
    
    fileprivate func sendEventCommand(from gesture: UIGestureRecognizer, eventType: EventType) {
        if let tag = gesture.view?.tag {
            let event      = events[tag]
            let eventID    = Int(event.eventId)
            let gateway    = event.gateway
            let useTrigger = event.useTrigger
            
            var address: [Byte] = []
            
            if event.isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if event.isLocalcast.boolValue {
                address = [getByte(event.gateway.addressOne), getByte(event.gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(event.gateway.addressOne), getByte(event.gateway.addressTwo), getByte(event.address)]
            }
            
            switch eventType {
                case .run     :
                    if useTrigger {
                        SendingHandler.sendCommand(byteArray: OutgoingHandler.triggerEvent(address, id: UInt8(eventID)), gateway: gateway)
                    } else {
                        if eventID >= 0 && eventID <= 255 { SendingHandler.sendCommand(byteArray: OutgoingHandler.runEvent(address, id: UInt8(eventID)), gateway: gateway) }
                    }
                case .cancel  : SendingHandler.sendCommand(byteArray: OutgoingHandler.cancelEvent(address, id: UInt8(eventID)), gateway: gateway)
            }
            
            if let originPoint = gesture.view?.bounds.origin {
                if let pointInCollection = gesture.view?.convert(originPoint, to: eventCollectionView) {
                    if let indexPath = eventCollectionView.indexPathForItem(at: pointInCollection) {
                        if let cell = eventCollectionView.cellForItem(at: indexPath) as? EventsCollectionViewCell {
                            cell.commandSentChangeImage()
                        }
                    }
                }
            }
        }
    }
    enum EventType {
        case run
        case cancel
    }
    
}


// MARK: - SW Reveal View Controller Delegate
extension EventsViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { eventCollectionView.isUserInteractionEnabled = true } else { eventCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { eventCollectionView.isUserInteractionEnabled = true } else { eventCollectionView.isUserInteractionEnabled = false }
    }
    
}
