//
//  PCControlViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class PCControlViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var sidebarMenuOpen : Bool!
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    
    @IBOutlet weak var pccontrolCollectionView: UICollectionView!
    var pcs:[Device] = []
    var appDel:AppDelegate?
    
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
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        // Not sending zones and categories
        pcs = fetchSortedPCRequest("", parentZone: 1, zone: 1, category: 1)
        pccontrolCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        // Do any additional setup after loading the view.
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            pccontrolCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            pccontrolCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            pccontrolCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            pccontrolCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }

    
    func fetchSortedPCRequest (gatewayName:String, parentZone:Int, zone:Int, category:Int) -> [Device] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Device")
        //        let predicate = NSPredicate(format: "gateway.name == %@", gatewayName)
        let predicateOne = NSPredicate(format: "type == %@", ControlType.PC)
        //        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateOne])
        let predicateArray = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateOne])
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        let sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        fetchRequest.predicate = predicateArray
        do {
            let fetResults = try appDel!.managedObjectContext!.executeFetchRequest(fetchRequest) as! [Device]
            return fetResults
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        return []
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pccontrolCell", forIndexPath: indexPath) as? PCControlCell{
            cell.setItem(pcs[indexPath.row], tag: indexPath.row)
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pcs.count
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showPCInterface(pcs[indexPath.row])
    }
    
    @IBAction func changeSliderValue(sender: AnyObject) {
        guard let slider = sender as? UISlider else {
            return
        }
        guard let tag = sender.tag else {
            return
        }
        let address = [Byte(Int(pcs[tag].gateway.addressOne)), Byte(Int(pcs[tag].gateway.addressTwo)), Byte(Int(pcs[tag].address))]
        let value = Byte(Int(slider.value * 100))
        if value == 0x00 {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: pcs[tag].pcVolume, mute: 0x01), gateway: pcs[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: value), gateway: pcs[tag].gateway)
            pcs[tag].pcVolume = value
        }
    }

}
