//
//  SurveilenceUrlsVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 11/26/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class SurveilenceUrlsVC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
//    /dms?nowprofileid=2 -- getting images
//    /cgi-bin/longcctvmove.cgi?action=move&amp;direction=down&amp;panstep=1&amp;tiltstep=15 -- move down
//    /cgi-bin/longcctvmove.cgi?action=move&amp;direction=right&amp;panstep=1&amp;tiltstep=15 -- move right
//    /cgi-bin/longcctvmove.cgi?action=move&amp;direction=up&amp;panstep=1&amp;tiltstep=15 -- move up
//    /cgi-bin/longcctvmove.cgi?action=move&amp;direction=left&amp;panstep=1&amp;tiltstep=15 -- move left
//    /cgi-bin/longcctvapn.cgi?action=go&speed=1 -- auto pan
//    /cgi-bin/longcctvapn.cgi?action=stop -- auto pan stop
//    /cgi-bin/longcctvseq.cgi?action=go -- preset sequence
//    /cgi-bin/longcctvseq.cgi?action=stop  -- preset sequence stop
//    /cgi-bin/longcctvhome.cgi?action=gohome -- home
    
    var getImage = "/dms?nowprofileid=2"
    var moveRight = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=right&amp;panstep=1&amp;tiltstep=15"
    var moveLeft = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=left&amp;panstep=1&amp;tiltstep=15"
    var moveUp = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=up&amp;panstep=1&amp;tiltstep=15"
    var moveDown = "/cgi-bin/longcctvmove.cgi?action=move&amp;direction=down&amp;panstep=1&amp;tiltstep=15"
    var autoPan = "/cgi-bin/longcctvapn.cgi?action=go&speed=1"
    var stopAutoPan = "/cgi-bin/longcctvapn.cgi?action=stop"
    var presetSequence = "/cgi-bin/longcctvseq.cgi?action=go"
    var stopPresetSequence = "/cgi-bin/longcctvseq.cgi?action=stop"
    var home = "/cgi-bin/longcctvhome.cgi?action=gohome"
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    var surv:Surveillance?
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var txtGetImage: UITextField!
    @IBOutlet weak var txtMoveLeft: UITextField!
    @IBOutlet weak var txtMoveRight: UITextField!
    @IBOutlet weak var txtMoveUp: UITextField!
    @IBOutlet weak var txtMoveDown: UITextField!
    @IBOutlet weak var txtAutoPan: UITextField!
    @IBOutlet weak var txtStopAutoPan: UITextField!
    @IBOutlet weak var txtPresetSequence: UITextField!
    @IBOutlet weak var txtStopPresetSequence: UITextField!
    @IBOutlet weak var txtHome: UITextField!
    
    init(point:CGPoint, surv:Surveillance){
        super.init(nibName: "SurveilenceUrlsVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.point = point
        self.surv = surv
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        txtGetImage.delegate = self
        txtMoveLeft.delegate = self
        txtMoveRight.delegate = self
        txtMoveUp.delegate = self
        txtMoveDown.delegate = self
        txtAutoPan.delegate = self
        txtStopAutoPan.delegate = self
        txtPresetSequence.delegate = self
        txtStopPresetSequence.delegate = self
        txtHome.delegate = self
        
        txtGetImage.placeholder = getImage
        txtMoveLeft.placeholder = moveLeft
        txtMoveRight.placeholder = moveRight
        txtMoveUp.placeholder = moveUp
        txtMoveDown.placeholder = moveDown
        txtAutoPan.placeholder = autoPan
        txtStopAutoPan.placeholder = stopAutoPan
        txtPresetSequence.placeholder = presetSequence
        txtStopPresetSequence.placeholder = stopPresetSequence
        txtHome.placeholder = home
        
        txtGetImage.text = surv!.urlGetImage
        txtMoveLeft.text = surv!.urlMoveLeft
        txtMoveRight.text = surv!.urlMoveRight
        txtMoveUp.text = surv!.urlMoveUp
        txtMoveDown.text = surv!.urlMoveDown
        txtAutoPan.text = surv!.urlAutoPan
        txtStopAutoPan.text = surv!.urlAutoPanStop
        txtPresetSequence.text = surv!.urlPresetSequence
        txtStopPresetSequence.text = surv!.urlPresetSequenceStop
        txtHome.text = surv!.urlHome
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    func dismissViewController () {
        resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewWillDisappear(animated: Bool) {
        resignFirstResponders()
    }
    func resignFirstResponders () {
        txtGetImage.resignFirstResponder()
        txtMoveLeft.resignFirstResponder()
        txtMoveRight.resignFirstResponder()
        txtMoveUp.resignFirstResponder()
        txtMoveDown.resignFirstResponder()
        txtAutoPan.resignFirstResponder()
        txtStopAutoPan.resignFirstResponder()
        txtPresetSequence.resignFirstResponder()
        txtStopPresetSequence.resignFirstResponder()
        txtHome.resignFirstResponder()
    }
    
    func saveChanges() {
        appDel.establishAllConnections()
    }
    
    @IBAction func btnCancel(sender: AnyObject) {
        resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func btnSave(sender: AnyObject) {
        print(txtGetImage.text)
        print(surv!.urlGetImage)
        print(txtGetImage.text!)
        print(surv!.urlGetImage!)
        print(surv!.objectID)
        print(surv!.name)
        print(surv!.urlGetImage)
        print(surv!.urlGetImage)
        print(surv!.urlGetImage)
        print(surv!.urlGetImage)
        if txtGetImage.text != "" {surv!.urlGetImage! = txtGetImage.text!}
        if txtMoveRight.text != "" {surv!.urlMoveRight! = txtMoveRight.text!}
        if txtMoveLeft.text != "" {surv!.urlMoveLeft! = txtMoveLeft.text!}
        if txtMoveUp.text != "" {surv!.urlMoveUp! = txtMoveUp.text!}
        if txtMoveDown.text != "" {surv!.urlMoveDown! = txtMoveDown.text!}
        if txtAutoPan.text != "" {surv!.urlAutoPan! = txtAutoPan.text!}
        if txtStopAutoPan.text != "" {surv!.urlAutoPanStop! = txtStopAutoPan.text!}
        if txtPresetSequence.text != "" {surv!.urlPresetSequence! = txtPresetSequence.text!}
        if txtStopPresetSequence.text != "" {surv!.urlPresetSequenceStop! = txtStopPresetSequence.text!}
        if txtHome.text != "" {surv!.urlHome! = txtHome.text!}
//        txtGetImage.resignFirstResponder()
//        txtMoveLeft.resignFirstResponder()
//        txtMoveRight.resignFirstResponder()
//        txtMoveUp.resignFirstResponder()
//        txtMoveDown.resignFirstResponder()
//        txtAutoPan.resignFirstResponder()
//        txtStopAutoPan.resignFirstResponder()
//        txtPresetSequence.resignFirstResponder()
//        txtStopPresetSequence.resignFirstResponder()
//        txtHome.resignFirstResponder()
        print(surv!)
        CoreDataController.shahredInstance.saveChanges()
        saveChanges()
        
        resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
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
extension SurveilenceUrlsVC : UIViewControllerAnimatedTransitioning {
    
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

extension SurveilenceUrlsVC : UIViewControllerTransitioningDelegate {
    
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
    func showCameraUrls (point:CGPoint, surveillance:Surveillance) {
        let scu = SurveilenceUrlsVC(point: point, surv: surveillance)
//        scu.surv = surveillance
        self.presentViewController(scu, animated: true, completion: nil)
    }
}