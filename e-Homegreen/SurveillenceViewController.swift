//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

//class Camera:NSObject{
//    var image:NSData?
//    var time:String?
//    var lync:String!
//}

import UIKit
import CoreData

class SurveillenceViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, GetImageHandler {
    
    var data:NSData?
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    var timer:NSTimer = NSTimer()
    
    var surveillance:[Surveilence] = []
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
//    var cameraList:[Camera] = []
//    
//    var camera1 =  Camera()
//    var camera2 =  Camera()
//    var camera3 =  Camera()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
//        camera1.lync = "http://192.168.0.18:8081/"
//        camera2.lync = "http://192.168.0.18:8081/"
//        camera3.lync = "http://192.168.0.32:8081/"
//        
//        cameraList.append(camera1)
//        cameraList.append(camera2)
//        cameraList.append(camera3)

//        getData()
        
        fetchSurveillance()
        
        if surveillance != []{
            SurveillanceHandler(surv: surveillance[0]).delegate = self
        }
        
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSurveillanceList", name: "refreshCameraListNotification", object: nil)
        
        // Do any additional setup after loading the view.
    }
    
//    func getImageHandlerFinished(succeded: Bool, data: NSData?) {
//        if succeded{
//            self.data = data
//        }else{
//            
//        }
//    }
    
    func getImageHandlerFinished(succeded: Bool, data: NSData?) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.data = data
            self.cameraCollectionView.reloadData()
            self.imageBack.image = UIImage(data: self.data!)
        })
        
        
    }
    
    func getData(){
        if surveillance != []{
            SurveillanceHandler(surv: surveillance[0]).delegate = self
        }
        
//        for item in cameraList {
//            let url = NSURL(string: item.lync)
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
//                if error == nil{
//                    dispatch_async(dispatch_get_main_queue(), {
//                        item.image = data
//                        item.time = "\(NSDate())"
//                    })
//                }
//            }
//            task.resume()
//        }
        
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
        

//        if let nesto = cameraList[indexPath.row].image{
        if self.data != nil {
            cell.image.image = UIImage(data: self.data!)
        }
//        }
//        
//        if let time = cameraList[indexPath.row].time{
//            cell.lblTime.text = "\(time.removeCharsFromEnd(6))"
//        }

        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell = cameraCollectionView.cellForItemAtIndexPath(indexPath)
//        dispatch_async(dispatch_get_main_queue(), {
//        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - cameraCollectionView.contentOffset.y), lync: NSURL(string: cameraList[indexPath.row].lync)!)
//        })
    }
    
    func fetchSurveillance () {
        let fetchRequest = NSFetchRequest(entityName: "Surveilence")
        let sortDescriptor = NSSortDescriptor(key: "ip", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "port", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptorTwo]
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Surveilence]
            surveillance = fetResults!
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


