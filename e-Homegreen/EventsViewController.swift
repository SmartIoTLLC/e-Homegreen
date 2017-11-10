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
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    var events:[Event] = []

    var scrollView = FilterPullDown()
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "EventCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEvents), object: nil)
    }
    
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
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { eventCollectionView.reloadData() })            
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.events)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    func updateEventsList(){
        events = DatabaseEventsController.shared.getEvents(filterParametar)
        eventCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        eventCollectionView.reloadData()
    }
    
    // Helper functions
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.events)
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
}

extension EventsViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { eventCollectionView.isUserInteractionEnabled = true } else { eventCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { eventCollectionView.isUserInteractionEnabled = true } else { eventCollectionView.isUserInteractionEnabled = false }
    }
    
}

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
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.eventTitle.addGestureRecognizer(longPress)
            
            cell.eventImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setEvent(_:))))
            
            cell.eventButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapCancel(_:))))
            
            return cell
        }
        
        return UICollectionViewCell()

    }
    func setEvent (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if events[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if events[tag].isLocalcast.boolValue {
                address = [getByte(events[tag].gateway.addressOne), getByte(events[tag].gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(events[tag].gateway.addressOne), getByte(events[tag].gateway.addressTwo), getByte(events[tag].address)]
            }
            
            let eventId = Int(events[tag].eventId)
            if eventId >= 0 && eventId <= 255 { SendingHandler.sendCommand(byteArray: OutgoingHandler.runEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway) }
            
            let pointInTable = gesture.view?.convert(gesture.view!.bounds.origin, to: eventCollectionView)
            let indexPath = eventCollectionView.indexPathForItem(at: pointInTable!)
            if let cell = eventCollectionView.cellForItem(at: indexPath!) as? EventsCollectionViewCell {
                cell.commandSentChangeImage()
            }
        }
    }
    func tapCancel (_ gesture:UITapGestureRecognizer) {
        //   Take cell from touched point
        let pointInTable = gesture.view?.convert(gesture.view!.bounds.origin, to: eventCollectionView)
        let indexPath = eventCollectionView.indexPathForItem(at: pointInTable!)
        if let cell = eventCollectionView.cellForItem(at: indexPath!) as? EventsCollectionViewCell {
            //   Take tag from touced vies
            let tag = gesture.view!.tag
            let eventId = Int(events[tag].eventId)
            var address:[UInt8] = []
            if events[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if events[tag].isLocalcast.boolValue {
                address = [getByte(events[tag].gateway.addressOne), getByte(events[tag].gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(events[tag].gateway.addressOne), getByte(events[tag].gateway.addressTwo), getByte(events[tag].address)]
            }
            SendingHandler.sendCommand(byteArray: OutgoingHandler.cancelEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: eventCollectionView)
            if let index = eventCollectionView.indexPathForItem(at: location) {
                let cell = eventCollectionView.cellForItem(at: index)
                showEventParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - eventCollectionView.contentOffset.y), event: events[tag])
            }
        }
    }
}
