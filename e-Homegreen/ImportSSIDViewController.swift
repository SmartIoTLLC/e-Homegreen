//
//  ImportSSIDViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ImportSSIDViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ssidCell") as? SSIDCell {
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    @IBAction func doneAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

class SSIDCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func setItem(){
        
    }
}
