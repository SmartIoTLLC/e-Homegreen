//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SurveillenceViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var data:NSData?
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    var timer:NSTimer = NSTimer()
    
    var surveillance:[Surveilence] = []
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }
        
        fetchSurveillance()

        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSurveillanceList", name: "refreshCameraListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "runTimer", name: "runTimer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: "stopTimer", object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
        }else{
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
        }
        cameraCollectionView.reloadData()
    }
    
    func runTimer(){
        if timer.valid == false{
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
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
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "cameraParametar:")
        longPress.minimumPressDuration = 0.5
        cell.lblName.addGestureRecognizer(longPress)
        
        if surveillance[indexPath.row].imageData != nil {
            cell.image.image = UIImage(data: surveillance[indexPath.row].imageData!)
        }else{
            cell.image.image = UIImage(named: "loading")
        }
        
        if surveillance[indexPath.row].lastDate != nil {
            let date = "\(surveillance[indexPath.row].lastDate!)"
            cell.lblTime.text = date.removeCharsFromEnd(5)
        }else{
            cell.lblTime.text = ""
        }
        
        
        
//        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = cameraCollectionView.cellForItemAtIndexPath(indexPath)
        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - self.cameraCollectionView.contentOffset.y), surv: surveillance[indexPath.row])
        
    }
    
    func fetchSurveillance () {
        let fetchRequest = NSFetchRequest(entityName: "Surveilence")
        let sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "port", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptorTwo]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Surveilence]
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
    
    func refreshSurveillanceList(){
        fetchSurveillance()
        cameraCollectionView.reloadData()
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
    
}




