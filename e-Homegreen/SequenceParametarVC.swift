//
//  SequenceParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SequenceParametarVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    var sequence:Sequence?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var cyclesTextField: UITextField!
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    var isPresenting: Bool = true
    
    init(point:CGPoint){
        super.init(nibName: "SequenceParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SequenceParametarVC.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        cyclesTextField.text = "\(sequence!.sequenceCycles)"
        isBroadcast.tag = 100
        isBroadcast.isOn = sequence!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(SequenceParametarVC.changeValue(_:)), for: UIControlEvents.valueChanged)
        isLocalcast.tag = 200
        isLocalcast.isOn = sequence!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(SequenceParametarVC.changeValue(_:)), for: UIControlEvents.valueChanged)
        appDel = UIApplication.shared.delegate as! AppDelegate
        cyclesTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func changeValue (_ sender:UISwitch){
        if sender.tag == 100 {
            if sender.isOn == true {
                isLocalcast.isOn = false
            } else {
                isLocalcast.isOn = false
            }
        } else if sender.tag == 200 {
            if sender.isOn == true {
                isBroadcast.isOn = false
            } else {
                isBroadcast.isOn = false
            }
        }
    }
    
    func dismissViewController () {
//        if cyclesTextField.text != "" {
//            if let cycles = Int(cyclesTextField.text!) {
//                sequence?.sequenceCycles = cycles
//                saveChanges()
//            }
//        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnSave(_ sender: AnyObject) {
        if isBroadcast.isOn {
            sequence?.isBroadcast = true
        } else {
            sequence?.isBroadcast = false
        }
        if isLocalcast.isOn {
            sequence?.isLocalcast = true
        } else {
            sequence?.isLocalcast = false
        }
        if cyclesTextField.text != "" {
            if let cycles = Int(cyclesTextField.text!) {
                sequence?.sequenceCycles = NSNumber(value: cycles)
            }
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshSequence), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SequenceParametarVC : UIViewControllerAnimatedTransitioning {
    
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
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
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
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension SequenceParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showSequenceParametar(_ point:CGPoint, sequence:Sequence) {
        let sp = SequenceParametarVC(point: point)
//        ad.indexPathRow = indexPathRow
        sp.sequence = sequence
        self.present(sp, animated: true, completion: nil)
    }
}
