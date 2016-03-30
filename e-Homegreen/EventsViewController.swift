//
//  EventsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class EventsViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    var appDel:AppDelegate!
    var events:[Event] = []
    var error:NSError? = nil
    
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
        eventCollectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)
        updateEventsList()
        // Do any additional setup after loading the view.
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Events)
        pullDown.drawMenu(filterParametar)
        updateEventsList()
        eventCollectionView.reloadData()
    }
    func refreshEventsList() {
        updateEventsList()
        eventCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        updateEventsList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventsViewController.refreshEventsList), name: NotificationKey.RefreshEvent, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventsViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshEvent, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            if self.view.frame.size.width == 568{
//                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
//            }else if self.view.frame.size.width == 667{
//                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
        } else {
//            if self.view.frame.size.width == 320{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }else if self.view.frame.size.width == 375{
//                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
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
    func updateEventsList () {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne]
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "gateway.location.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelName != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", filterParametar.levelName)
            predicateArray.append(levelPredicate)
        }
        if filterParametar.zoneName != "All" {
            let zonePredicate = NSPredicate(format: "eventZone == %@", filterParametar.zoneName)
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "eventCategory == %@", filterParametar.categoryName)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            events = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
//        if let results = fetResults {
//            events = results
//        } else {
//            
//        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        var address:[UInt8] = []
//        if events[indexPath.row].isBroadcast.boolValue {
//            address = [0xFF, 0xFF, 0xFF]
//        } else if events[indexPath.row].isLocalcast.boolValue {
//            address = [UInt8(Int(events[indexPath.row].gateway.addressOne)), UInt8(Int(events[indexPath.row].gateway.addressTwo)), 0xFF]
//        } else {
//            address = [UInt8(Int(events[indexPath.row].gateway.addressOne)), UInt8(Int(events[indexPath.row].gateway.addressTwo)), UInt8(Int(events[indexPath.row].address))]
//        }
//        let eventId = Int(events[indexPath.row].eventId)
//        if eventId >= 0 && eventId <= 255 {
//            SendingHandler.sendCommand(byteArray: Function.runEvent(address, id: UInt8(eventId)), gateway: events[indexPath.row].gateway)
//        }
    }
    
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
class EventsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventButton: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(event:Event) {
        if let eventImage = UIImage(data: event.eventImageOne) {
            imageOne = eventImage
        }
        
        if let eventImage = UIImage(data: event.eventImageTwo) {
            imageTwo = eventImage
        }
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
//    override var highlighted: Bool {
//        willSet(newValue) {
//            if newValue {
//                eventImageView.image = imageTwo
//                setNeedsDisplay()
//                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
//            }
//        }
//        didSet {
//            print("highlighted = \(highlighted)")
//        }
//    }
    func commandSentChangeImage () {
        eventImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(EventsCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}