//
//  LogInViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/6/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var remote: UIButton!
    @IBOutlet weak var local: UIButton!
    
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
    @IBAction func remote(sender: AnyObject) {
        showAleartWithMessage("Remote Connection Settings")
    }
    
    @IBAction func local(sender: AnyObject) {
        showAleartWithMessage("Local Connection Settings")
    }



}
