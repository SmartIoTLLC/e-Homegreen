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
    func nameAndId(_ name : String, id:String)
}

//class SecurityFeedback {
//    var name:String
//    var gateway:Gateway
//    init(name: String, gateway:Gateway) {
//        self.name = name
//        self.gateway = gateway
//    }
//}

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
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if cellWithTwoTextRows {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PullDownViewTwoRowsCell())) as? PullDownViewTwoRowsCell {
                
                cell.tableItemName.text = popOverList[(indexPath as NSIndexPath).row].name
                cell.tableItemDescription.text = popOverList[(indexPath as NSIndexPath).row].id
                return cell
            }

        }else{
            if let cell = tableView.dequeueReusableCell(withIdentifier: "pullCell") as? PullDownViewCell {
                cell.tableItem.text = popOverList[(indexPath as NSIndexPath).row].name
                return cell
            }
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        delegate?.nameAndId(popOverList[(indexPath as NSIndexPath).row].name, id: popOverList[(indexPath as NSIndexPath).row].id)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popOverList.count
    }
    
}


