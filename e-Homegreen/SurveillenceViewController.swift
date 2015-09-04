//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SurveillenceViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    var timer:NSTimer = NSTimer()
    
//    @IBOutlet weak var liveStreamWebView: UIWebView!
    
    
//    @IBOutlet weak var image: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        
//        getData("http://192.168.0.45:8081/")

        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        // Do any additional setup after loading the view.
    }
    
    func getData(urlString:String) -> NSData?{
        let url = NSURL(string: urlString)
        var dataPic:NSData?
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                dataPic = data
//                   return data
                    
                })
            }
        }
        task.resume()
        return dataPic
    }
    
    func update(){
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
        let url:NSURL!
//        if indexPath.row == 0{
//            url = NSURL(string: "http://192.168.0.45:8081/")
//        }
//        else if indexPath.row == 1{
//            url = NSURL(string: "http://192.168.0.33:8081/")
//        }else {
            url = NSURL(string: "http://192.168.0.19:8081/")
//        }
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    cell.image.image = UIImage(data: data)
                    
                })
            }
        }
        task.resume()

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


