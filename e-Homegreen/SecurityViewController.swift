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
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SecurityCell"
    
    var securities:[Security] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var lblAlarmState: UILabel!
    

    @IBOutlet weak var securityCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Do any additional setup after loading the view.
        
        updateSecurityList()
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
    func didSelectCell (tag:Int) {
//        if tag == 0 {
//            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode([0x00, 0x00, 0x00], mode: 0x01), gateway: Gateway())
//        }
//        if tag == 1 {
//            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode([0x00, 0x00, 0x00], mode: 0x02), gateway: Gateway())
//        }
//        if tag == 2 {
//            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode([0x00, 0x00, 0x00], mode: 0x03), gateway: Gateway())
//        }
//        if tag == 3 {
//            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode([0x00, 0x00, 0x00], mode: 0x04), gateway: Gateway())
//        }
//        if tag == 4 {
//            SendingHandler.sendCommand(byteArray: Function.changeSecurityMode([0x00, 0x00, 0x00], mode: 0x04), gateway: Gateway())
//        }
//        if tag == 5 {
//            
//        }
    }

}
extension SecurityViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
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
        let gradient:CAGradientLayer = CAGradientLayer()
        cell.securityTitle.text = "\(securities[indexPath.row].name)"
        cell.securityImageView.image = UIImage(named: "maaa")
        cell.securityButton.setTitle("ARG", forState: UIControlState.Normal)
        switch securities[indexPath.row].name {
        case "Away":
            cell.securityImageView.image = UIImage(named: "away")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
//            cell.
            cell.securityButton.tag = indexPath.row
        case "Night":
            cell.securityImageView.image = UIImage(named: "night")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
        case "Day":
            cell.securityImageView.image = UIImage(named: "day")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
        case "Vacation":
            cell.securityImageView.image = UIImage(named: "vacation")
            cell.securityButton.setTitle("ARM", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
        case "Disarm":
            cell.securityImageView.image = UIImage(named: "disarm")
            cell.securityButton.setTitle("ENTER CODE", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
        case "Panic":
            cell.securityImageView.image = UIImage(named: "panic")
            cell.securityButton.setTitle("TRIGGER", forState: UIControlState.Normal)
            cell.securityButton.tag = indexPath.row
        default:
            print("")
        }
        gradient.frame = CGRectMake(0, 0, 150, 150)
        gradient.colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        cell.layer.insertSublayer(gradient, atIndex: 0)
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
    
}
