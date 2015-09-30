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
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    var timer:NSTimer = NSTimer()
    
    var surveillance:[Surveilence] = []
    
    var appDel:AppDelegate!
    var error:NSError? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate

        
        fetchSurveillance()

        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSurveillanceList", name: "refreshCameraListNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "runTimer", name: "runTimer", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopTimer", name: "stopTimer", object: nil)
        
        // Do any additional setup after loading the view.
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
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveillance.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Surveillance", forIndexPath: indexPath) as! SurveillenceCell

        if surveillance[indexPath.row].imageData != nil {
            cell.image.image = UIImage(data: surveillance[indexPath.row].imageData!)
        }else{
            cell.image.image = UIImage(named: "loading")
        }

        cell.layer.cornerRadius = 5
        
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
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
}


