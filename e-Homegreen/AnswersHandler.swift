//
//  AnswersHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/14/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class AnswersHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    func getAnswerComplition(var question:String, completion:(result:String) -> Void){

        question = question.stringByReplacingOccurrencesOfString(" ", withString: "_")
        let url = NSURL(string: "http://answers.com/Q/\(question)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue())
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error == nil{
                let returnS = String(data: data!, encoding: NSUTF8StringEncoding)
                if var returnString = returnS!.sliceFrom("<div class=\"answer_text\">\n\t\t\t\t\t\t\t\t", to: "\t\t\t\t\t\t\t</div>"){
                    returnString = returnString.stringByReplacingOccurrencesOfString("\n", withString: "", options: .RegularExpressionSearch, range: nil)
                    returnString = returnString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                    completion(result: returnString)
                }else{
                    completion(result: "")
                }

            }else{
                completion(result: "")
            }
            
        }
        task.resume()
    }

 
    
}


extension String {
    
    func sliceFrom(start: String, to: String) -> String? {
        return (rangeOfString(start)?.endIndex).flatMap { sInd in
            (rangeOfString(to, range: sInd..<endIndex)?.startIndex).map { eInd in
                substringWithRange(sInd..<eInd)
            }
        }
    }
}
