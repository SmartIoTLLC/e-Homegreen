//
//  SecurityLocationXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 9/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class SecurityLocationXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var textView: UITextView!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "SecurityLocationXIB", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = UIBezierPath(roundedRect:textView.bounds, byRoundingCorners:[.topRight, .topLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        textView.layer.mask = maskLayer

    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }

    @IBAction func update(_ sender: AnyObject) {
        
    }
}

extension SecurityLocationXIB: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension UIViewController {
    func showSecurityLocationParametar() -> SecurityLocationXIB {
        let vc = SecurityLocationXIB()
        self.present(vc, animated: true, completion: nil)
        return vc
    }
}
