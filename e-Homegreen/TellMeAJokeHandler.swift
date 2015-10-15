//
//  TellMeAJokeHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/15/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class TellMeAJokeHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    func getJokeCompletion(completion:(result:String) -> Void){
        
        let url = NSURL(string: "http://api.icndb.com/jokes/random")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil{
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                    print(json)
                    if let value = json["value"] as? NSDictionary{
                        if let joke = value["joke"] as? String{
                            completion(result: joke)
                        }
                    }
                } catch _ {
                    completion(result: "Something went wrong!!!")
                }
                
            }else{
                completion(result: "Something went wrong!!!")
            }
        }
        task.resume()
    }
    
    
}
