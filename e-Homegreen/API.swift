//
//  API.swift
//  API
//
//  Created by Sladjan Nimcevic on 12/7/15.
//  Copyright © 2015 Sladjan Nimcevic. All rights reserved.
//

import UIKit
import Alamofire

//Vec sam deklarisao na jednom mestu :)
//typealias JSONDictionary = [String:AnyObject]

enum APIResponse {
    case Error(NSError)
    case Success(AnyObject?)
}
enum APIProgressResponse {
    case Error(NSError)
    case Success(NSData?)
    case Progress(Double)
}

class API{
    
    private func craeteHeaders() -> Dictionary<String,String>? {
        if let token = userDefaults.valueForKey("token") as? String {
            return ["Authorization":"Bearer " + token]
        }
        return nil
    }
    
    static let shared = API()
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    func sendRequest(method:Alamofire.Method, url:String, parameters:Dictionary<String,AnyObject>? = nil,completionResponse:(completion: APIResponse) -> ()){
        switch method {
        case .GET:
            Alamofire.request(method, url, parameters: nil, headers: craeteHeaders())
                .response { request, response, data, error in
                    self.createResponse(request, response: response, data: data, error: error){
                        completion in
                        completionResponse(completion: completion)
                    }
            }
        default:
            Alamofire.request(method, url, parameters: parameters, encoding: ParameterEncoding.JSON, headers: craeteHeaders())
                .response { request, response, data, error in
                    self.createResponse(request, response: response, data: data, error: error){
                        completion in
                        completionResponse(completion: completion)
                    }
            }
        }
    }
    private func createResponse(request:NSURLRequest?, response:NSHTTPURLResponse?, data:NSData?, error:NSError?, completionResponse:(completion:APIResponse) -> ()){
        if let response = response {
            let statusCode = response.statusCode
            switch statusCode {
            case 200:
                if let data = data {
                    completionResponse(completion: .Success(data))
                }else{
                    completionResponse(completion: .Success(nil))
                }
            default:
                if let data = data {
                    let message = String(data: data, encoding: NSUTF8StringEncoding)//extract from data
                    var userInfo = [NSObject: AnyObject]()
                    userInfo[NSLocalizedDescriptionKey] = message
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionResponse(completion: .Error(error))
                }
                else if let error = error {
                    completionResponse(completion: .Error(error))
                }else{
                    let message = "Server Error"
                    var userInfo = [NSObject: AnyObject]()
                    userInfo[NSLocalizedDescriptionKey] = message
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionResponse(completion: .Error(error))
                }
            }
        }else{
            let message = "Server Error"
            var userInfo = [NSObject: AnyObject]()
            userInfo[NSLocalizedDescriptionKey] = message
            let error = NSError(domain: "API", code: 321, userInfo: userInfo)
            completionResponse(completion: .Error(error))
        }
    }
    
    func downloadFileFromUrl(url:String, destination:URLStringConvertible, parameters:Dictionary<String,AnyObject>,completionResponse:(completion: APIProgressResponse) -> ()){
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
        Alamofire.download(.GET, url, parameters: parameters, encoding: ParameterEncoding.URLEncodedInURL, headers: craeteHeaders(), destination: destination)
            .progress {bytesRead, totalBytesRead, totalBytesExpectedToRead in
                completionResponse(completion: .Progress(Double(totalBytesRead/totalBytesExpectedToRead)))
                
            }.response {request, response, data, error in
                self.createResponseForDownload(request, response: response, data: data, error: error){
                    completion in
                    completionResponse(completion: completion)
                }
        }
    }
    
    private func createResponseForDownload(request:NSURLRequest?, response:NSHTTPURLResponse?, data:NSData?, error:NSError?, completionResponse:(completion:APIProgressResponse) -> ()){
        if let response = response {
            let statusCode = response.statusCode
            switch statusCode {
            case 200:
                if let data = data {
                    completionResponse(completion: .Success(data))
                }else{
                    completionResponse(completion: .Success(nil))
                }
            default:
                if let data = data {
                    let message = String(data: data, encoding: NSUTF8StringEncoding)//extract from data
                    var userInfo = [NSObject: AnyObject]()
                    userInfo[NSLocalizedDescriptionKey] = message
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionResponse(completion: .Error(error))
                }
                else if let error = error {
                    completionResponse(completion: .Error(error))
                }else{
                    let message = "Server Error"
                    var userInfo = [NSObject: AnyObject]()
                    userInfo[NSLocalizedDescriptionKey] = message
                    let error = NSError(domain: "API", code: statusCode, userInfo: userInfo)
                    completionResponse(completion: .Error(error))
                }
            }
        }
    }
}