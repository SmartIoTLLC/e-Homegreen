//
//  IntelligentSwitchParameter.swift
//  e-Homegreen
//
//  Created by Damir Djozic on 8/25/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class IntelligentSwitchParameter: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var backView: UIView!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var isPresenting: Bool = true
    var delegate: DevicePropertiesDelegate?
    var device:Device?
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var deviceAddress: UILabel!
    @IBOutlet weak var deviceChannel: UILabel!
    
    
    init(point:CGPoint){
        super.init(nibName: "IntelligentSwitchParameter", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        lblLocation.text = "\(devices[indexPathRow].gateway.name)"
        lblName.text = "\(devices[indexPathRow].name)"
        
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].parentZoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblLevel.text = "\(name)"
        }else{
            lblLevel.text = ""
        }
        if let zone = DatabaseHandler.returnZoneWithId(Int(devices[indexPathRow].zoneId), location: devices[indexPathRow].gateway.location), let name = zone.name {
            lblZone.text = "\(name)"
        }else{
            lblZone.text = ""
        }
        
        lblCategory.text = "\(DatabaseHandler.returnCategoryWithId(Int(devices[indexPathRow].categoryId), location: devices[indexPathRow].gateway.location))"
        deviceAddress.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].address)))"
        deviceChannel.text = "\(devices[indexPathRow].channel)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnSave(sender: AnyObject) {
        self.delegate?.saveClicked()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func getDeviceAndSave (numberOne:Int, numberTwo:Int, numberThree:Int) {
        if let deviceObject = appDel.managedObjectContext!.objectWithID(devices[indexPathRow].objectID) as? Device {
            device = deviceObject
            print(device)
            device!.delay = numberOne
            device!.runtime = numberTwo
            device!.skipState = numberThree
            CoreDataController.shahredInstance.saveChanges()
        }
    }
}

extension IntelligentSwitchParameter : UIViewControllerAnimatedTransitioning {
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
            self.oldPoint = presentedControllerView.center
            presentedControllerView.center = self.point!
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            containerView!.addSubview(presentedControllerView)
            
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                
                presentedControllerView.center = self.oldPoint!
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
                
                presentedControllerView.center = self.point!
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(0.2, 0.2)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension IntelligentSwitchParameter : UIViewControllerTransitioningDelegate {
    
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
    func showIntelligentSwitchParameter(point:CGPoint, indexPathRow: Int, devices:[Device]) {
        let ad = IntelligentSwitchParameter(point: point)
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        //        ad.device = device
        self.presentViewController(ad, animated: true, completion: nil)
    }
}
