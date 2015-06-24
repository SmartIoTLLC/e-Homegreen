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
    var open:Bool!
    
    init(image:UIImage, text:String) {
        self.image = image
        self.text = text
        self.open = false
    }
    
}

class DevicesViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    private let reuseIdentifier = "deviceCell"
    let collectionViewCellSize = CGSize(width: 150, height: 180)
    var pullDown = PullDownView()
    
    var table:UITableView = UITableView()
    
    var locationList:[String] = ["All"]
    var levelList:[String] = ["Level 1", "All"]
    var zoneList:[String] = ["Zone 1", "Zone 2", "All"]
    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    
    var device:DeviceImage = DeviceImage(image: UIImage(named: "lightBulb")!, text: "Light")
    var device1:DeviceImage = DeviceImage(image: UIImage(named: "curtain0")!, text: "Curtain")
    var device2:DeviceImage = DeviceImage(image: UIImage(named: "applianceoff")!, text: "Coffee Machine")
    var device3:DeviceImage = DeviceImage(image: UIImage(named: "doorclosed")!, text: "Garage door")
    
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

        
        
        for i in 0...2 {
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
            
            var locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            locationLabel.text = "Location"
            locationLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(locationLabel)
            
            var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
            levelLabel.text = "Level"
            levelLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(levelLabel)
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
            categoryLabel.text = "Category"
            categoryLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(categoryLabel)
            
            var locationButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            locationButton.backgroundColor = UIColor.grayColor()
            locationButton.titleLabel?.tintColor = UIColor.whiteColor()
            locationButton.setTitle("All", forState: UIControlState.Normal)
            locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            locationButton.layer.cornerRadius = 5
            locationButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            locationButton.layer.borderWidth = 0.5
            locationButton.tag = 1
            locationButton.addTarget(self, action: "menuLocation:", forControlEvents: UIControlEvents.TouchUpInside)
            locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(locationButton)
            
            var levelButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
            levelButton.backgroundColor = UIColor.grayColor()
            levelButton.titleLabel?.tintColor = UIColor.whiteColor()
            levelButton.setTitle("All", forState: UIControlState.Normal)
            levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            levelButton.layer.cornerRadius = 5
            levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            levelButton.layer.borderWidth = 0.5
            levelButton.tag = 1
            levelButton.addTarget(self, action: "menuLevel:", forControlEvents: UIControlEvents.TouchUpInside)
            levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(levelButton)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
            zoneButton.backgroundColor = UIColor.grayColor()
            zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            zoneButton.layer.cornerRadius = 5
            zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            zoneButton.layer.borderWidth = 0.5
            zoneButton.tag = 1
            zoneButton.addTarget(self, action: "menuZone:", forControlEvents: UIControlEvents.TouchUpInside)
            zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(zoneButton)
            
            var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
            categoryButton.backgroundColor = UIColor.grayColor()
            categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
            categoryButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            categoryButton.layer.cornerRadius = 5
            categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            categoryButton.layer.borderWidth = 0.5
            categoryButton.tag = 1
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
            
            var locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
            locationLabel.text = "Location"
            locationLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(locationLabel)
            
            var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
            levelLabel.text = "Level"
            levelLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(levelLabel)
            
            var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
            zoneLabel.text = "Zone"
            zoneLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(zoneLabel)
            
            var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
            categoryLabel.text = "Category"
            categoryLabel.textColor = UIColor.whiteColor()
            pullDown.addSubview(categoryLabel)
            
            var locationButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
            locationButton.backgroundColor = UIColor.grayColor()
            locationButton.titleLabel?.tintColor = UIColor.whiteColor()
            locationButton.setTitle("All", forState: UIControlState.Normal)
            locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            locationButton.layer.cornerRadius = 5
            locationButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            locationButton.layer.borderWidth = 0.5
            locationButton.tag = 2
            locationButton.addTarget(self, action: "menuLocation:", forControlEvents: UIControlEvents.TouchUpInside)
            locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(locationButton)
            
            var levelButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
            levelButton.backgroundColor = UIColor.grayColor()
            levelButton.titleLabel?.tintColor = UIColor.whiteColor()
            levelButton.setTitle("All", forState: UIControlState.Normal)
            levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            levelButton.layer.cornerRadius = 5
            levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            levelButton.layer.borderWidth = 0.5
            levelButton.tag = 2
            levelButton.addTarget(self, action: "menuLevel:", forControlEvents: UIControlEvents.TouchUpInside)
            levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(levelButton)
            
            var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
            zoneButton.backgroundColor = UIColor.grayColor()
            zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            zoneButton.layer.cornerRadius = 5
            zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            zoneButton.layer.borderWidth = 0.5
            zoneButton.tag = 2
            zoneButton.addTarget(self, action: "menuZone:", forControlEvents: UIControlEvents.TouchUpInside)
            zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            pullDown.addSubview(zoneButton)
            
            var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
            categoryButton.backgroundColor = UIColor.grayColor()
            categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
            categoryButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            categoryButton.layer.cornerRadius = 5
            categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            categoryButton.layer.borderWidth = 0.5
            categoryButton.tag = 2
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func menuLocation(sender : UIButton){
        if table.hidden == true{
            senderButton = sender
            var height:CGFloat
            if locationList.count * 40 < 160{
                height = CGFloat(locationList.count * 40)
            }else{
                height = 160
            }
            if sender.tag == 1 {
                table.frame = CGRectMake(260, 30, 150, height)
            }else{
                table.frame = CGRectMake(110, 70, 150, height)
            }
            table.hidden = false
            tableList.removeAll(keepCapacity: false)
            tableList = locationList
            table.reloadData()
        }else{
            table.hidden = true
        }
    }
    
    func menuLevel(sender : UIButton){
        if table.hidden == true{
            senderButton = sender
            var height:CGFloat
            if levelList.count * 40 < 160{
                height = CGFloat(levelList.count * 40)
            }else{
                height = 160
            }
            if sender.tag == 1 {
                table.frame = CGRectMake(260, 30, 150, height)
            }else{
                table.frame = CGRectMake(110, 120, 150, height)
            }
            table.hidden = false
            tableList.removeAll(keepCapacity: false)
            tableList = levelList
            table.reloadData()
        }else{
            table.hidden = true
        }
    }
    
    func menuZone(sender : UIButton){
        if table.hidden == true{
            senderButton = sender
            var height:CGFloat
            if zoneList.count * 40 < 160{
                height = CGFloat(zoneList.count * 40)
            }else{
                height = 160
            }
            if sender.tag == 1 {
                table.frame = CGRectMake(260, 60, 150, height)
            }else{
                table.frame = CGRectMake(110, 170, 150, height)
            }
            table.hidden = false
            tableList.removeAll(keepCapacity: false)
            tableList = zoneList
            table.reloadData()
        }else{
            table.hidden = true
        }
        
    }
    
    func menuCategory(sender : UIButton){
        if table.hidden == true{
            senderButton = sender
            var height:CGFloat
            if categoryList.count * 40 < 160{
                height = CGFloat(categoryList.count * 40)
            }else{
                height = 160
            }
            if sender.tag == 1 {
                table.frame = CGRectMake(260, 60, 150, height)
            }else{
                table.frame = CGRectMake(110, 220, 150, height)
            }
            table.hidden = false
            tableList.removeAll(keepCapacity: false)
            tableList = categoryList
            table.reloadData()
        }else{
            table.hidden = true
        }
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
//        println(sender.value)
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
    
    func changeSliderValue1(sender: UISlider){
//        println(sender.value)
        if sender.value >= 0 && sender.value < 0.2{
            device1.image = UIImage(named: "curtain0")
            
        }else if sender.value > 0.2 && sender.value < 0.4{
            device1.image = UIImage(named: "curtain1")
            
        }else if sender.value > 0.4 && sender.value < 0.6 {
            device1.image = UIImage(named: "curtain2")
            
        }else if sender.value > 0.6 && sender.value < 0.8 {
            device1.image = UIImage(named: "curtain3")
            
        }else {
            device1.image = UIImage(named: "curtain4")
            
        }
        
        deviceCollectionView.reloadData()
        
    }
    
    func buttonTapped(sender:UIButton){
        if sender.tag == 2{
            if device2.open == false {
                device2.open = true
                
            }else{
                device2.open = false
            }
            deviceCollectionView.reloadData()
        }
    }
    
    
    
    
}
extension DevicesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(myView)
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(mySecondView)
        if indexPath.row == 4{
            if device3.open == false{
                device3.open = true
            }else{
                device3.open = false
            }
            deviceCollectionView.reloadData()
        }
        
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
        return 5
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
        
        else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("curtainCell", forIndexPath: indexPath) as! CurtainCollectionCell
            //2
            //        let flickrPhoto = photoForIndexPath(indexPath)
            cell.backgroundColor = UIColor.lightGrayColor()
            //3
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.curtainName.text = device1.text
            cell.curtainImage.image = device1.image
            cell.curtainSlider.addTarget(self, action: "changeSliderValue1:", forControlEvents: .ValueChanged)
            cell.curtainSlider.tag = indexPath.row
            //        cell.addSubview(myView[indexPath.row])
            //        cell.addSubview(mySecondView[indexPath.row])
            //            println("Broj: \(indexPath.row)")
            return cell
        }
        

       else if indexPath.row == 2 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("applianceCell", forIndexPath: indexPath) as! ApplianceCollectionCell
            cell.backgroundColor = UIColor.lightGrayColor()
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.name.text = device2.text
            if device2.open == false {
                cell.image.image = UIImage(named: "applianceoff")
                cell.button.setTitle("OFF", forState: UIControlState.Normal)
            }else{
                cell.image.image = UIImage(named: "applianceon")
                cell.button.setTitle("ON", forState: UIControlState.Normal)
            }
            cell.button.addTarget(self, action: "buttonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.button.tag = 2
            //            cell.addSubview(myView[indexPath.row])
            //            cell.addSubview(mySecondView[indexPath.row])
            //        println("Broj: \(indexPath.row)")
            return cell
            
        }else if indexPath.row == 3 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("climaCell", forIndexPath: indexPath) as! ClimateCell

            cell.backgroundColor = UIColor.lightGrayColor()
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5


            return cell
            
        }
        
        else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("accessCell", forIndexPath: indexPath) as! AccessControllCell
            cell.backgroundColor = UIColor.lightGrayColor()
            cell.layer.cornerRadius = 5
            cell.layer.borderColor = UIColor.grayColor().CGColor
            cell.layer.borderWidth = 0.5
            cell.accessLabel.text = device3.text
            if device3.open == false {
                cell.accessImage.image = UIImage(named: "doorclosed")
            }else{
                cell.accessImage.image = UIImage(named: "dooropen")
            }
            return cell
            
        }
        
        
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
    @IBOutlet weak var button: UIButton!
    
}

class CurtainCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    
}

class AccessControllCell: UICollectionViewCell {
    
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
    
}

class ClimateCell: UICollectionViewCell {
    
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var coolingSetPoint: UILabel!
    @IBOutlet weak var heatingSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!    
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    
}
