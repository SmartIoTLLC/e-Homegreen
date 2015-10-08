//
//  MoveCameraHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/28/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class MoveCameraHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    func autoSpan(surv: Surveilence){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let url = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvapn.cgi?action=go&speed=\(surv.autSpanStep!)")
        let request = NSMutableURLRequest(URL: url!)
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
    
    func stop(surv: Surveilence){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let url = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvseq.cgi?action=stop")
        let request = NSMutableURLRequest(URL: url!)
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
        
        let url1 = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvapn.cgi?action=stop")
        let request1 = NSMutableURLRequest(URL: url1!)
        request1.HTTPMethod = "GET"
        request1.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task1 = session.dataTaskWithRequest(request1) { (data, response, error) -> Void in
            
            if error == nil{
                
            }else{
                
            }
            
        }
        task1.resume()
    }
    
    func presetSequence(surv: Surveilence){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        let url = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvseq.cgi?action=go")
        let request = NSMutableURLRequest(URL: url!)
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

    
    func moveCamera(surv: Surveilence, position: String){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        print(surv.panStep)
        let url = NSURL(string: "http://\(surv.ip!):\(surv.port!)/cgi-bin/longcctvmove.cgi?action=move&direction=\(position)&panstep=\(surv.panStep!)&tiltstep=\(surv.tiltStep!)")
        let request = NSMutableURLRequest(URL: url!)
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
