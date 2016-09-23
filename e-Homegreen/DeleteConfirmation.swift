//
//  DeleteConfirmation.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/24/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol DeleteAllDelegate {
    func deleteConfirmed()
}

class DeleteConfirmation: UIViewController {

    var delegate: DeleteAllDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func deleteAll(_ sender: AnyObject) {
        delegate?.deleteConfirmed()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
    }
    
}
