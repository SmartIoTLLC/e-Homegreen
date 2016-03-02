//
//  SequencesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SequencesViewController: CommonViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, PullDownViewDelegate {

    @IBOutlet weak var sequenceCollectionView: UICollectionView!
//    @IBOutlet weak var broadcastSwitch: UISwitch!
//    @IBOutlet weak var cyclesTextField: UITextField!
    
    var pullDown = PullDownView()
    var senderButton:UIButton?
    
    var appDel:AppDelegate!
    var sequences:[Sequence] = []
    var error:NSError? = nil
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SequenceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var locationSearchText = ["", "", "", "", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
        updateSequencesList()
        sequenceCollectionView.reloadData()
        LocalSearchParametar.setLocalParametar("Sequences", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
        locationSearchText = LocalSearchParametar.getLocalParametar("Sequences")
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
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
        locationSearchText = LocalSearchParametar.getLocalParametar("Sequences")
        updateSequencesList()
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        // Do any additional setup after loading the view.
    }
    func refreshSequenceList() {
        updateSequencesList()
        sequenceCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Sequences")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
        updateSequencesList()
        sequenceCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        refreshSequenceList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSequenceList", name: NotificationKey.RefreshSequence, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSequence, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
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
        sequenceCollectionView.reloadData()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
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
        
    func updateSequencesList () {
        let fetchRequest = NSFetchRequest(entityName: "Sequence")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne]
//        if levelSearch != "All" {
//            let levelPredicate = NSPredicate(format: "entityLevel == %@", returnZoneWithId(Int(levelSearch)!))
//            predicateArray.append(levelPredicate)
//        }
//        if zoneSearch != "All" {
//            let zonePredicate = NSPredicate(format: "sequenceZone == %@", returnZoneWithId(Int(zoneSearch)!))
//            predicateArray.append(zonePredicate)
//        }
//        if categorySearch != "All" {
//            let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", returnCategoryWithId(Int(categorySearch)!))
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
            let zonePredicate = NSPredicate(format: "sequenceZone == %@", zoneSearchName)
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", categorySearchName)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            sequences = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
//        if let results = fetResults {
//            sequences = results
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

extension SequencesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        var address:[UInt8] = []
//        if sequences[indexPath.row].isBroadcast.boolValue {
//            address = [0xFF, 0xFF, 0xFF]
//        } else if sequences[indexPath.row].isLocalcast.boolValue {
//            address = [UInt8(Int(sequences[indexPath.row].gateway.addressOne)), UInt8(Int(sequences[indexPath.row].gateway.addressTwo)), 0xFF]
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
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension SequencesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(sequenceCollectionView)
            if let index = sequenceCollectionView.indexPathForItemAtPoint(location){
                let cell = sequenceCollectionView.cellForItemAtIndexPath(index)
                showSequenceParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - sequenceCollectionView.contentOffset.y), sequence: sequences[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SequenceCollectionViewCell
        
        var sequenceLevel = ""
        var sequenceZone = ""
        let sequenceLocation = sequences[indexPath.row].gateway.name
        
        if let level = sequences[indexPath.row].entityLevel{
            sequenceLevel = level
        }
        if let zone = sequences[indexPath.row].sequenceZone{
            sequenceZone = zone
        }
        
        if locationSearchText[0] == "All" {
            cell.sequenceTitle.text = sequenceLocation + " " + sequenceLevel + " " + sequenceZone + " " + sequences[indexPath.row].sequenceName
        }else{
            var sequenceTitle = ""
            if locationSearchText[4] == "All"{
                sequenceTitle += " " + sequenceLevel
            }
            if locationSearchText[5] == "All"{
                sequenceTitle += " " + sequenceZone
            }
            sequenceTitle += " " + sequences[indexPath.row].sequenceName
            cell.sequenceTitle.text = sequenceTitle
        }

        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
        longPress.minimumPressDuration = 0.5
        cell.sequenceTitle.userInteractionEnabled = true
        cell.sequenceTitle.addGestureRecognizer(longPress)
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "setSequence:")
        cell.sequenceImageView.tag = indexPath.row
        cell.sequenceImageView.userInteractionEnabled = true
        cell.sequenceImageView.addGestureRecognizer(set)
        cell.sequenceImageView.clipsToBounds = true
        cell.sequenceImageView.layer.cornerRadius = 5
        
        cell.getImagesFrom(sequences[indexPath.row])
        
        cell.sequenceButton.tag = indexPath.row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapStop:")
        cell.sequenceButton.addGestureRecognizer(tap)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    func setSequence (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), UInt8(Int(sequences[tag].address))]
            }
            if let cycles = sequences[tag].sequenceCycles as? Int {
                if cycles >= 0 && cycles <= 255 {
                    SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[tag].sequenceId), cycle: UInt8(cycles)), gateway: sequences[tag].gateway)
                }
            } else {
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[tag].sequenceId), cycle: 0x00), gateway: sequences[tag].gateway)
            }
            let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: sequenceCollectionView)
            let indexPath = sequenceCollectionView.indexPathForItemAtPoint(pointInTable!)
            if let cell = sequenceCollectionView.cellForItemAtIndexPath(indexPath!) as? SequenceCollectionViewCell {
                cell.commandSentChangeImage()
            }
        }
    }
    func tapStop (gesture:UITapGestureRecognizer) {
        //   Take cell from touched point
        let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: sequenceCollectionView)
        let indexPath = sequenceCollectionView.indexPathForItemAtPoint(pointInTable!)
        if let cell = sequenceCollectionView.cellForItemAtIndexPath(indexPath!) as? SequenceCollectionViewCell {
            //   Take tag from touced vies
            let tag = gesture.view!.tag
            let sequenceId = Int(sequences[tag].sequenceId)
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), UInt8(Int(sequences[tag].address))]
            }
            //  0xEF = 239, stops it?
            SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: sequenceId, cycle: 0xEF), gateway: sequences[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
}


class SequenceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sequenceTitle: UILabel!
    @IBOutlet weak var sequenceImageView: UIImageView!
    @IBOutlet weak var sequenceButton: UIButton!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(sequence:Sequence) {
        if let sequenceImage = UIImage(data: sequence.sequenceImageOne) {
            imageOne = sequenceImage
        }
        
        if let sequenceImage = UIImage(data: sequence.sequenceImageTwo) {
            imageTwo = sequenceImage
        }
        sequenceImageView.image = imageOne
        setNeedsDisplay()
    }
//    override var highlighted: Bool {
//        willSet(newValue) {
//            if newValue {
//                sequenceImageView.image = imageTwo
//                setNeedsDisplay()
//                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
//            }
//        }
//        didSet {
//            print("highlighted = \(highlighted)")
//        }
//    }
    func commandSentChangeImage() {
        sequenceImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
    }
    func changeImageToNormal () {
        sequenceImageView.image = imageOne
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