//
//  SecurityViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SecurityViewController: CommonViewController {
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SecurityCell"
    var pullDown = PullDownView()
    
    var securities:[Security] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var lblAlarmState: UILabel!
    

    @IBOutlet weak var securityCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        //        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSecurity", name: "refreshSecurityNotification", object: nil)
        
        refreshSecurity()
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
    }
    func refreshSecurity () {
        updateSecurityList()
        refreshSecurityAlarmStateAndSecurityMode()
    }
    func refreshSecurityAlarmStateAndSecurityMode () {
        let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
        if let gateway = securities[0].gateway {
            SendingHandler.sendCommand(byteArray: Function.getCurrentAlarmState(address), gateway: gateway)
            SendingHandler.sendCommand(byteArray: Function.getCurrentSecurityMode(address), gateway: gateway)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSecurityList () {
        let fetchRequest = NSFetchRequest(entityName: "Security")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Security]
            securities = fetResults!
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
    
//    ima: adresu, gateway, alarm state, naziv
    func buttonPressed (gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        if tag == 0 {
//            if gestureRecognizer.state == UIGestureRecognizerState.Began {
                let location = gestureRecognizer.locationInView(securityCollectionView)
                if let index = securityCollectionView.indexPathForItemAtPoint(location){
                    let cell = securityCollectionView.cellForItemAtIndexPath(index)
                    showSecurityCommand(CGPoint(x: cell!.center.x, y: cell!.center.y - securityCollectionView.contentOffset.y), text:securities[tag].modeExplanation)
                }
//            }
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x01), gateway: gateway)
            }
        }
        if tag == 1 {
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x02), gateway: gateway)
            }
        }
        if tag == 2 {
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x03), gateway: gateway)
            }
        }
        if tag == 3 {
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.changeSecurityMode(address, mode: 0x04), gateway: gateway)
            }
        }
        if tag == 4 {
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x00), gateway: gateway)
                SendingHandler.sendCommand(byteArray: Function.sendKeySecurity(address, key: 0x00), gateway: gateway)
            }
        }
        if tag == 5 {
            let address:[UInt8] = [UInt8(Int(securities[0].addressOne)), UInt8(Int(securities[0].addressTwo)), UInt8(Int(securities[0].addressThree))]
            if let gateway = securities[0].gateway {
                SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x00), gateway: gateway)
                SendingHandler.sendCommand(byteArray: Function.setPanic(address, panic: 0x01), gateway: gateway)
            }
        }
    }

}
extension SecurityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension SecurityViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return securities.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SecurityCollectionCell
//        let gradient:CAGradientLayer = CAGradientLayer()
        cell.securityTitle.text = "\(securities[indexPath.row].name)"
        cell.securityImageView.image = UIImage(named: "maaa")
        cell.securityButton.setTitle("ARG", forState: UIControlState.Normal)
        switch securities[indexPath.row].name {
        case "Away":
            cell.securityImageView.image = UIImage(named: "away")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "buttonPressed:")
            cell.securityButton.addGestureRecognizer(tap)
        case "Night":
            cell.securityImageView.image = UIImage(named: "night")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.securityButton.tag = indexPath.row
        case "Day":
            cell.securityImageView.image = UIImage(named: "day")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.securityButton.tag = indexPath.row
        case "Vacation":
            cell.securityImageView.image = UIImage(named: "vacation")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.securityButton.tag = indexPath.row
        case "Disarm":
            cell.securityImageView.image = UIImage(named: "disarm")
            cell.securityButton.setTitle("ENTER CODE", forState: UIControlState.Normal)
            cell.securityButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.securityButton.tag = indexPath.row
        case "Panic":
            cell.securityImageView.image = UIImage(named: "panic")
            cell.securityButton.setTitle("TRIGGER", forState: UIControlState.Normal)
            cell.securityButton.addTarget(self, action: "buttonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.securityButton.tag = indexPath.row
        default:
            print("")
        }
//        gradient.frame = CGRectMake(0, 0, 150, 150)
//        gradient.colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
//        cell.layer.insertSublayer(gradient, atIndex: 0)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}
class SecurityCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var securityTitle: UILabel!
    @IBOutlet weak var securityImageView: UIImageView!
    @IBOutlet weak var securityButton: UIButton!
    
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
