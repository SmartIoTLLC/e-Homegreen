//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    

    
    var ipadress: UITextField?
    var port: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        inSocket = InSocket()
        outSocket = OutSocket()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var inSocket:InSocket!
    var outSocket:OutSocket!


    @IBAction func localIP(sender: AnyObject) {
        showAleartWithMessage("Local Connection Settings")
    }

    @IBAction func remoteIP(sender: AnyObject) {
        showAleartWithMessage("Remote Connection Settings")
    }
    

}
