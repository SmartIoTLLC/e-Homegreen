//
//  UsersViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/22/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UIPopoverPresentationControllerDelegate, PullDownViewDelegate {
    
    var appDel:AppDelegate!
    var timers:[Timer] = []
    var error:NSError? = nil
    
    var pullDown = PullDownView()
    var senderButton:UIButton?
    
    @IBOutlet weak var timersCollectionView: UICollectionView!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "TimerCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var locationSearchText = ["", "", "", "", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        // Do any additional setup after loading the view.
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("usersCell", forIndexPath: indexPath) as! TimerCollectionViewCell
        
//        var timerLevel = ""
//        var timerZone = ""
//        let timerLocation = timers[indexPath.row].gateway.name
//        
//        if let level = timers[indexPath.row].entityLevel{
//            timerLevel = level
//        }
//        if let zone = timers[indexPath.row].timeZone{
//            timerZone = zone
//        }
//        
//        if locationSearchText[0] == "All" {
//            cell.timerTitle.text = timerLocation + " " + timerLevel + " " + timerZone + " " + timers[indexPath.row].timerName
//        }else{
//            var timerTitle = ""
//            if locationSearchText[4] == "All"{
//                timerTitle += " " + timerLevel
//            }
//            if locationSearchText[5] == "All"{
//                timerTitle += " " + timerZone
//            }
//            timerTitle += " " + timers[indexPath.row].timerName
//            cell.timerTitle.text = timerTitle
//        }
//        
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
//        
//        // cancel start pause resume
//        //
//        cell.timerImageView.layer.cornerRadius = 5
//        cell.timerImageView.clipsToBounds = true
//        cell.layer.cornerRadius = 5
//        cell.layer.borderColor = UIColor.grayColor().CGColor
//        cell.layer.borderWidth = 0.5
        return cell
    }
}

