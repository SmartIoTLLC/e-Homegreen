//
//  TagsXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/5/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class TagsXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var textField: UITextField!
    
    init(){
        super.init(nibName: "TagsXIB", bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }


}

extension TagsXIB: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showTag() -> TagsXIB{
        let tag = TagsXIB()
        self.present(tag, animated: true, completion: nil)
        return tag
    }
}
