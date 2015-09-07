//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

class Camera:NSObject{
    var image:NSData?
    var time:NSDate?
    var lync:String!
}

import UIKit

class SurveillenceViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    var timer:NSTimer = NSTimer()
    
    var cameraList:[Camera] = []
    
    var camera1 =  Camera()
    var camera2 =  Camera()
    var camera3 =  Camera()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        camera1.lync = "http://192.168.0.16:8081/"
        camera2.lync = "http://192.168.0.18:8081/"
        camera3.lync = "http://192.168.0.32:8081/"
        
        cameraList.append(camera1)
        cameraList.append(camera2)
        cameraList.append(camera3)

        getData()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }
    
    func getData(){
        
        for item in cameraList {
            let url = NSURL(string: item.lync)
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
                if error == nil{
                                        dispatch_async(dispatch_get_main_queue(), {
                    item.image = data
                    item.time = NSDate()
                                        })
                }
            }
            task.resume()

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
        return cameraList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Surveillance", forIndexPath: indexPath) as! SurveillenceCell
        cell.lblTime.text = "\(NSDate())"

        if let nesto = cameraList[indexPath.row].image{
            cell.image.image = UIImage(data: nesto)
        }
        
        if let time = cameraList[indexPath.row].time{
            cell.lblTime.text = "\(time)"
        }

        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var cell = cameraCollectionView.cellForItemAtIndexPath(indexPath)
//        dispatch_async(dispatch_get_main_queue(), {
        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - cameraCollectionView.contentOffset.y), lync: NSURL(string: cameraList[indexPath.row].lync)!)
//        })
    }


}

class SurveillenceCell:UICollectionViewCell{
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
}


