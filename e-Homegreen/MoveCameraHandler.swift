//
//  MoveCameraHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/28/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class MoveCameraHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
    
    init(surv: Surveilence, position: String) {
        super.init()
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        print(base64LoginString)
        
        let url = NSURL(string: "\(surv.ip!):\(surv.port!)/cgi-bin/longcctvmove.cgi?action=move&direction=\(position)&panstep=1&tiltstep=1")
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
