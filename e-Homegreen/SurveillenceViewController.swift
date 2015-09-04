//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

class Camera:NSObject{
    var image:NSData?
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
    
//    @IBOutlet weak var liveStreamWebView: UIWebView!
    
    
//    @IBOutlet weak var image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        camera1.lync = "http://192.168.0.19:8081/"
        
//        var camera2 =  Camera()
        camera2.lync = "http://192.168.0.33:8081/"
        
//        var camera3 =  Camera()
        camera3.lync = "http://192.168.0.45:8081/"
        
        cameraList.append(camera1)
        cameraList.append(camera2)
        cameraList.append(camera3)
        
//        getData("http://192.168.0.45:8081/")
        getData()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }
    
    func getData(){
        let task1 = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: camera1.lync)!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {

                    self.camera1.image = data
                })
            }
        }
        task1.resume()
        let task2 = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: camera2.lync)!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.camera2.image = data
                    
                })
            }
        }
        task2.resume()
        let task3 = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: camera3.lync)!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.camera3.image = data
                })
            }
        }
        task3.resume()
//        cameraCollectionView.reloadData()
    }
    
    func update(){
//        for var i=0;i<3;i++ {
//
//            UIView.setAnimationsEnabled(false)
//            self.cameraCollectionView.performBatchUpdates({ () -> Void in
//                self.cameraCollectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0), NSIndexPath(forItem: 1, inSection: 0), NSIndexPath(forItem: 2, inSection: 0)])
//            }, completion: nil)
//            self.deviceCollectionView.performBatchUpdates({
//            var indexPath = NSIndexPath(forItem: tag, inSection: 0)
//            self.deviceCollectionView.reloadItemsAtIndexPaths([indexPath])
//            }, completion:  {(completed: Bool) -> Void in
//            UIView.setAnimationsEnabled(true)
//            })
//        }
        getData()
        cameraCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Surveillance", forIndexPath: indexPath) as! SurveillenceCell
        cell.lblTime.text = "\(NSDate())"
//        if let data = getData("http://192.168.0.45:8081/"){
////            dispatch_async(dispatch_get_main_queue(), {
//                cell.image.image = UIImage(data: data)
////            })
//        }
//        let url:NSURL!
//        if indexPath.row == 0{
//            url = NSURL(string: "http://192.168.0.45:8081/")
//        }
//        else if indexPath.row == 1{
//            url = NSURL(string: "http://192.168.0.19:8081/")
//        }else {
//            url = NSURL(string: cameraList[indexPath.row])
//        }
//        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
//            if error == nil{
//                dispatch_async(dispatch_get_main_queue(), {
        if let nesto = cameraList[indexPath.row].image{
            cell.image.image = UIImage(data: nesto)
        }
//
//                })
//            }
//        }
//        task.resume()

        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        delegate?.backString(galleryList[indexPath.row], imageIndex: imageIndex)
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }


}

class SurveillenceCell:UICollectionViewCell{
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
}


