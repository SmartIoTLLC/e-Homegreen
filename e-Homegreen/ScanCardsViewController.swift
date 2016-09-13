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
    
    var gateway:Gateway!
    var cards:[Card] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardsTableView.tableFooterView = UIView()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        
        devAddressThree.delegate = self
        toTextField.delegate = self
        fromTextField.delegate = self
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.enabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.enabled = false

        // Do any additional setup after loading the view.
    }

    @IBAction func clearRangeTextFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    func reloadCards(){
        cards = DatabaseCardsController.shared.getCardsByGateway(gateway)
        cardsTableView.reloadData()
    }
    
}

extension ScanCardsViewController: UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
}

extension ScanCardsViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(CardCell)) as? CardCell {
            cell.backgroundColor = UIColor.clearColor()
            
            cell.labelID.text = "\(cards[indexPath.row].id)"
            cell.cardNameLabel.text = cards[indexPath.row].cardName
            cell.cardIdLabel.text = cards[indexPath.row].cardId
            cell.address.text = "\(cards[indexPath.row].gateway.addressOne):\(cards[indexPath.row].gateway.addressTwo):\(cards[indexPath.row].timerAddress):\(cards[indexPath.row].timerId)"
            
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
