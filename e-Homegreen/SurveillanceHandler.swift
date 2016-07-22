//
//  SurveillanceHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/25/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

//protocol GetImageHandler{
//    func getImageHandlerFinished(succeded:Bool, data:NSData?)
//}

class SurveillanceHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate{
    
//    static let shared = SurveillanceHandler()
    
    //    var delegate:GetImageHandler?
    
    init(surv: Surveillance) {
        super.init()
        
        if let username = surv.username, let password = surv.password {
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            var url:NSURL
            var urlMain = ""
//            if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//                urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
//                
//            }else{
                urlMain = "http://\(surv.ip!):\(surv.port!)"
//            }
            var urlExtension = ""
            if surv.urlGetImage == "" {
                urlExtension = "/dms?nowprofileid=3"
            } else {
                urlExtension = surv.urlGetImage!
            }
            url = NSURL(string: "\(urlMain)\(urlExtension)")!
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
            
            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                
                if error == nil{
                    surv.imageData = data
                    surv.lastDate = NSDate()
                }
                
            }
            task.resume()
        }
    }
    
    func getCameraImage(surv: Surveillance, completion: (success:Bool)->()){
        if let username = surv.username, let password = surv.password {
            
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            var url:NSURL
            var urlMain = ""
            //            if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
            //                urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
            //
            //            }else{
            urlMain = "http://\(surv.ip!):\(surv.port!)"
            //            }
            var urlExtension = ""
            if surv.urlGetImage == "" {
                urlExtension = "/dms?nowprofileid=3"
            } else {
                urlExtension = surv.urlGetImage!
            }
            url = NSURL(string: "\(urlMain)\(urlExtension)")!

            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
                if error == nil{
                    completion(success: true)
                    print(NSDate())
                    surv.imageData = data
                    surv.lastDate = NSDate()
                }else{
                    completion(success: false)
                    print("nista")
                    surv.imageData = nil
                    surv.lastDate = nil
                }
            }
            task.resume()
            
            
            
//            let loginString = NSString(format: "%@:%@", username, password)
//            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
//            let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//            var url:NSURL
//            var urlMain = ""
//            //            if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            //                urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
//            //
//            //            }else{
//            urlMain = "http://\(surv.ip!):\(surv.port!)"
//            //            }
//            var urlExtension = ""
//            if surv.urlGetImage == "" {
//                urlExtension = "/dms?nowprofileid=3"
//            } else {
//                urlExtension = surv.urlGetImage!
//            }
//            url = NSURL(string: "\(urlMain)\(urlExtension)")!
//            
//            let request = NSMutableURLRequest(URL: url)
//            request.HTTPMethod = "GET"
//            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//            
//            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//            let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
//            
//            let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//                
//                if error == nil{
//                    completion(success: true)
//                    print(NSDate())
//                    surv.imageData = data
//                    surv.lastDate = NSDate()
//                }else{
//                    completion(success: false)
//                    print("nista")
//                    surv.imageData = nil
//                    surv.lastDate = nil
//                }
//                
//            }
//            task.resume()
        }
    }
    
    
}
