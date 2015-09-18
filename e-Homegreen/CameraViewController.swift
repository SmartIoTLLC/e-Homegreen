//
//  CameraViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraViewController: CommonViewController {
    
    
    @IBOutlet weak var liveStreamWebView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = NSURL(string: "http://192.168.0.33:8081/")
        let myUrlRequest:NSURLRequest = NSURLRequest(URL: myURL!)
        liveStreamWebView.loadRequest(myUrlRequest)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
