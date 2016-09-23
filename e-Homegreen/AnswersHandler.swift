//
//  AnswersHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/14/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class AnswersHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    func getAnswerComplition(_ question:String, completion:@escaping (_ result:String) -> Void){
        
        let questionTemp = question.replacingOccurrences(of: " ", with: "_")
        let url = URL(string: "http://answers.com/Q/\(questionTemp)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request) { (data, rasponse, error) in
            if error == nil{
                if let returnS = String(data: data!, encoding: String.Encoding.utf8){
                    if var returnString = returnS.sliceFrom("<div class=\"answer_text\">\n\t\t\t\t\t\t\t\t", to: "\t\t\t\t\t\t\t</div>"){
                        returnString = returnString.replacingOccurrences(of: "\n", with: "", options: .regularExpression, range: nil)
                        returnString = returnString.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
                        completion(returnString)
                    }else{
                        completion("")
                    }
                }else{
                    completion("")
                }
                
            }else{
                completion("")
            }
        }
         
        task.resume()
    }
}

extension String {
    func sliceFrom(_ start: String, to: String) -> String? {
        return (range(of: start)?.upperBound).flatMap { sInd in
            (range(of: to, range: sInd..<endIndex)?.lowerBound).map { eInd in
                substring(with: sInd..<eInd)
            }
        }
    }
}
