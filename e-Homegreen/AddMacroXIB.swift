//
//  AddMacroXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/7/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class AddMacroXIB: PopoverVC {
    
    var isPresenting: Bool = true
    
    var delegate:EditZoneDelegate?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var chooseOption: CustomGradientButton!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var btnSet: UIButton!
    @IBOutlet weak var btnAdd: UIButton!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    init(){
        super.init(nibName: "AddMacroXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        nameTextField.delegate = self
        
//        slider.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditZoneViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func nameAndId(_ name: String, id: String) {
        chooseOption.setTitle(name, for: [])
    }
    
    @IBAction func levelButton(_ sender: AnyObject) {
//        var popoverList:[PopOverItem] = []
//        
//        let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
//        for item in list {
//            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
//        }
//        
//        popoverList.insert(PopOverItem(name: "", id: ""), at: 0)
//        openPopover(sender, popOverList:popoverList)
        
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddMacroXIB : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddMacroXIB : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            self.view.endEditing(true)
            return false
        }
        return true
    }
}

extension AddMacroXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension AddMacroXIB : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showAddMacro() {
        let addMacro = AddMacroXIB()
        self.present(addMacro, animated: true, completion: nil)
    }
}
