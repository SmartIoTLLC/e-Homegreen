//
//  MoveCameraHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/28/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class MoveCameraHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    func home(surv:Surveillance) {
        let username = surv.username
        let password = surv.password
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        var url:NSURL
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            var urlExtension = ""
//            if surv.urlHome == "" {urlExtension = "/cgi-bin/longcctvhome.cgi?action=gohome"} else {urlExtension = surv.urlHome!}
//            url = NSURL(string: "http://\(surv.localIp!):\(surv.localPort!)\(urlExtension)")!
//            
//        }else{
            var urlExtension = ""
            if surv.urlHome == "" {urlExtension = "/cgi-bin/longcctvhome.cgi?action=gohome"} else {urlExtension = surv.urlHome!}
            url = NSURL(string: "http://\(surv.ip!):\(surv.port!)\(urlExtension)")!
//        }
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                
            }else{
                
            }
            
        }
        task.resume()
    }
    func moveCamera(surv: Surveillance, position: String){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        var url:NSURL
        var urlMain = ""
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
//        }else{
            urlMain = "http://\(surv.ip!):\(surv.port!)"
//        }
        var urlExtension = "/cgi-bin/longcctvmove.cgi?action=move&direction=\(position)&panstep=\(surv.panStep!)&tiltstep=\(surv.tiltStep!)"
        if position == "right" {
            if surv.urlMoveRight != "" {urlExtension = surv.urlMoveRight!}
        } else  if position == "left" {
            if surv.urlMoveLeft != "" {urlExtension = surv.urlMoveLeft!}
        } else  if position == "up" {
            if surv.urlMoveUp != "" {urlExtension = surv.urlMoveUp!}
        } else  if position == "down" {
            if surv.urlMoveDown != "" {urlExtension = surv.urlMoveDown!}
        }
        url = NSURL(string: "\(urlMain)\(urlExtension)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                
            }else{
                
            }
            
        }
        task.resume()
    }
    func autoPan(surv: Surveillance, isStopNecessary:Bool){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        var url:NSURL
        var urlMain = ""
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
//            
//        }else{
            urlMain = "http://\(surv.ip!):\(surv.port!)"
//        }
        var urlExtension = ""
        if isStopNecessary {
            if surv.urlAutoPanStop == "" {urlExtension = "/cgi-bin/longcctvapn.cgi?action=stop"} else {urlExtension = surv.urlAutoPanStop!}
        } else {
            if surv.urlAutoPan == "" {urlExtension = "/cgi-bin/longcctvapn.cgi?action=go&speed=\(surv.autSpanStep!)"} else {urlExtension = surv.urlAutoPan!}
        }
        url = NSURL(string: "\(urlMain)\(urlExtension)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                
            }else{
                
            }
            
        }
        task.resume()
    }
//    func stop(surv: Surveilence){
//        let username = surv.username
//        let password = surv.password
//        
//        let loginString = NSString(format: "%@:%@", username!, password!)
//        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
//        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//        var url:NSURL
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            url = NSURL(string: "http://\(surv.localIp!):\(surv.localPort!)/cgi-bin/longcctvseq.cgi?action=stop")!
//            
//        }else{
//            url = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvseq.cgi?action=stop")!
//        }
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//        
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
//        
//        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
//            
//            if error == nil{
//                
//            }else{
//                
//            }
//            
//        }
//        task.resume()
//        
//        var url1:NSURL
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            url1 = NSURL(string: "http://\(surv.localIp!):\(surv.localPort!)/cgi-bin/longcctvapn.cgi?action=stop")!
//        }else{
//            url1 = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvapn.cgi?action=stop")!
//        }
//        let request1 = NSMutableURLRequest(URL: url1)
//        request1.HTTPMethod = "GET"
//        request1.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//        
//        let task1 = session.dataTaskWithRequest(request1) { (data, response, error) -> Void in
//            
//            if error == nil{
//                
//            }else{
//                
//            }
//            
//        }
//        task1.resume()
//    }
    
    func presetSequence(surv: Surveillance, isStopNecessary:Bool){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        var url:NSURL
        var urlMain = ""
//        if surv.ssid != nil && surv.ssid == UIDevice.currentDevice().SSID{
//            urlMain = "http://\(surv.localIp!):\(surv.localPort!)"
//            url = NSURL(string: "/cgi-bin/longcctvseq.cgi?action=go")!
//            
//        }else{
            urlMain = "http://\(surv.ip!):\(surv.port!)"
            url = NSURL(string: "/cgi-bin/longcctvseq.cgi?action=go")!
//        }
        var urlExtension = ""
        if isStopNecessary {
            if surv.urlPresetSequenceStop == "" {urlExtension = "/cgi-bin/longcctvseq.cgi?action=stop"} else {urlExtension = surv.urlPresetSequenceStop!}
        } else {
            if surv.urlPresetSequence == "" {urlExtension = "/cgi-bin/longcctvseq.cgi?action=go"} else {urlExtension = surv.urlPresetSequence!}
        }
        url = NSURL(string: "\(urlMain)\(urlExtension)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                
            }else{
                
            }
            
        }
        task.resume()
    }

    
    
    
}
