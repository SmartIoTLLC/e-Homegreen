//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScenesViewController: CommonViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    

    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SceneCell"
    var pullDown = PullDownView()
    
//    var table:UITableView = UITableView()
    
    var zoneList:[String] = ["Zone 1", "Zone 2", "Zone 3", "All"]
    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    var appDel:AppDelegate!
    var scenes:[Scene] = []
    var error:NSError? = nil
    
    var senderButton:UIButton?
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    
    @IBOutlet weak var scenesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        commonConstruct()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        updateSceneList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSceneList", name: "refreshSceneListNotification", object: nil)
        // Do any additional setup after loading the view.
    }
    func refreshSceneList () {
        updateSceneList()
        scenesCollectionView.reloadData()
    }
    func updateSceneList () {
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            scenes = fetResults!
        } catch  {
            
        }
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
//        if let results = fetResults {
//            scenes = results
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
    
    override func viewWillLayoutSubviews() {
        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
            
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
   
        } else {
            
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
            
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

        }
        drawMenu()
        scenesCollectionView.reloadData()
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
        var address:[UInt8] = []
        if scenes[indexPath.row].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(scenes[indexPath.row].gateway.addressOne)), UInt8(Int(scenes[indexPath.row].gateway.addressTwo)), UInt8(Int(scenes[indexPath.row].address))]
        }
        let sceneId = Int(scenes[indexPath.row].sceneId)
        if sceneId >= 0 && sceneId <= 255 {
            SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scenes[indexPath.row].sceneId)), gateway: scenes[indexPath.row].gateway)
        }
        scenesCollectionView.reloadData()
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {        return collectionViewCellSize
    }
}

extension ScenesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneCollectionCell
        
        cell.sceneCellLabel.text = "\(scenes[indexPath.row].sceneName)"
        cell.sceneCellLabel.tag = indexPath.row
        cell.sceneCellLabel.userInteractionEnabled = true
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
        longPress.minimumPressDuration = 0.5
        cell.sceneCellLabel.addGestureRecognizer(longPress)
        
        if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageOne) {
            cell.sceneCellImageView.image = sceneImage
        }
        
        if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageTwo) {
            cell.sceneCellImageView.highlightedImage = sceneImage
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItemAtPoint(location){
                let cell = scenesCollectionView.cellForItemAtIndexPath(index)
                showSceneParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - scenesCollectionView.contentOffset.y), scene: scenes[tag])
            }
        }
        
    }
}


class SceneCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var sceneCellLabel: UILabel!
    @IBOutlet weak var sceneCellImageView: UIImageView!
    
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
