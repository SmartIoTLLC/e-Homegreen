//
//  ChooseMacroVC.swift
//  e-Homegreen
//
//  When user long press on tableview cell in ScanDevicesViewController this popup is presented.
//  It is used to attach devices action to macros.
//
//  Created by Bratislav Baljak on 4/2/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import UIKit


class ChooseMacroPopupVC: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    var delayLabel: UILabel!
    var delayTimeTF: [EditTextField]!
    var twoDotsLabel: [UILabel]!
    var macroTableView: UITableView!
    var confirmButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
    }



}

extension ChooseMacroPopupVC: UITableViewDelegate, UITableViewDataSource {
    //Add fixed size of table view. Better solution.
}
