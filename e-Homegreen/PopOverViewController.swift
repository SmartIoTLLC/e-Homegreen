//
//  PopOverViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 6/25/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData


protocol PopOverIndexDelegate
{
    /// Function returns name and ID of item selected
    func nameAndId(name : String, id:String)
}

class SecurityFeedback {
    var name:String
    var gateway:Gateway
    init(name: String, gateway:Gateway) {
        self.name = name
        self.gateway = gateway
    }
}

struct PopOverItem {
    var name:String
    var id:String
}

class PopOverViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var table: UITableView!
    
    var delegate : PopOverIndexDelegate?
    var popOverList:[PopOverItem] = []
    var cellWithTwoTextRows : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.layer.cornerRadius = 8
        
    }
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return false
    }
}

extension PopOverViewController: UITableViewDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if cellWithTwoTextRows {
            if let cell = tableView.dequeueReusableCellWithIdentifier(String(PullDownViewTwoRowsCell)) as? PullDownViewTwoRowsCell {
                
                cell.tableItemName.text = popOverList[indexPath.row].name
                cell.tableItemDescription.text = popOverList[indexPath.row].id
                return cell
            }

        }else{
            if let cell = tableView.dequeueReusableCellWithIdentifier("pullCell") as? PullDownViewCell {
                cell.tableItem.text = popOverList[indexPath.row].name
                return cell
            }
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate?.nameAndId(popOverList[indexPath.row].name, id: popOverList[indexPath.row].id)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popOverList.count
    }
    
}


