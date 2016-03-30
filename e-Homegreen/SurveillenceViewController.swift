//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SurveillenceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PullDownViewDelegate, UIPopoverPresentationControllerDelegate, SWRevealViewControllerDelegate {
    
    var data:NSData?
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    var timer:NSTimer = NSTimer()
    
    var pullDown = PullDownView()
    
    var surveillance:[Surveillance] = []
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

//        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
//            collectionViewCellSize = CGSize(width: 128, height: 156)
//        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
//            collectionViewCellSize = CGSize(width: 118, height: 144)
//        }
        
        fetchSurveillance()

        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SurveillenceViewController.update), userInfo: nil, repeats: true)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        
        // Do any additional setup after loading the view.
    }
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Surveillance)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        fetchSurveillance()
        cameraCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        pullDown.drawMenu(filterParametar)
        fetchSurveillance()
        cameraCollectionView.reloadData()
    }
    func refreshSurveillanceList(){
        fetchSurveillance()
        cameraCollectionView.reloadData()
    }
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
        fetchSurveillance()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    func addObservers () {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.runTimer), name: NotificationKey.Surveillance.Run, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.stopTimer), name: NotificationKey.Surveillance.Stop, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.refreshSurveillanceList), name: NotificationKey.RefreshSurveillance, object: nil)
//        NSNotificationCenter.defaultCenter().addObserverForName("", object: nil, queue: NSOperationQueue.mainQueue()) { (let notification) -> Void in
//            <#code#>
//        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
//    var notificationObserver: ((NSNotification) -> Void)?
//    init() {
//        notificationObserver = NSNotificationCenter.defaultCenter().addObserverForName("humanEnteredKrakensLair", object: nil, queue: NSOperationQueue.mainQueue()) { notification in
//    [weak self] notification in //The retain cycle is fixed by using capture lists!
//    self?.eatHuman() //self is now an optional!
//            self.eatHuman()
//        }
//    }
//    
//    deinit {
//        if notificationObserver != nil {
//            NSNotificationCenter.defaultCenter.removeObserver(notificationObserver)
//        }
//    }
    func removeObservers () {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.Surveillance.Run, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.Surveillance.Stop, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSurveillance, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
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
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
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
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        cameraCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    func runTimer(){
        if timer.valid == false{
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SurveillenceViewController.update), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer(){
        if timer.valid{
            timer.invalidate()
        }
    }
    
    func getData(){
        if surveillance != []{
            for item in surveillance{
                SurveillanceHandler(surv: item)
            }
        }
    }
    
    func update(){
        getData()
        cameraCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cameraParametar(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(cameraCollectionView)
            if let index = cameraCollectionView.indexPathForItemAtPoint(location){
                let cell = cameraCollectionView.cellForItemAtIndexPath(index)
                showCameraParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - cameraCollectionView.contentOffset.y), surveillance: surveillance[index.row])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveillance.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Surveillance", forIndexPath: indexPath) as! SurveillenceCell
        
        cell.lblName.text = surveillance[indexPath.row].name
        cell.lblName.userInteractionEnabled = true
        cell.lblName.tag = indexPath.row
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SurveillenceViewController.cameraParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.lblName.addGestureRecognizer(longPress)
        
        if surveillance[indexPath.row].imageData != nil {
            cell.setImageForSurveillance(UIImage(data: surveillance[indexPath.row].imageData!)!)
//            cell.image.image = UIImage(data: surveillance[indexPath.row].imageData!)
        }else{
            cell.setImageForSurveillance(UIImage(named: "loading")!)
//            cell.image.image = UIImage(named: "loading")
        }
        
        if surveillance[indexPath.row].lastDate != nil {
            let formatter = NSDateFormatter()
            formatter.timeZone = NSTimeZone.localTimeZone()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell.lblTime.text = formatter.stringFromDate(surveillance[indexPath.row].lastDate!)
        } else {
            cell.lblTime.text = ""
        }
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cameraCollectionView.cellForItemAtIndexPath(indexPath)
        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - self.cameraCollectionView.contentOffset.y), surv: surveillance[indexPath.row])
    }
    
    func fetchSurveillance() {
        let fetchRequest = NSFetchRequest(entityName: "Surveillance")
        let sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "port", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptorTwo]
        var predicateArray:[NSPredicate] = []
        if filterParametar.location != "All" {
            let locationPredicate = NSPredicate(format: "location.name == %@", filterParametar.location)
            predicateArray.append(locationPredicate)
        }
        if filterParametar.levelName != "All" {
            let levelPredicate = NSPredicate(format: "surveillanceLevel == %@", filterParametar.levelName)
            predicateArray.append(levelPredicate)
        }
        if filterParametar.zoneName != "All" {
            let zonePredicate = NSPredicate(format: "surveillanceZone == %@", filterParametar.zoneName)
            predicateArray.append(zonePredicate)
        }
        if filterParametar.categoryName != "All" {
            let categoryPredicate = NSPredicate(format: "surveillanceCategory == %@", filterParametar.categoryName)
            predicateArray.append(categoryPredicate)
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Surveillance]
            surveillance = []
            for item in fetResults!{
                if item.isVisible == true {
                    surveillance.append(item)
                }
            }
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            cameraCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            cameraCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            cameraCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveillenceViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            cameraCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }

}

extension String {
    
    func removeCharsFromEnd(count_:Int) -> String {
        let stringLength = self.characters.count
        
        let substringIndex = (stringLength < count_) ? 0 : stringLength - count_
        
        return self.substringToIndex(self.startIndex.advancedBy(substringIndex))
    }
}

class SurveillenceCell:UICollectionViewCell{
    
    @IBOutlet weak var lblName: MarqueeLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    func setImageForSurveillance (image:UIImage) {
        self.image.image = image
        setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 8.0, height: 8.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        
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




