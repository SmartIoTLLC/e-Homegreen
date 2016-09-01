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
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: "SecurityLocationXIB", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = UIBezierPath(roundedRect:textView.bounds, byRoundingCorners:[.TopRight, .TopLeft], cornerRadii: CGSizeMake(5, 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        textView.layer.mask = maskLayer

    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }

    @IBAction func update(sender: AnyObject) {
        
    }
}

extension SecurityLocationXIB: UITextViewDelegate{
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
        self.presentViewController(vc, animated: true, completion: nil)
        return vc
    }
}
