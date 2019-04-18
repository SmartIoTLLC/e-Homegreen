//
//  EventParametarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/14/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class EventParametarVC: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint? = .zero
    var indexPathRow: Int = -1
    var event:Event?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var isPresenting: Bool = true

    
    @IBOutlet weak var backView: UIView!
    @IBOutlet var superView: UIView!
    
    @IBOutlet weak var isBroadcast: UISwitch!
    @IBOutlet weak var isLocalcast: UISwitch!
    @IBOutlet weak var useTrigger: UISwitch!
    
    @IBAction func btnSave(_ sender: AnyObject) {
        save()
    }
    
    init(point:CGPoint){
        super.init(nibName: "EventParametarVC", bundle: nil)
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
extension EventParametarVC {
    func setupViews() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        isBroadcast.tag  = 100
        isBroadcast.isOn = event!.isBroadcast.boolValue
        isBroadcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        isLocalcast.tag  = 200
        isLocalcast.isOn = event!.isLocalcast.boolValue
        isLocalcast.addTarget(self, action: #selector(changeValue(_:)), for: .valueChanged)
        useTrigger.isOn = event!.useTrigger
    }
    
    @objc func dismissViewController () {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
}

// MARK: - Logic
extension EventParametarVC {
    
    fileprivate func save() {
        if isBroadcast.isOn { event?.isBroadcast = true } else { event?.isBroadcast = false }
        if isLocalcast.isOn { event?.isLocalcast = true } else { event?.isLocalcast = false }
        if useTrigger.isOn { event?.useTrigger = true } else { event?.useTrigger = false }
        
        CoreDataController.sharedInstance.saveChanges()
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshEvent), object: self, userInfo: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changeValue (_ sender:UISwitch) {
        if sender.tag == 100 {
            if sender.isOn == true { isLocalcast.isOn = false } else { isLocalcast.isOn = false }
        } else if sender.tag == 200 {
            if sender.isOn == true { isBroadcast.isOn = false } else { isBroadcast.isOn = false }
        }
    }
}

extension EventParametarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
    }
}

extension EventParametarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showEventParametar(_ point:CGPoint, event:Event) {
        let ep = EventParametarVC(point: point)
        ep.event = event
        self.present(ep, animated: true, completion: nil)
    }
}
