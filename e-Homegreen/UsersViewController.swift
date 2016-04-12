//
//  UsersViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate, SWRevealViewControllerDelegate {
    
    var appDel:AppDelegate!
    var timers:[Timer] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    var senderButton:UIButton?
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Users)

    
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
        refreshTimerList()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)

        
    }
    
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Users)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Users)
        refreshTimerList()
    }
    
    func refreshTimerList() {
        timers = DatabaseUserTimerController.shared.getTimers(filterParametar)
        usersCollectionView.reloadData()
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
        usersCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            usersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            usersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            usersCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UsersViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            usersCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }

}

extension UsersViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension UsersViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timers.count
    }
    
//    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
//        let tag = gestureRecognizer.view!.tag
//        if gestureRecognizer.state == UIGestureRecognizerState.Began {
//            let location = gestureRecognizer.locationInView(timersCollectionView)
//            if let index = timersCollectionView.indexPathForItemAtPoint(location){
//                let cell = timersCollectionView.cellForItemAtIndexPath(index)
//                showTimerParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - timersCollectionView.contentOffset.y), timer: timers[tag])
//            }
//        }
//    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("usersCell", forIndexPath: indexPath) as! TimerUserCell
        
        cell.setItem(timers[indexPath.row], filterParametar:filterParametar)

//        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "openCellParametar:")
//        longPress.minimumPressDuration = 0.5
//        cell.timerTitle.userInteractionEnabled = true
//        cell.timerTitle.addGestureRecognizer(longPress)
//        
//        cell.getImagesFrom(timers[indexPath.row])
//        
//        cell.timerButton.tag = indexPath.row
//        cell.timerButtonLeft.tag = indexPath.row
//        cell.timerButtonRight.tag = indexPath.row
//        print(timers[indexPath.row].type)
//        if timers[indexPath.row].type == "Countdown" {
//            //   ===   Default   ===
//            cell.timerButton.hidden = false
//            cell.timerButtonLeft.hidden = true
//            cell.timerButtonRight.hidden = true
//            cell.timerButton.enabled = true
//            cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
//            cell.timerButton.addTarget(self, action: "pressedStart:", forControlEvents: UIControlEvents.TouchUpInside)
//            //   ===================
//            if timers[indexPath.row].timerState == 1 {
//                cell.timerButton.hidden = true
//                cell.timerButtonLeft.hidden = false
//                cell.timerButtonRight.hidden = false
//                cell.timerButtonRight.setTitle("Pause", forState: UIControlState.Normal)
//                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
//                cell.timerButtonRight.addTarget(self, action: "pressedPause:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.timerButtonLeft.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            if timers[indexPath.row].timerState == 240 {
//                cell.timerButton.hidden = false
//                cell.timerButtonLeft.hidden = true
//                cell.timerButtonRight.hidden = true
//                cell.timerButton.enabled = true
//                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
//                cell.timerButton.addTarget(self, action: "pressedStart:", forControlEvents: UIControlEvents.TouchUpInside)
//            }
//            if timers[indexPath.row].timerState == 238 {
//                cell.timerButton.hidden = true
//                cell.timerButtonLeft.hidden = false
//                cell.timerButtonRight.hidden = false
//                cell.timerButtonRight.setTitle("Resume", forState: UIControlState.Normal)
//                cell.timerButtonLeft.setTitle("Cancel", forState: UIControlState.Normal)
//                cell.timerButtonRight.addTarget(self, action: "pressedResume:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.timerButtonLeft.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
//            }
//        } else {
//            if timers[indexPath.row].timerState == 240 {
//                cell.timerButton.hidden = false
//                cell.timerButtonLeft.hidden = true
//                cell.timerButtonRight.hidden = true
//                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
//                //                cell.timerButton.setTitle("Start", forState: UIControlState.Normal)
//                cell.timerButton.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.timerButton.enabled = false
//            } else {
//                cell.timerButton.hidden = false
//                cell.timerButtonLeft.hidden = true
//                cell.timerButtonRight.hidden = true
//                cell.timerButton.setTitle("Cancel", forState: UIControlState.Normal)
//                cell.timerButton.addTarget(self, action: "pressedCancel:", forControlEvents: UIControlEvents.TouchUpInside)
//                cell.timerButton.enabled = true
//            }
//        }

        return cell
    }
}



