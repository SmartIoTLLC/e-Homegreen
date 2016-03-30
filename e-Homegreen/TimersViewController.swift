//
//  TimersViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class TimersViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
        
    var appDel:AppDelegate!
    var timers:[Timer] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    var senderButton:UIButton?
    var sidebarMenuOpen : Bool!
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "TimerCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var timersCollectionView: UICollectionView!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Timers)
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Timers)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        updateTimersList()
        timersCollectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //        cyclesTextField.delegate = self
        
//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        refreshTimerList()
        // Do any additional setup after loading the view.
    }
    func refreshTimerList() {
        updateTimersList()
        timersCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Timers)
        pullDown.drawMenu(filterParametar)
        updateTimersList()
        timersCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        refreshTimerList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimersViewController.refreshTimerList), name: NotificationKey.RefreshTimer, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TimersViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshTimer, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
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
        timersCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func updateTimersList () {
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
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
            let zonePredicate = NSPredicate(format: "timeZone == %@", filterParametar.zoneName)
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "timerCategory == %@", filterParametar.categoryName)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            timers = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
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
        let pointInTable = button.convertPoint(button.bounds.origin, toView: timersCollectionView)
        let indexPath = timersCollectionView.indexPathForItemAtPoint(pointInTable)
        if let cell = timersCollectionView.cellForItemAtIndexPath(indexPath!) as? TimerCollectionViewCell {
            cell.commandSentChangeImage()
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            timersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            timersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            timersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: Selector("closeSideMenu"))
            self.view.addGestureRecognizer(tap)
            timersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }

}

extension TimersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        var address:[UInt8] = []
//        if sequences[indexPath.row].isBroadcast.boolValue {
//            address = [0xFF, 0xFF, 0xFF]
//        } else {
//            address = [UInt8(Int(sequences[indexPath.row].gateway.addressOne)), UInt8(Int(sequences[indexPath.row].gateway.addressTwo)), UInt8(Int(sequences[indexPath.row].address))]
//        }
//        if let cycles = sequences[indexPath.row].sequenceCycles as? Int {
//            if cycles >= 0 && cycles <= 255 {
//                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[indexPath.row].sequenceId), cycle: UInt8(cycles)), gateway: sequences[indexPath.row].gateway)
//            }
//        } else {
//            SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[indexPath.row].sequenceId), cycle: 0x00), gateway: sequences[indexPath.row].gateway)
//        }
//        sequenceCollectionView.reloadData()
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension TimersViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timers.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(timersCollectionView)
            if let index = timersCollectionView.indexPathForItemAtPoint(location){
                let cell = timersCollectionView.cellForItemAtIndexPath(index)
                showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - timersCollectionView.contentOffset.y), timer: timers[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TimerCollectionViewCell
        
        var timerLevel = ""
        var timerZone = ""
        let timerLocation = timers[indexPath.row].gateway.name
        
        if let level = timers[indexPath.row].entityLevel{
            timerLevel = level
        }
        if let zone = timers[indexPath.row].timeZone{
            timerZone = zone
        }
        
        if filterParametar.location == "All" {
            cell.timerTitle.text = timerLocation + " " + timerLevel + " " + timerZone + " " + timers[indexPath.row].timerName
        }else{
            var timerTitle = ""
            if filterParametar.levelName == "All"{
                timerTitle += " " + timerLevel
            }
            if filterParametar.zoneName == "All"{
                timerTitle += " " + timerZone
            }
            timerTitle += " " + timers[indexPath.row].timerName
            cell.timerTitle.text = timerTitle
        }
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TimersViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.timerTitle.userInteractionEnabled = true
        cell.timerTitle.addGestureRecognizer(longPress)
        
        cell.getImagesFrom(timers[indexPath.row])
        
        cell.timerButton.tag = indexPath.row
        cell.timerButtonLeft.tag = indexPath.row
        cell.timerButtonRight.tag = indexPath.row
        print(timers[indexPath.row].type)
        if timers[indexPath.row].type == "Countdown" {
            //   ===   Default   ===
            cell.timerButton.hidden = false
            cell.timerButtonLeft.hidden = true
            cell.timerButtonRight.hidden = true
            cell.timerButton.enabled = true
            cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
            cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            //   ===================
            if timers[indexPath.row].timerState == 1 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Pause", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedPause(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.enabled = true
                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedStart(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 238 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Resume", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: #selector(TimersViewController.pressedResume(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
//                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = false
            } else {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: #selector(TimersViewController.pressedCancel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = true
            }
        }
        
        // cancel start pause resume
        //
        cell.timerImageView.layer.cornerRadius = 5
        cell.timerImageView.clipsToBounds = true
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}


class TimerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerButtonLeft: UIButton!
    @IBOutlet weak var timerButtonRight: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(timer:Timer) {
        if let timerImage = UIImage(data: timer.timerImageOne) {
            imageOne = timerImage
        }
        if let timerImage = UIImage(data: timer.timerImageTwo) {
            imageTwo = timerImage
        }
        timerImageView.image = imageOne
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        timerImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(TimerCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        timerImageView.image = imageOne
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
