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
    @IBOutlet weak var fullScreenButton: UIButton!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    var timer:NSTimer = NSTimer()
    
    var pullDown = PullDownView()
    
    var surveillance:[Surveillance] = []
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
    
    override func viewWillAppear(animated: Bool) {
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
        
        fetchSurveillance()
        runTimer()
        changeFullScreeenImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopTimer()
        removeObservers()
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
        } else {
            
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        cameraCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    
    //full screen button from navigation bar
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        }
    }
    
    //change fullscreen button if it pressed in other navigation controller
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    //return parametars from filter
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Surveillance)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        fetchSurveillance()
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        pullDown.drawMenu(filterParametar)
        fetchSurveillance()
    }
    
    func refreshSurveillanceList(){
        fetchSurveillance()
    }
    
    //get surv from database
    func fetchSurveillance() {
        surveillance = DatabaseSurveillanceController.shared.getSurveillace(filterParametar)
        cameraCollectionView.reloadData()
    }


    func addObservers () {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.refreshSurveillanceList), name: NotificationKey.RefreshSurveillance, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SurveillenceViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }

    func removeObservers () {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshSurveillance, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    //run timer and repeat on every one second
    func runTimer(){
        if timer.valid == false{
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SurveillenceViewController.update), userInfo: nil, repeats: true)
        }
    }
    
    //stop timer when we dont need to refresh screen, on disappear
    func stopTimer(){
        if timer.valid{
            timer.invalidate()
        }
    }
    
    //get data from api, refresh image for show
    func getData(){
        if surveillance != []{
            for item in surveillance{
                SurveillanceHandler(surv: item)
            }
        }
    }
    
    //timer function
    func update(){
        getData()
        cameraCollectionView.reloadItemsAtIndexPaths(self.cameraCollectionView.indexPathsForVisibleItems())
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
    
    //collection view delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveillance.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Surveillance", forIndexPath: indexPath) as! SurveillenceCell
        
        cell.setItem(surveillance[indexPath.row], filterParametar: filterParametar)
        cell.lblName.userInteractionEnabled = true
        cell.lblName.tag = indexPath.row
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SurveillenceViewController.cameraParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.lblName.addGestureRecognizer(longPress)
        
        if let data = surveillance[indexPath.row].imageData {
            cell.setImageForSurveillance(UIImage(data: data))
        }else{
            cell.setImageForSurveillance(UIImage(named: "loading")!)
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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
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
    
    //Side menu delegate
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






