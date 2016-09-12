//
//  ScanCardsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 9/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanCardsViewController: UIViewController {
    
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    
    @IBOutlet weak var cardsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func clearRangeTextFields(sender: AnyObject) {
        let nsString4 = NSString(format: "%02X %02X %02X %02X %02X %02X%02X", 0xD3, 0x34, 0xA1, 0xD3, 0x34, 0xA1, 0x33)
        print(nsString4) // prints: "0C, 79, FF"
    }
    
}

extension ScanCardsViewController: UITableViewDelegate{
    
}

extension ScanCardsViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(CardCell)) as? CardCell {
            cell.backgroundColor = UIColor.clearColor()
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
}

class CardCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    @IBOutlet weak var address: UILabel!
    
}
