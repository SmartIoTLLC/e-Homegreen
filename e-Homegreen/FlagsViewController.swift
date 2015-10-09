//
//  FlagsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class FlagsViewController: CommonViewController, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate {
    
    var appDel:AppDelegate!
    var flags:[Flag] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    
    var senderButton:UIButton?
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "FlagCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var flagsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        cyclesTextField.delegate = self
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        refreshFlagList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFlagList", name: "refreshFlagListNotification", object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            
            drawMenu()
            
        } else {
            
            
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
            
            drawMenu()
        }
<<<<<<< HEAD
=======
        
>>>>>>> origin/master
        flagsCollectionView.reloadData()
    }
    
    func drawMenu(){
        let locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(locationLabel)
        
        let levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(levelLabel)
        
        let zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
        zoneLabel.text = "Zone"
        zoneLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(zoneLabel)
        
        let categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
        categoryLabel.text = "Category"
        categoryLabel.textColor = UIColor.whiteColor()
        pullDown.addSubview(categoryLabel)
        
        let locationButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
        locationButton.backgroundColor = UIColor.grayColor()
        locationButton.titleLabel?.tintColor = UIColor.whiteColor()
        locationButton.setTitle("All", forState: UIControlState.Normal)
        locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationButton.layer.borderWidth = 1
        locationButton.tag = 1
        locationButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(locationButton)
        
        let levelButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
        levelButton.backgroundColor = UIColor.grayColor()
        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        levelButton.setTitle("All", forState: UIControlState.Normal)
        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        levelButton.layer.cornerRadius = 5
        levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        levelButton.layer.borderWidth = 1
        levelButton.tag = 2
        levelButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(levelButton)
        
        let zoneButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
        zoneButton.backgroundColor = UIColor.grayColor()
        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        zoneButton.setTitle("All", forState: UIControlState.Normal)
        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        zoneButton.layer.cornerRadius = 5
        zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        zoneButton.layer.borderWidth = 1
        zoneButton.tag = 3
        zoneButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(zoneButton)
        
        let categoryButton:UIButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
        categoryButton.backgroundColor = UIColor.grayColor()
        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        categoryButton.setTitle("All", forState: UIControlState.Normal)
        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        categoryButton.layer.cornerRadius = 5
        categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        categoryButton.layer.borderWidth = 1
        categoryButton.tag = 4
        categoryButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        pullDown.addSubview(categoryButton)
    }
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    func menuTable(sender : UIButton){
        senderButton = sender
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = sender.tag
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    
    func saveText (text : String, id:Int) {
        let tag = senderButton!.tag
        switch tag {
        case 1:
            locationSearch = text
        case 2:
            if id == -1 {
                levelSearch = "All"
            } else {
                levelSearch = "\(id)"
            }
        case 3:
            if id == -1 {
                zoneSearch = "All"
            } else {
                zoneSearch = "\(id)"
            }
        case 4:
            if id == -1 {
                categorySearch = "All"
            } else {
                categorySearch = "\(id)"
            }
        default:
            print("")
        }
        senderButton?.setTitle(text, forState: .Normal)
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func refreshFlagList () {
        updateFlagsList()
        flagsCollectionView.reloadData()
    }
    func updateFlagsList () {
        let fetchRequest = NSFetchRequest(entityName: "Flag")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
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
//                showFlagParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - flagsCollectionView.contentOffset.y), timer: flags[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlagCollectionViewCell
        cell.flagTitle.text = "\(flags[indexPath.row].flagName)"
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
        longPress.minimumPressDuration = 0.5
        cell.flagTitle.userInteractionEnabled = true
        cell.flagTitle.addGestureRecognizer(longPress)
        
        if let flagImage = UIImage(data: flags[indexPath.row].flagImageOne) {
            cell.flagImageView.image = flagImage
        }
        
        if let flagImage = UIImage(data: flags[indexPath.row].flagImageTwo) {
            cell.flagImageView.highlightedImage = flagImage
        }
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
        cell.flagButton.tag = indexPath.row
        cell.flagButton.addGestureRecognizer(tap)
        if flags[indexPath.row].setState.boolValue {
            cell.flagButton.setTitle("Set False", forState: UIControlState.Normal)
        } else {
            cell.flagButton.setTitle("Set True", forState: UIControlState.Normal)
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if let flagId = flags[tag].flagId as? Int {
            var address:[UInt8] = []
            if flags[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else {
                address = [UInt8(Int(flags[tag].gateway.addressOne)), UInt8(Int(flags[tag].gateway.addressTwo)), UInt8(Int(flags[tag].address))]
            }
            if flags[tag].setState.boolValue {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
            } else {
                SendingHandler.sendCommand(byteArray: Function.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
            }
        }
    }
}
class FlagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var flagTitle: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var flagButton: UIButton!
    
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
