//
//  DimmerParametarVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 8/4/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DimmerParametarVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backView: UIView!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    var indexPathRow: Int = -1
    
    var devices:[Device] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var isPresenting: Bool = true
    
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editDelay: UITextField!
    @IBOutlet weak var editRunTime: UITextField!
    @IBOutlet weak var editSkipState: UITextField!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var overRideID: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLevel: UILabel!
    @IBOutlet weak var lblZone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    
    
    init(point:CGPoint){
        super.init(nibName: "DimmerParametarVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        editDelay.delegate = self
        editRunTime.delegate = self
        editSkipState.delegate = self
        
//        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        //        tapGesture.delegate = self
//        self.view.addGestureRecognizer(tapGesture)
//        self.view.tag = 1
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = backView.bounds
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        backView.layer.insertSublayer(gradient, atIndex: 0)
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGrayColor().CGColor
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        
//        devices[indexPathRow].zoneId
//        devices[indexPathRow].categoryId
//        devices[indexPathRow].delay
//        devices[indexPathRow].runtime
//        devices[indexPathRow].isEnabled
//        devices[indexPathRow].name
//        devices[indexPathRow].skipState
//        devices[indexPathRow].level
//        devices[indexPathRow].overrideControl1
//        devices[indexPathRow].overrideControl2
        //        devices[indexPathRow].overrideControl3@IBOutlet weak var lblName: UILabel!
        editDelay.text = "\(devices[indexPathRow].delay)"
        editRunTime.text = "\(devices[indexPathRow].runtime)"
        editSkipState.text = "\(devices[indexPathRow].skipState)"
        overRideID.text = "\(returnThreeCharactersForByte(Int(devices[indexPathRow].overrideControl1))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].overrideControl2))):\(returnThreeCharactersForByte(Int(devices[indexPathRow].overrideControl3)))"
        lblName.text = "\(devices[indexPathRow].name)"
        lblLevel.text = "\(devices[indexPathRow].parentZoneId)"
        lblZone.text = "\(devices[indexPathRow].zoneId)"
        lblCategory.text = "\(devices[indexPathRow].categoryId)"
        
        self.view.backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        let point:CGPoint = gesture.locationInView(self.view)
        let tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        print(tappedView.tag)
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                backViewHeightConstraint.constant = 250
            }else if self.view.frame.size.height == 375{
                backViewHeightConstraint.constant = 300
            }else if self.view.frame.size.height == 414{
                backViewHeightConstraint.constant = 350
            }else{
                backViewHeightConstraint.constant = 420
            }
        }else{
            
            backViewHeightConstraint.constant = 420
            
        }
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    @IBAction func btnSave(sender: AnyObject) {
        if let numberOne = Int(editDelay.text!), let numberTwo = Int(editRunTime.text!), let numberThree = Int(editSkipState.text!) {
            if numberOne <= 65534 && numberTwo <= 65534 && numberThree <= 100 {
                getDeviceAndSave(numberOne, numberTwo:numberTwo, numberThree:numberThree)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    var device:Device?
    func getDeviceAndSave (numberOne:Int, numberTwo:Int, numberThree:Int) {
        if let deviceObject = appDel.managedObjectContext!.objectWithID(devices[indexPathRow].objectID) as? Device {
            device = deviceObject
            print(device)
            device!.delay = numberOne
            device!.runtime = numberTwo
            device!.skipState = numberThree
            saveChanges()
        }
    }
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}

extension DimmerParametarVC : UIViewControllerAnimatedTransitioning {
    
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

extension DimmerParametarVC : UIViewControllerTransitioningDelegate {
    
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
    func showDimmerParametar(point:CGPoint, indexPathRow: Int, devices:[Device]) {
        let ad = DimmerParametarVC(point: point)
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }
}
