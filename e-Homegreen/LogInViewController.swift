//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func localIP(sender: AnyObject) {
        showAleartWithMessage("Local Connection Settings")
    }

    @IBAction func remoteIP(sender: AnyObject) {
        showAleartWithMessage("Remote Connection Settings")
    }
    

}
