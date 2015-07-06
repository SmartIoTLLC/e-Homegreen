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
//        remote.layer.borderWidth = 0.5
//        remote.layer.borderColor = UIColor.blackColor().CGColor
//        
//        local.layer.borderWidth = 0.5
//        local.layer.borderColor = UIColor.blackColor().CGColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func remote(sender: AnyObject) {
        let alert = UIAlertController(title: "Remote IP", message: "Log in with remote IP", preferredStyle: .Alert)
        
        let dismissHandler = {
            (action: UIAlertAction!) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: dismissHandler))
//        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: dismissHandler))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            println(self.ipadress?.text)
            println(self.port?.text)

        }))
        alert.addTextFieldWithConfigurationHandler { textField in
            self.ipadress = textField
            textField.placeholder = "IP address"
        }
        alert.addTextFieldWithConfigurationHandler { textField in
            self.port = textField
            textField.placeholder = "Port"
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func local(sender: AnyObject) {
        showAleartWithMessage("nesto")
    }



}
