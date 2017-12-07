//
//  SequenceParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SequenceParametarVC: UIViewController {
    
    var point:CGPoint?
    var oldPoint:CGPoint? = .zero
    var indexPathRow: Int = -1
    var sequence:Sequence?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var cyclesTextField: UITextField!
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }

    init(point:CGPoint) {
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
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        setupViews()
    }

}

// MARK: - View setup
extension SequenceParametarVC: UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        cyclesTextField.text = "\(sequence!.sequenceCycles)"
        isBroadcast.tag = 100
        isBroadcast.isOn = sequence!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        isLocalcast.tag = 200
        isLocalcast.isOn = sequence!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        
        cyclesTextField.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Logic
extension SequenceParametarVC {
    fileprivate func save() {
        if isBroadcast.isOn { sequence?.isBroadcast = true } else { sequence?.isBroadcast = false }
        if isLocalcast.isOn { sequence?.isLocalcast = true } else { sequence?.isLocalcast = false }
        
        if cyclesTextField.text != "" {
            if let cycles = Int(cyclesTextField.text!) { sequence?.sequenceCycles = NSNumber(value: cycles) }
        }
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshSequence), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func changeValue (_ sender:UISwitch) {
        if sender.tag == 100 {
            if sender.isOn == true { isLocalcast.isOn = false } else { isLocalcast.isOn = false }
        } else if sender.tag == 200 {
            if sender.isOn == true { isBroadcast.isOn = false } else { isBroadcast.isOn = false }
        }
    }
}

// MARK: - Animated Transition
extension SequenceParametarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
    }
}

extension SequenceParametarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showSequenceParametar(_ point:CGPoint, sequence:Sequence) {
        let sp = SequenceParametarVC(point: point)
        sp.sequence = sequence
        present(sp, animated: true, completion: nil)
    }
}
