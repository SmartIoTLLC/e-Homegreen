//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScenesViewController: CommonViewController, PullDownViewDelegate, UIPopoverPresentationControllerDelegate {
    

    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SceneCell"
    var pullDown = PullDownView()
    
//    var table:UITableView = UITableView()
    
    var appDel:AppDelegate!
    var scenes:[Scene] = []
    var error:NSError? = nil
    
    var senderButton:UIButton?
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    
    
    @IBOutlet weak var scenesCollectionView: UICollectionView!
    
    var locationSearchText = ["", "", "", "", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (gateway, level, zone, category, levelName, zoneName, categoryName)
        updateSceneList()
        scenesCollectionView.reloadData()
        LocalSearchParametar.setLocalParametar("Scenes", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName])
        locationSearchText = LocalSearchParametar.getLocalParametar("Scenes")
//        LocalSearchParametar.setLocalParametar("Scenes", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        commonConstruct()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        locationSearchText = LocalSearchParametar.getLocalParametar("Scenes")
        updateSceneList()
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        // Do any additional setup after loading the view.
    }
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Scenes")
        (locationSearch, levelSearch, zoneSearch, categorySearch, levelSearchName, zoneSearchName, categorySearchName) = (locationSearchText[0], locationSearchText[1], locationSearchText[2], locationSearchText[3], locationSearchText[4], locationSearchText[5], locationSearchText[6])
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
        updateSceneList()
        scenesCollectionView.reloadData()
    }
    func refreshSceneList() {
        updateSceneList()
        scenesCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        refreshSceneList()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSceneList", name: NotificationKey.RefreshScene, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshScene, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    func returnZoneWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnCategoryWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func updateSceneList () {
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        var predicateArray:[NSPredicate] = [predicateOne]
//        if levelSearch != "All" {
//            let levelPredicate = NSPredicate(format: "entityLevel == %@", returnZoneWithId(Int(levelSearch)!))
//            predicateArray.append(levelPredicate)
//        }
//        if zoneSearch != "All" {
//            let zonePredicate = NSPredicate(format: "sceneZone == %@", returnZoneWithId(Int(zoneSearch)!))
//            predicateArray.append(zonePredicate)
//        }
//        if categorySearch != "All" {
//            let categoryPredicate = NSPredicate(format: "sceneCategory == %@", returnCategoryWithId(Int(categorySearch)!))
//            predicateArray.append(categoryPredicate)
//        }
        if locationSearch != "All" {
            let locationPredicate = NSPredicate(format: "gateway.name == %@", locationSearch)
            predicateArray.append(locationPredicate)
        }
        if levelSearch != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelSearchName)
            predicateArray.append(levelPredicate)
        }
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "sceneZone == %@", zoneSearchName)
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "sceneCategory == %@", categorySearchName)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            scenes = fetResults!
        } catch  {
            
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
//            if self.view.frame.size.width == 568{
//                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
//            }else if self.view.frame.size.width == 667{
//                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
//            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
        } else {
//            if self.view.frame.size.width == 320{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }else if self.view.frame.size.width == 375{
//                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//            }else{
//                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//            }
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        scenesCollectionView.reloadData()
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[4], zone: locationSearchText[5], category: locationSearchText[6], locationSearch: locationSearchText)
    }
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    var zoneSearchName:String = "All"
    var levelSearchName:String = "All"
    var categorySearchName:String = "All"
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension ScenesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        var address:[UInt8] = []
//        if scenes[indexPath.row].isBroadcast.boolValue {
//            address = [0xFF, 0xFF, 0xFF]
//        } else if scenes[indexPath.row].isLocalcast.boolValue {
//            address = [UInt8(Int(scenes[indexPath.row].gateway.addressOne)), UInt8(Int(scenes[indexPath.row].gateway.addressTwo)), 0xFF]
//        } else {
//            address = [UInt8(Int(scenes[indexPath.row].gateway.addressOne)), UInt8(Int(scenes[indexPath.row].gateway.addressTwo)), UInt8(Int(scenes[indexPath.row].address))]
//        }
//        let sceneId = Int(scenes[indexPath.row].sceneId)
//        if sceneId >= 0 && sceneId <= 32767 {
//            SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scenes[indexPath.row].sceneId)), gateway: scenes[indexPath.row].gateway)
//        }
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
        cell.getImagesFrom(scenes[indexPath.row])
        cell.sceneCellLabel.addGestureRecognizer(longPress)
        cell.sceneCellImageView.tag = indexPath.row
        cell.sceneCellImageView.userInteractionEnabled = true
        cell.sceneCellImageView.clipsToBounds = true
        cell.sceneCellImageView.layer.cornerRadius = 5
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "setScene:")
        cell.sceneCellImageView.addGestureRecognizer(set)
        cell.btnSet.tag = indexPath.row
        let setTwo:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "setScene:")
        cell.btnSet.addGestureRecognizer(setTwo)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    func setScene (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if scenes[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if scenes[tag].isLocalcast.boolValue {
                address = [UInt8(Int(scenes[tag].gateway.addressOne)), UInt8(Int(scenes[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(scenes[tag].gateway.addressOne)), UInt8(Int(scenes[tag].gateway.addressTwo)), UInt8(Int(scenes[tag].address))]
            }
            let sceneId = Int(scenes[tag].sceneId)
            if sceneId >= 0 && sceneId <= 32767 {
                SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scenes[tag].sceneId)), gateway: scenes[tag].gateway)
            }
//            UIView.setAnimationsEnabled(false)
//            self.scenesCollectionView.performBatchUpdates({
//                let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//                let cell = self.scenesCollectionView.cellForItemAtIndexPath(indexPath)
//                self.scenesCollectionView.reloadItemsAtIndexPaths([indexPath])
//                }, completion:  {(completed: Bool) -> Void in
//                    UIView.setAnimationsEnabled(true)
//            })
//            let indexPath = NSIndexPath(forItem: tag, inSection: 0)
//            let cell = self.scenesCollectionView.cellForItemAtIndexPath(indexPath)
//            if let cell = cell as? SceneCollectionCell {
//                cell.sceneCellImageView.image =
//            }
            let tag = gesture.view!.tag
            let location = gesture.locationInView(scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItemAtPoint(location){
                if let cell = scenesCollectionView.cellForItemAtIndexPath(index) as? SceneCollectionCell {
                    cell.changeImageForOneSecond()
                }
            }
        }
        
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
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(scene:Scene) {
        if let sceneImage = UIImage(data: scene.sceneImageOne) {
            imageOne = sceneImage
        }
        
        if let sceneImage = UIImage(data: scene.sceneImageTwo) {
            imageTwo = sceneImage
        }
        sceneCellImageView.image = imageOne
        setNeedsDisplay()
    }
    func changeImageForOneSecond() {
        sceneCellImageView.image = imageTwo
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
    }
    func changeImageBack() {
        sceneCellImageView.image = imageOne
    }
//    override var highlighted: Bool {
//        willSet(newValue) {
//            if newValue {
//                sceneCellImageView.image = imageTwo
//                setNeedsDisplay()
//                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
//            }
//        }
//        didSet {
//            print("highlighted = \(highlighted)")
//        }
//    }
    func changeImageToNormal () {
        sceneCellImageView.image = imageOne
//        setNeedsDisplay()
    }
    @IBOutlet weak var btnSet: CustomGradientButtonWhite!
    @IBAction func btnSet(sender: AnyObject) {
        
    }
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
