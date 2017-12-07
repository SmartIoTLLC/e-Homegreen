//
//  SecParamatarVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/5/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SecParamatarVC: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint? = .zero
    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    var security:Security!
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var centarY: NSLayoutConstraint!
    @IBOutlet weak var popUpTextView: CustomTextView!
    
    init(point:CGPoint, security: Security, newDescription: String? = nil){
        super.init(nibName: "SecParamatarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
        self.security = security
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        setupViews()
    }
    
    func setupViews() {
        popUpTextView.text = security.securityDescription
        popUpTextView.delegate = self
        textViewDidChange(popUpTextView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            centarY.constant = -80
        } else {
            centarY.constant = -60
        }
    }

    @IBAction func btnUpdate(_ sender: AnyObject) {
        if popUpTextView.text != "" {
            security.securityDescription = popUpTextView.text
            CoreDataController.sharedInstance.saveChanges()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if popUpTextView.isFirstResponder {
            if popUpView.frame.origin.y + popUpView.frame.size.height > self.view.frame.size.height - keyboardFrame.size.height {
                
                self.centarY.constant = -50
                
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 190 {
            textView.frame = newFrame
            popUpViewHeight.constant = textView.frame.size.height + 60
        }
        
        
    }
    
    func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: popUpView) { return false }
        return true
    }
    
}
extension SecParamatarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
        
    }
}

extension SecParamatarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showSecurityParametar (_ point:CGPoint, security: Security) {
        let sp = SecParamatarVC(point: point, security: security)
        self.present(sp, animated: true, completion: nil)
    }
}
