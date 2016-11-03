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

class SurveillanceHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate{
    
//    static let shared = SurveillanceHandler()
    
    //    var delegate:GetImageHandler?
    
    init(surv: Surveillance) {
        super.init()
        
        if let username = surv.username, let password = surv.password {
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
            let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            var url:URL
            var urlMain = ""
                urlMain = "http://\(surv.ip!):\(surv.port!)"
            var urlExtension = ""
            if surv.urlGetImage == "" {
                urlExtension = "/dms?nowprofileid=3"
            } else {
                urlExtension = surv.urlGetImage!
            }
            url = URL(string: "\(urlMain)\(urlExtension)")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    surv.imageData = data
                    surv.lastDate = Date()
                }
            }
             
            task.resume()
        }
    }
}
