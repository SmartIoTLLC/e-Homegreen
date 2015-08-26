//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScenesViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SceneCell"
    var pullDown = PullDownView()
    
    var table:UITableView = UITableView()
    
    var zoneList:[String] = ["Zone 1", "Zone 2", "Zone 3", "All"]
    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    
    var senderButton:UIButton?
    
    @IBOutlet weak var scenesCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        commonConstruct()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        
        // Do any additional setup after loading the view.
    }
    func updateDeviceList () {
        println("ovde je uslo")
        var fetchRequest = NSFetchRequest(entityName: "Device")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "address", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "type", ascending: true)
        var sortDescriptorFour = NSSortDescriptor(key: "channel", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree, sortDescriptorFour]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            println("ovde je uslo 2")
            devices = results
        } else {
            println("ovde je uslo 3")
        }
        println("ovde je izaslo")
    }
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    override func viewWillLayoutSubviews() {
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
            
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            zoneButton.backgroundColor = UIColor.grayColor()
            zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            zoneButton.layer.cornerRadius = 5
            zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            zoneButton.layer.borderWidth = 0.5
            zoneButton.addTarget(self, action: "menuZone:", forControlEvents: UIControlEvents.TouchUpInside)
            zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(zoneButton)
            
            table.delegate = self
            table.dataSource = self
            table.frame = CGRectMake(0, 0, 150, 150)
            table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.hidden = true
            pullDown.addSubview(table)
            
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
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            zoneButton.backgroundColor = UIColor.grayColor()
            zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            zoneButton.layer.cornerRadius = 5
            zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            zoneButton.layer.borderWidth = 0.5
            zoneButton.addTarget(self, action: "menuZone:", forControlEvents: UIControlEvents.TouchUpInside)
            zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(zoneButton)
            
            table.delegate = self
            table.dataSource = self
            table.frame = CGRectMake(0, 0, 150, 150)
            table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.hidden = true
            pullDown.addSubview(table)
            
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        //        if let tableString = tableList[indexPath.row] as String {
        cell.textLabel?.text = tableList[indexPath.row]
        //        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableList.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        senderButton!.setTitle(tableList[indexPath.row], forState: UIControlState.Normal)
        table.hidden = true
    }

    
    func menuZone(sender : UIButton){
        senderButton = sender
        table.frame = CGRectMake(110, 70, 150, 160)
        table.hidden = false
        tableList.removeAll(keepCapacity: false)
        tableList = zoneList
        table.reloadData()
        
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

}
extension ScenesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(myView)
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(mySecondView)
        println(" ")
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 150, height: 150)
    }
}

extension ScenesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneCollectionCell
        //2
        //        let flickrPhoto = photoForIndexPath(indexPath)
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 150, 150)
        gradient.colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        cell.layer.insertSublayer(gradient, atIndex: 0)
//        cell.backgroundColor = UIColor.lightGrayColor()
        //3
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}


class SceneCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var sceneCellLabel: UILabel!
    @IBOutlet weak var sceneCellImageView: UIImageView!
    
    
}
