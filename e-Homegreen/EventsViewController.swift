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
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Events", subtitle: "All All All")
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EventsViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
//        scrollView.setFilterItem(Menu.events)
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerEvents), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5

            revealViewController().rearViewRevealWidth = 200
        }
        
        eventCollectionView.isUserInteractionEnabled = true
        
        updateEventsList()
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
        eventCollectionView.reloadData()
        
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
//            scrollView.setDefaultFilterItem(Menu.events)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Events", subtitle: location + " " + level + " " + zone)
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
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func updateEventsList(){
        events = DatabaseEventsController.shared.getEvents(filterParametar)
        eventCollectionView.reloadData()
    }
    func refreshLocalParametars() {
//        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)
//        pullDown.drawMenu(filterParametar)
//        updateEventsList()
        eventCollectionView.reloadData()
    }
    
    // Helper functions
    func setDefaultFilterFromTimer(){
//        scrollView.setDefaultFilterItem(Menu.events)
    }

}

// Parametar from filter and relaod data
extension EventsViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
//        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.events)
        updateEventsList()
        
//        TimerForFilter.shared.counterEvents = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.events)
//        TimerForFilter.shared.startTimer(type: Menu.events)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension EventsViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            eventCollectionView.isUserInteractionEnabled = true
        } else {
            eventCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            eventCollectionView.isUserInteractionEnabled = true
        } else {
            eventCollectionView.isUserInteractionEnabled = false
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EventsCollectionViewCell

        cell.setItem(events[(indexPath as NSIndexPath).row], filterParametar: filterParametar)
        
        cell.eventTitle.tag = (indexPath as NSIndexPath).row
        cell.eventTitle.isUserInteractionEnabled = true
        cell.getImagesFrom(events[(indexPath as NSIndexPath).row])
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EventsViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.eventTitle.addGestureRecognizer(longPress)
        cell.eventImageView.tag = (indexPath as NSIndexPath).row
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventsViewController.setEvent(_:)))
        cell.eventImageView.isUserInteractionEnabled = true
        cell.eventImageView.addGestureRecognizer(set)
        
        if let id = events[(indexPath as NSIndexPath).row].eventImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    cell.eventImageView.image = UIImage(data: data)
                }else{
                    if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                        cell.eventImageView.image = UIImage(named: defaultImage)
                    }else{
                        cell.eventImageView.image = UIImage(named: "17 Event - Up Down - 00")
                    }
                }
            }else{
                if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                    cell.eventImageView.image = UIImage(named: defaultImage)
                }else{
                    cell.eventImageView.image = UIImage(named: "17 Event - Up Down - 00")
                }
            }
        }else{
            if let defaultImage = events[(indexPath as NSIndexPath).row].eventImageOneDefault{
                cell.eventImageView.image = UIImage(named: defaultImage)
            }else{
                cell.eventImageView.image = UIImage(named: "17 Event - Up Down - 00")
            }
        }
        
        cell.eventImageView.layer.cornerRadius = 5
        cell.eventImageView.clipsToBounds = true
        
        cell.eventButton.tag = (indexPath as NSIndexPath).row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventsViewController.tapCancel(_:)))
        cell.eventButton.addGestureRecognizer(tap)
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    func setEvent (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if events[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if events[tag].isLocalcast.boolValue {
                address = [UInt8(Int(events[tag].gateway.addressOne)), UInt8(Int(events[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(events[tag].gateway.addressOne)), UInt8(Int(events[tag].gateway.addressTwo)), UInt8(Int(events[tag].address))]
            }
            let eventId = Int(events[tag].eventId)
            if eventId >= 0 && eventId <= 255 {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.runEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway)
            }
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
                address = [UInt8(Int(events[tag].gateway.addressOne)), UInt8(Int(events[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(events[tag].gateway.addressOne)), UInt8(Int(events[tag].gateway.addressTwo)), UInt8(Int(events[tag].address))]
            }
            SendingHandler.sendCommand(byteArray: OutgoingHandler.cancelEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: eventCollectionView)
            if let index = eventCollectionView.indexPathForItem(at: location){
                let cell = eventCollectionView.cellForItem(at: index)
                showEventParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - eventCollectionView.contentOffset.y), event: events[tag])
            }
        }
    }
}
