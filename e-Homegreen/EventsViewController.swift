//
//  EventsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    var events:[Event] = []
    var sidebarMenuOpen : Bool!
    
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "EventCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Events)
    
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Events)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)
        updateEventsList()
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
        
        updateEventsList()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)

    }
    func updateEventsList(){
        events = DatabaseEventsController.shared.getEvents(filterParametar)
        eventCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)
        pullDown.drawMenu(filterParametar)
//        updateEventsList()
        eventCollectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
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
        eventCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            eventCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            eventCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            eventCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(EventsViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            eventCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize
    }
}

extension EventsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! EventsCollectionViewCell
    
        var eventLevel = ""
        var eventZone = ""
        let eventLocation = events[indexPath.row].gateway.location.name!
        
        if let level = events[indexPath.row].entityLevel{
            eventLevel = level
        }
        if let zone = events[indexPath.row].eventZone{
            eventZone = zone
        }
        
        if filterParametar.location == "All" {
            cell.eventTitle.text = eventLocation + " " + eventLevel + " " + eventZone + " " + events[indexPath.row].eventName
        }else{
            var eventTitle = ""
            if filterParametar.location == "All"{
                eventTitle += " " + eventLocation
            }
            if filterParametar.levelName == "All"{
                eventTitle += " " + eventLevel
            }
            if filterParametar.zoneName == "All"{
                eventTitle += " " + eventZone
            }
            eventTitle += " " + events[indexPath.row].eventName
            cell.eventTitle.text = eventTitle
        }
        
        cell.eventTitle.tag = indexPath.row
        cell.eventTitle.userInteractionEnabled = true
        cell.getImagesFrom(events[indexPath.row])
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EventsViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.eventTitle.addGestureRecognizer(longPress)
        cell.eventImageView.tag = indexPath.row
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventsViewController.setEvent(_:)))
        cell.eventImageView.userInteractionEnabled = true
        cell.eventImageView.addGestureRecognizer(set)
        if let eventImage = UIImage(data: events[indexPath.row].eventImageOne) {
            cell.eventImageView.image = eventImage
        }
        cell.eventImageView.layer.cornerRadius = 5
        cell.eventImageView.clipsToBounds = true
        
        cell.eventButton.tag = indexPath.row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventsViewController.tapCancel(_:)))
        cell.eventButton.addGestureRecognizer(tap)
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    func setEvent (gesture:UIGestureRecognizer) {
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
                SendingHandler.sendCommand(byteArray: Function.runEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway)
            }
            let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: eventCollectionView)
            let indexPath = eventCollectionView.indexPathForItemAtPoint(pointInTable!)
            if let cell = eventCollectionView.cellForItemAtIndexPath(indexPath!) as? EventsCollectionViewCell {
                cell.commandSentChangeImage()
            }
        }
    }
    func tapCancel (gesture:UITapGestureRecognizer) {
        //   Take cell from touched point
        let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: eventCollectionView)
        let indexPath = eventCollectionView.indexPathForItemAtPoint(pointInTable!)
        if let cell = eventCollectionView.cellForItemAtIndexPath(indexPath!) as? EventsCollectionViewCell {
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
            SendingHandler.sendCommand(byteArray: Function.cancelEvent(address, id: UInt8(eventId)), gateway: events[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(eventCollectionView)
            if let index = eventCollectionView.indexPathForItemAtPoint(location){
                let cell = eventCollectionView.cellForItemAtIndexPath(index)
                showEventParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - eventCollectionView.contentOffset.y), event: events[tag])
            }
        }
    }
}
