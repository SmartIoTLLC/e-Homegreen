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
    
    var locationSearchText = ["", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch) = (gateway, level, zone, category)
        updateSceneList()
        scenesCollectionView.reloadData()
        LocalSearchParametar.setLocalParametar("Scenes", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch])
    }
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
        locationSearchText = LocalSearchParametar.getLocalParametar("Scenes")
        updateSceneList()
        // Do any additional setup after loading the view.
    }
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Scenes")
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSceneList", name: "refreshSceneListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: "refreshLocalParametarsNotification", object: nil)
    }
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshSceneListNotification", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshLocalParametarsNotification", object: nil)
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
        if zoneSearch != "All" {
            let zonePredicate = NSPredicate(format: "sceneZone == %@", returnZoneWithId(Int(zoneSearch)!))
            predicateArray.append(zonePredicate)
        }
        if categorySearch != "All" {
            let categoryPredicate = NSPredicate(format: "sceneCategory == %@", returnCategoryWithId(Int(categorySearch)!))
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
    
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
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
            pullDown.customDelegate = self
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
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
        }
        scenesCollectionView.reloadData()
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[1], zone: locationSearchText[2], category: locationSearchText[3])
    }
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    
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
        var address:[UInt8] = []
        if scenes[indexPath.row].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if scenes[indexPath.row].isLocalcast.boolValue {
            address = [UInt8(Int(scenes[indexPath.row].gateway.addressOne)), UInt8(Int(scenes[indexPath.row].gateway.addressTwo)), 0xFF]
        } else {
            address = [UInt8(Int(scenes[indexPath.row].gateway.addressOne)), UInt8(Int(scenes[indexPath.row].gateway.addressTwo)), UInt8(Int(scenes[indexPath.row].address))]
        }
        let sceneId = Int(scenes[indexPath.row].sceneId)
        if sceneId >= 0 && sceneId <= 255 {
            SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scenes[indexPath.row].sceneId)), gateway: scenes[indexPath.row].gateway)
        }
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
        
        cell.getImagesFrom(scenes[indexPath.row])
        
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
    override var highlighted: Bool {
        willSet(newValue) {
            if newValue {
                sceneCellImageView.image = imageTwo
                setNeedsDisplay()
                NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "changeImageToNormal", userInfo: nil, repeats: false)
            }
        }
        didSet {
            print("highlighted = \(highlighted)")
        }
    }
    func changeImageToNormal () {
        sceneCellImageView.image = imageOne
        setNeedsDisplay()
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
