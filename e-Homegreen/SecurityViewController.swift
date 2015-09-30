//
//  SecurityViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityViewController: CommonViewController {
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SecurityCell"

    @IBOutlet weak var securityCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        Function.sendKeySecurity([0x00, 0x01], key: 0xFF)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return 6
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SecurityCollectionCell
        let gradient:CAGradientLayer = CAGradientLayer()
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
    
    
    @IBOutlet weak var securityCellLabel: UILabel!
    @IBOutlet weak var securityCellImageView: UIImageView!
    
}
