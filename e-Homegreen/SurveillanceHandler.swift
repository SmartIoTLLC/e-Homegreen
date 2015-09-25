//
//  SurveillanceHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/25/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

protocol GetImageHandler{
    func getImageHandlerFinished(succeded:Bool, data:NSData?)
}

class SurveillanceHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate{
    
    var delegate:GetImageHandler?
    
    init(surv: Surveilence) {
        super.init()
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        
        print(base64LoginString)
        
        let url = NSURL(string: "\(surv.ip!):\(surv.port!)/")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                print(response)
                print(data)
                self.delegate?.getImageHandlerFinished(true, data: data!)
            }else{
                self.delegate?.getImageHandlerFinished(false, data: nil)
            }
            
        }
        task.resume()
    }
    

}
