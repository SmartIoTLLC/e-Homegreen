//
//  AnswersHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/14/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class AnswersHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    func getAnswer(){
    
        var url = NSURL(string: "http://answers.com/Q/what_is_banana")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
//                print(response)
//                print(data)
                
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                
            }else{
                
            }
            
        }
        task.resume()
    }
 
    
}
