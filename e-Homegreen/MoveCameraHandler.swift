//
//  MoveCameraHandler.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/28/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class MoveCameraHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    func home(_ surv:Surveillance) {
        let username = surv.username
        let password = surv.password
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        var url:URL
            var urlExtension = ""
            if surv.urlHome == "" {urlExtension = "/cgi-bin/longcctvhome.cgi?action=gohome"} else {urlExtension = surv.urlHome!}
            url = URL(string: "http://\(surv.ip!):\(surv.port!)\(urlExtension)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
        }
 
        task.resume()
    }
    func moveCamera(_ surv: Surveillance, position: String){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        var url:URL
        var urlMain = ""
            urlMain = "http://\(surv.ip!):\(surv.port!)"
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
        url = URL(string: "\(urlMain)\(urlExtension)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error == nil{
                
            }else{
                
            }
            
        }) 
        task.resume()
    }
    func autoPan(_ surv: Surveillance, isStopNecessary:Bool){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        var url:URL
        var urlMain = ""
            urlMain = "http://\(surv.ip!):\(surv.port!)"
        var urlExtension = ""
        if isStopNecessary {
            if surv.urlAutoPanStop == "" {urlExtension = "/cgi-bin/longcctvapn.cgi?action=stop"} else {urlExtension = surv.urlAutoPanStop!}
        } else {
            if surv.urlAutoPan == "" {urlExtension = "/cgi-bin/longcctvapn.cgi?action=go&speed=\(surv.autSpanStep!)"} else {urlExtension = surv.urlAutoPan!}
        }
        url = URL(string: "\(urlMain)\(urlExtension)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if error == nil{
                
            }else{
                
            }
            
        }) 
        task.resume()
    }
    func presetSequence(_ surv: Surveillance, isStopNecessary:Bool){
        let username = surv.username
        let password = surv.password
        
        let loginString = NSString(format: "%@:%@", username!, password!)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        
        var url:URL
        var urlMain = ""
            urlMain = "http://\(surv.ip!):\(surv.port!)"
            url = URL(string: "/cgi-bin/longcctvseq.cgi?action=go")!
        var urlExtension = ""
        if isStopNecessary {
            if surv.urlPresetSequenceStop == "" {urlExtension = "/cgi-bin/longcctvseq.cgi?action=stop"} else {urlExtension = surv.urlPresetSequenceStop!}
        } else {
            if surv.urlPresetSequence == "" {urlExtension = "/cgi-bin/longcctvseq.cgi?action=go"} else {urlExtension = surv.urlPresetSequence!}
        }
        url = URL(string: "\(urlMain)\(urlExtension)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil{
                
            }else{
                
            }
        }
        task.resume()
    }
}
