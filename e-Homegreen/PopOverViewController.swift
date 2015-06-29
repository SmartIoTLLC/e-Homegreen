//
//  PopOverViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

protocol PopOverIndexDelegate
{
    func saveText(var strText : String)
}

class PopOverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var locationList:[String] = ["All"]
    var levelList:[String] = ["Level 1", "All"]
    var zoneList:[String] = ["Zone 1", "Zone 2", "All"]
    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    var tableList:[String] = []
    
    
    @IBOutlet weak var table: UITableView!
    
    var indexTab: Int = 0
    var delegate : PopOverIndexDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if indexTab == 1{
            tableList = locationList
        }else if indexTab == 2{
            tableList = levelList
        }else if indexTab == 3{
            tableList = zoneList
        }else {
            tableList = categoryList
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("pullCell") as? PullDownViewCell {
            cell.tableItem.text = tableList[indexPath.row]
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.saveText(tableList[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableList.count
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }

    



}

class PullDownViewCell: UITableViewCell {
    
    @IBOutlet weak var tableItem: UILabel!
    
}
