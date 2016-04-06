//
//  InsertGatewayAddressXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

struct Address {
    var firstByte:Int
    var secondByte:Int
    var thirdByte:Int
}

protocol AddAddressDelegate{
    func addAddressFinished(address:Address)
}

class InsertGatewayAddressXIB: UIViewController,UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var isPresenting: Bool = true
    
    var delegate:AddAddressDelegate?
    
    @IBOutlet weak var addressOne: EditTextField!
    @IBOutlet weak var addressTwo: EditTextField!
    @IBOutlet weak var addressThree: EditTextField!
    
    @IBOutlet weak var scan: CustomGradientButtonWhite!
    @IBOutlet weak var cancel: CustomGradientButtonWhite!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    init(){
        super.init(nibName: "InsertGatewayAddressXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        scan.layer.cornerRadius = 2
        cancel.layer.cornerRadius = 2
        
        addressOne.delegate = self
        addressTwo.delegate = self
        addressThree.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(InsertGatewayAddressXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(InsertGatewayAddressXIB.endEditingNow) )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        addressOne.inputAccessoryView = keyboardDoneButtonView
        addressTwo.inputAccessoryView = keyboardDoneButtonView
        addressThree.inputAccessoryView = keyboardDoneButtonView

    }
    
    func endEditingNow(){
        addressOne.resignFirstResponder()
        addressTwo.resignFirstResponder()
        addressThree.resignFirstResponder()        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func scan(sender: AnyObject) {
        guard let firstAddress = addressOne.text where firstAddress != "", let secondAddress = addressTwo.text where secondAddress != "", let thirdAddress = addressThree.text where thirdAddress != "" else{
            self.view.makeToast(message: "All fields must be filled")
            return
        }
        guard let addressOne = Int(firstAddress), let addressTwo = Int(secondAddress), let addressThree = Int(thirdAddress) else{
            self.view.makeToast(message: "Insert number in field")
            return
        }
        self.dismissViewControllerAnimated(true) { 
            self.delegate?.addAddressFinished(Address(firstByte: addressOne, secondByte: addressTwo, thirdByte: addressThree))
        }
        
    }
    
    

}

extension InsertGatewayAddressXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension InsertGatewayAddressXIB : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showAddAddress() -> InsertGatewayAddressXIB {
        let addAddress = InsertGatewayAddressXIB()
        self.presentViewController(addAddress, animated: true, completion: nil)
        return addAddress
    }
}
