//
//  TellMeAJokeHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/15/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class TellMeAJokeHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    func getJokeCompletion(_ completion:@escaping (_ result:String) -> Void){
        
        let url = URL(string: "http://api.icndb.com/jokes/random")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil{
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                    print(json)
                    if let value = json["value"] as? NSDictionary{
                        if let joke = value["joke"] as? String{
                            completion(joke)
                        }
                    }
                } catch _ {
                    completion("Something went wrong!!!")
                }
                
            }else{
                completion("Something went wrong!!!")
            }
        }
         
        task.resume()
    }
    
    
}
