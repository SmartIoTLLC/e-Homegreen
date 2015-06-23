//
//  DevicesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class DeviceImage:NSObject{
    var image:UIImage!
    var text:String!
    
    init(image:UIImage, text:String) {
        self.image = image
        self.text = text
    }
    
}

class DevicesViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    private let reuseIdentifier = "deviceCell"
    let collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    
    var table:UITableView = UITableView()
    
    var levelList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    var zoneList:[String] = ["Zone 1", "Zone 2", "Zone 3", "All"]
    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    
    var device:DeviceImage = DeviceImage(image: UIImage(named: "lightBulb")!, text: "Light")
    
    var senderButton:UIButton?
    
    @IBOutlet weak var deviceCollectionView: UICollectionView!
    
    var myView:Array<UIView> = []
    var mySecondView:Array<UIView> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonConstruct()
        
        
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)

        
        
        for i in 0...6 {
            var gradient:CAGradientLayer = CAGradientLayer()
            gradient.frame = CGRectMake(0, 0, collectionViewCellSize.width, collectionViewCellSize.height)
            gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
            var gradientSecond:CAGradientLayer = CAGradientLayer()
            gradientSecond.frame = CGRectMake(0, 0, collectionViewCellSize.width, collectionViewCellSize.height)
            gradientSecond.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
            var myViewIterator = UIView()
            myViewIterator.frame = CGRectMake(0, 0, collectionViewCellSize.width, collectionViewCellSize.height)
            //            myViewIterator.backgroundColor = UIColor.yellowColor()
            myViewIterator.tag = i
            myViewIterator.layer.cornerRadius = 5
            myViewIterator.layer.borderColor = UIColor.grayColor().CGColor
            myViewIterator.layer.borderWidth = 0.5
            myViewIterator.layer.insertSublayer(gradient, atIndex: 0)
            myViewIterator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
            myView.append(myViewIterator)
            
            var mySecondViewIterator = UIView()
            mySecondViewIterator.frame = CGRectMake(0, 0, collectionViewCellSize.width, collectionViewCellSize.height)
            //            mySecondViewIterator.backgroundColor = UIColor.greenColor()
            mySecondViewIterator.tag = i
            mySecondViewIterator.layer.cornerRadius = 5
            mySecondViewIterator.layer.borderColor = UIColor.grayColor().CGColor
            mySecondViewIterator.layer.borderWidth = 0.5
            mySecondViewIterator.layer.insertSublayer(gradient, atIndex: 0)
            mySecondViewIterator.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap2:"))
            mySecondView.append(mySecondViewIterator)
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            
            sectionInsets = UIEdgeInsets(top: 10, left: 25, bottom: 5, right: 25)
            
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
            
            var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            levelLabel.text = "LVL"
            levelLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(levelLabel)
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
            categoryLabel.text = "Category"
            categoryLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(categoryLabel)
            
            var levelButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            levelButton.backgroundColor = UIColor.grayColor()
            levelButton.titleLabel?.tintColor = UIColor.whiteColor()
            levelButton.setTitle("All", forState: UIControlState.Normal)
            levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            levelButton.layer.cornerRadius = 5
            levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            levelButton.layer.borderWidth = 0.5
            levelButton.addTarget(self, action: "menuLevel:", forControlEvents: UIControlEvents.TouchUpInside)
            levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(levelButton)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
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
            
            var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
            categoryButton.backgroundColor = UIColor.grayColor()
            categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
            categoryButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            categoryButton.layer.cornerRadius = 5
            categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            categoryButton.layer.borderWidth = 0.5
            categoryButton.addTarget(self, action: "menuCategory:", forControlEvents: UIControlEvents.TouchUpInside)
            categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(categoryButton)
            
            table.delegate = self
            table.dataSource = self
            table.frame = CGRectMake(0, 0, 150, 150)
            table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.hidden = true
            pullDown.addSubview(table)
            deviceCollectionView.reloadData()
            
        } else {
            
            sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            
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
            
            var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            levelLabel.text = "LVL"
            levelLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(levelLabel)
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
            categoryLabel.text = "Category"
            categoryLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(categoryLabel)
            
            var levelButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            levelButton.backgroundColor = UIColor.grayColor()
            levelButton.titleLabel?.tintColor = UIColor.whiteColor()
            levelButton.setTitle("All", forState: UIControlState.Normal)
            levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            levelButton.layer.cornerRadius = 5
            levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            levelButton.layer.borderWidth = 0.5
            levelButton.addTarget(self, action: "menuLevel:", forControlEvents: UIControlEvents.TouchUpInside)
            levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(levelButton)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
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
            
            var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
            categoryButton.backgroundColor = UIColor.grayColor()
            categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
            categoryButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            categoryButton.layer.cornerRadius = 5
            categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            categoryButton.layer.borderWidth = 0.5
            categoryButton.addTarget(self, action: "menuCategory:", forControlEvents: UIControlEvents.TouchUpInside)
            categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(categoryButton)
            
            table.delegate = self
            table.dataSource = self
            table.frame = CGRectMake(0, 0, 150, 150)
            table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.hidden = true
            pullDown.addSubview(table)
            deviceCollectionView.reloadData()
            
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
    
    func menuLevel(sender : UIButton){
        senderButton = sender
        table.frame = CGRectMake(110, 70, 150, 160)
        table.hidden = false
        tableList.removeAll(keepCapacity: false)
        tableList = levelList
        table.reloadData()
    }
    
    func menuZone(sender : UIButton){
        senderButton = sender
        table.frame = CGRectMake(110, 120, 150, 160)
        table.hidden = false
        tableList.removeAll(keepCapacity: false)
        tableList = zoneList
        table.reloadData()
        
    }
    
    func menuCategory(sender : UIButton){
        senderButton = sender
        table.frame = CGRectMake(110, 170, 150, 160)
        table.hidden = false
        tableList.removeAll(keepCapacity: false)
        tableList = categoryList
        table.reloadData()
    }
    
    func handleTap (gesture:UIGestureRecognizer) {
        println("!!! \(gesture.view!.tag)")
        UIView.transitionFromView(myView[gesture.view!.tag], toView: mySecondView[gesture.view!.tag], duration: 1, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
        //        UIView.transitionWithView(mySecondView, duration: 1, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: nil, completion: nil)
    }
    
    func handleTap2 (gesture:UIGestureRecognizer) {
        println("!!! \(gesture.view!.tag)")
        UIView.transitionFromView(mySecondView[gesture.view!.tag], toView: myView[gesture.view!.tag], duration: 1, options: UIViewAnimationOptions.TransitionFlipFromBottom, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeSliderValue(sender: UISlider){
        println(sender.value)
        if sender.value >= 0 && sender.value < 0.1{
            device.image = UIImage(named: "lightBulb1")

        }else if sender.value > 0.1 && sender.value < 0.2{
            device.image = UIImage(named: "lightBulb2")

        }else if sender.value > 0.2 && sender.value < 0.3 {
            device.image = UIImage(named: "lightBulb3")

        }else if sender.value > 0.3 && sender.value < 0.4 {
            device.image = UIImage(named: "lightBulb4")

        }else if sender.value > 0.4 && sender.value < 0.5 {
            device.image = UIImage(named: "lightBulb5")

        }else if sender.value > 0.5 && sender.value < 0.6 {
            device.image = UIImage(named: "lightBulb6")

        }else if sender.value > 0.6 && sender.value < 0.7 {
            device.image = UIImage(named: "lightBulb7")

        }else if sender.value > 0.7 && sender.value < 0.8 {
            device.image = UIImage(named: "lightBulb8")

        }else if sender.value > 0.8 && sender.value < 0.9{
            device.image = UIImage(named: "lightBulb9")

        }else{
            device.image = UIImage(named: "lightBulb10")

        }
        
        deviceCollectionView.reloadData()
        
    }
    
    
    
    
}
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(myView)
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(mySecondView)
        println(" ")
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}
extension DevicesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DeviceCollectionCell
            //2
            //        let flickrPhoto = photoForIndexPath(indexPath)
            cell.backgroundColor = UIColor.lightGrayColor()
            //3
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.typeOfLight.text = device.text
            cell.picture.image = device.image
            cell.lightSlider.addTarget(self, action: "changeSliderValue:", forControlEvents: .ValueChanged)
            cell.lightSlider.tag = indexPath.row
            //        cell.addSubview(myView[indexPath.row])
            //        cell.addSubview(mySecondView[indexPath.row])
//            println("Broj: \(indexPath.row)")
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
        //2
        //        let flickrPhoto = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.lightGrayColor()
        //3
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        cell.name.text = "Coffee Machine"
        //            cell.addSubview(myView[indexPath.row])
        //            cell.addSubview(mySecondView[indexPath.row])
//        println("Broj: \(indexPath.row)")
        return cell
        
        
    }
}
class DeviceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var typeOfLight: UILabel!    
    @IBOutlet weak var picture: UIImageView!    
    @IBOutlet weak var lightSlider: UISlider!
    
}

class ApplianceCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!    
    @IBOutlet weak var image: UIImageView!

    
}
