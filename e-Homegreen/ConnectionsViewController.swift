//
//  ConnectionsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ConnectionsViewController: UIViewController {
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    var backgroundImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonConstruct()
        if let ip = NSUserDefaults.standardUserDefaults().valueForKey("ipHost") as? String, let port = NSUserDefaults.standardUserDefaults().valueForKey("port") as? String {
            ipHostTextField.text = "\(ip)"
            portTextField.text = "\(port)"
        }
        // Do any additional setup after loading the view.
    }
    func commonConstruct() {
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 64, Common().screenWidth , Common().screenHeight-64)
        self.view.insertSubview(backgroundImageView, atIndex: 0)
    }
    @IBAction func btnSaveConnection(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue("\(ipHostTextField.text)", forKeyPath: "ipHost")
        NSUserDefaults.standardUserDefaults().setValue("\(portTextField.text)", forKeyPath: "port")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
