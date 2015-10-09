//
//  TimersViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class TimersViewController: CommonViewController {
        
    var appDel:AppDelegate!
    var timers:[Timer] = []
    var error:NSError? = nil
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "TimerCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var timersCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        cyclesTextField.delegate = self
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        refreshTimerList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshTimerList", name: "refreshTimerListNotification", object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
        }else{
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
        }
        timersCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func refreshTimerList () {
        updateTimersList()
        timersCollectionView.reloadData()
    }
    func updateTimersList () {
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
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
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEE), gateway: timers[tag].gateway)
    }
    
    func pressedStart (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0x01), gateway: timers[tag].gateway)
    }
    
    func pressedResume (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xED), gateway: timers[tag].gateway)
    }
    
    func pressedCancel (button:UIButton) {
        let tag = button.tag
        var address:[UInt8] = []
        if timers[tag].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
        }
        SendingHandler.sendCommand(byteArray: Function.getCancelTimerStatus(address, id: UInt8(Int(timers[tag].timerId)), command: 0xEF), gateway: timers[tag].gateway)
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
        cell.timerTitle.text = "\(timers[indexPath.row].timerName)"
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
        longPress.minimumPressDuration = 0.5
        cell.timerTitle.userInteractionEnabled = true
        cell.timerTitle.addGestureRecognizer(longPress)
        
        if let timerImage = UIImage(data: timers[indexPath.row].timerImageOne) {
            cell.timerImageView.image = timerImage
        }
        
        if let timerImage = UIImage(data: timers[indexPath.row].timerImageTwo) {
            cell.timerImageView.highlightedImage = timerImage
        }
        cell.timerButton.tag = indexPath.row
        cell.timerButtonLeft.tag = indexPath.row
        cell.timerButtonRight.tag = indexPath.row
//        cell.timerButton.buttonW = UIButtonType.Custom
//        cell.timerButton.buttonType = UIButtonType.Custom
//        cell.timerButton.buttonType = UIButtonType.Custom
        print(timers[indexPath.row].type)
        if timers[indexPath.row].type == "Countdown" {
            if timers[indexPath.row].timerState == 1 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Pause", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: "pressedPause:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: "pressedStart:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            if timers[indexPath.row].timerState == 238 {
                cell.timerButton.hidden = true
                cell.timerButtonLeft.hidden = false
                cell.timerButtonRight.hidden = false
                cell.timerButtonRight.setTitle("Resume", forState: UIControlState.Normal)
                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButtonRight.addTarget(self, action: "pressedResume:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButtonLeft.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
            }
        } else {
            if timers[indexPath.row].timerState == 240 {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = false
            } else {
                cell.timerButton.hidden = false
                cell.timerButtonLeft.hidden = true
                cell.timerButtonRight.hidden = true
                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
                cell.timerButton.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.timerButton.enabled = true
            }
        }
//        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapStop:")
//        cell.timerButton.addGestureRecognizer(tap)
//        cell.timerButton.tag = indexPath.row
        
        // cancel start pause resume
        //
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func tapStop (gestureRecognizer:UITapGestureRecognizer) {
//        let tag = gestureRecognizer.view!.tag
//        if let sequenceId = sequences[tag].sequenceId as? Int {
//            var address:[UInt8] = []
//            if timers[tag].isBroadcast.boolValue {
//                address = [0xFF, 0xFF, 0xFF]
//            } else {
//                address = [UInt8(Int(timers[tag].gateway.addressOne)), UInt8(Int(timers[tag].gateway.addressTwo)), UInt8(Int(timers[tag].address))]
//            }
//            SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: sequenceId, cycle: 0xEF), gateway: sequences[tag].gateway)
//            //        RepeatSendingHandler(byteArray: <#[UInt8]#>, gateway: <#Gateway#>, notificationName: <#String#>, device: <#Device#>, oldValue: <#Int#>)
//        }
    }
}


class TimerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerButtonLeft: UIButton!
    @IBOutlet weak var timerButtonRight: UIButton!
    
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
