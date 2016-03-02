//
//  EventsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class EventsViewController: CommonViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate {
    
    @IBOutlet weak var eventCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    var appDel:AppDelegate!
    var events:[Event] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "EventCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var locationSearchText = ["", "", "", "", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
        updateEventsList()
        eventCollectionView.reloadData()
        LocalSearchParametar.setLocalParametar("Events", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
        locationSearchText = LocalSearchParametar.getLocalParametar("Events")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        locationSearchText = LocalSearchParametar.getLocalParametar("Events")
        updateEventsList()
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        // Do any additional setup after loading the view.
    }
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Events")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshEventsList", name: NotificationKey.RefreshEvent, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
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
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
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
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        eventCollectionView.reloadData()
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    var zoneSearchName:String = "All"
    var levelSearchName:String = "All"
    var categorySearchName:String = "All"
    
    func returnZoneWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnCategoryWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func updateEventsList () {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne]
//        if levelSearch != "All" {
//            let levelPredicate = NSPredicate(format: "entityLevel == %@", returnZoneWithId(Int(levelSearch)!))
//            predicateArray.append(levelPredicate)
//        }
//        if zoneSearch != "All" {
//            let zonePredicate = NSPredicate(format: "eventZone == %@", returnZoneWithId(Int(zoneSearch)!))
//            predicateArray.append(zonePredicate)
//        }
//        if categorySearch != "All" {
//            let categoryPredicate = NSPredicate(format: "eventCategory == %@", returnCategoryWithId(Int(categorySearch)!))
//            predicateArray.append(categoryPredicate)
//        }
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelSearchName)
            predicateArray.append(levelPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "eventZone == %@", zoneSearchName)
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "eventCategory == %@", categorySearchName)
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
        cell.eventTitle.text = "\(events[indexPath.row].eventName)"
        cell.eventTitle.tag = indexPath.row
        cell.eventTitle.userInteractionEnabled = true
        cell.getImagesFrom(events[indexPath.row])
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
        longPress.minimumPressDuration = 0.5
        cell.eventTitle.addGestureRecognizer(longPress)
        cell.eventImageView.tag = indexPath.row
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "setEvent:")
        cell.eventImageView.userInteractionEnabled = true
        cell.eventImageView.addGestureRecognizer(set)
        if let eventImage = UIImage(data: events[indexPath.row].eventImageOne) {
            cell.eventImageView.image = eventImage
        }
        cell.eventImageView.layer.cornerRadius = 5
        cell.eventImageView.clipsToBounds = true
        
        cell.eventButton.tag = indexPath.row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapCancel:")
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
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
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