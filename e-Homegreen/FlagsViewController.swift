//
//  FlagsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class FlagsViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate {
    
    var appDel:AppDelegate!
    var flags:[Flag] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "FlagCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var flagsCollectionView: UICollectionView!
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Flags)
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Flags)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
        updateFlagsList()
        flagsCollectionView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //        cyclesTextField.delegate = self
        
//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
        refreshFlagList()
        // Do any additional setup after loading the view.
    }
    func refreshFlagList() {
        updateFlagsList()
        flagsCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
        pullDown.drawMenu(filterParametar)
        updateFlagsList()
        flagsCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        refreshFlagList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FlagsViewController.refreshFlagList), name: NotificationKey.RefreshFlag, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FlagsViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFlag, object: nil)
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
        flagsCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func updateFlagsList () {
        let fetchRequest = NSFetchRequest(entityName: "Flag")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.location.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
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
            let zonePredicate = NSPredicate(format: "flagZone == %@", filterParametar.zoneName)
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "flagCategory == %@", filterParametar.categoryName)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
            flags = fetResults!
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
}

extension FlagsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let flagId = flags[indexPath.row].flagId as? Int {
            var address:[UInt8] = []
            if flags[indexPath.row].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if flags[indexPath.row].isLocalcast.boolValue {
                address = [UInt8(Int(flags[indexPath.row].gateway.addressOne)), UInt8(Int(flags[indexPath.row].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(flags[indexPath.row].gateway.addressOne)), UInt8(Int(flags[indexPath.row].gateway.addressTwo)), UInt8(Int(flags[indexPath.row].address))]
            }
            if flags[indexPath.row].setState.boolValue {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[indexPath.row].gateway)
            } else {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[indexPath.row].gateway)
            }
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension FlagsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flags.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(flagsCollectionView)
            if let index = flagsCollectionView.indexPathForItemAtPoint(location){
                let cell = flagsCollectionView.cellForItemAtIndexPath(index)
                showFlagParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - flagsCollectionView.contentOffset.y), flag: flags[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlagCollectionViewCell
        
        var flagLevel = ""
        var flagZone = ""
        let flagLocation = flags[indexPath.row].gateway.name
        
        if let level = flags[indexPath.row].entityLevel{
            flagLevel = level
        }
        if let zone = flags[indexPath.row].flagZone{
            flagZone = zone
        }
        
        if filterParametar.location == "All" {
            cell.flagTitle.text = flagLocation + " " + flagLevel + " " + flagZone + " " + flags[indexPath.row].flagName
        }else{
            var flagTitle = ""
            if filterParametar.levelName == "All"{
                flagTitle += " " + flagLevel
            }
            if filterParametar.zoneName == "All"{
                flagTitle += " " + flagZone
            }
            flagTitle += " " + flags[indexPath.row].flagName
            cell.flagTitle.text = flagTitle
        }
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FlagsViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.flagTitle.userInteractionEnabled = true
        cell.flagTitle.addGestureRecognizer(longPress)
        
        cell.getImagesFrom(flags[indexPath.row])
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlagsViewController.setFlag(_:)))
        cell.flagImageView.tag = indexPath.row
        cell.flagImageView.userInteractionEnabled = true
        cell.flagImageView.addGestureRecognizer(set)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FlagsViewController.buttonPressed(_:)))
        cell.flagButton.tag = indexPath.row
        cell.flagButton.addGestureRecognizer(tap)
        if flags[indexPath.row].setState.boolValue {
            cell.flagButton.setTitle("Set False", forState: UIControlState.Normal)
        } else {
            cell.flagButton.setTitle("Set True", forState: UIControlState.Normal)
        }
        
        cell.flagImageView.layer.cornerRadius = 5
        cell.flagImageView.clipsToBounds = true
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func setFlag (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            if let flagId = flags[tag].flagId as? Int {
                var address:[UInt8] = []
                if flags[tag].isBroadcast.boolValue {
                    address = [0xFF, 0xFF, 0xFF]
                } else if flags[tag].isLocalcast.boolValue {
                    address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), 0xFF]
                } else {
                    address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), UInt8(Int(flags[tag].address))]
                }
                if flags[tag].setState.boolValue {
                    SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
                } else {
                    SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
                }
            }
        }
    }
    
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let flagId = Int(flags[tag].flagId)
        var address:[UInt8] = []
        if flags[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), UInt8(Int(flags[tag].address))]
        }
        if flags[tag].setState.boolValue {
            SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
        }
    }
}
class FlagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flagTitle: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var flagButton: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(flag:Flag) {
        if let flagImage = UIImage(data: flag.flagImageOne) {
            imageOne = flagImage
        }
        if let flagImage = UIImage(data: flag.flagImageTwo) {
            imageTwo = flagImage
        }
        if flag.setState.boolValue {
            flagImageView.image = imageTwo
        } else {
            flagImageView.image = imageOne
        }
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        flagImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(FlagCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        flagImageView.image = imageOne
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
