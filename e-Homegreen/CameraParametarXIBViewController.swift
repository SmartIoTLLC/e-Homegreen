//
//  CameraParametarXIBViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/2/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraParametarXIBViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var panStepSlider: UISlider!
    @IBOutlet weak var tiltStepSlider: UISlider!
    @IBOutlet weak var autoPanStepSlider: UISlider!
    @IBOutlet weak var dwellTimeSlider: UISlider!
    
    @IBOutlet weak var panStepLabel: UILabel!
    @IBOutlet weak var tiltStepLabel: UILabel!
    @IBOutlet weak var autoPanStepLabel: UILabel!
    @IBOutlet weak var dwellTimeLabel: UILabel!
    
    var point:CGPoint?
    var oldPoint:CGPoint?
    
    var isPresenting: Bool = true
    
    var surv:Surveillance!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    
    init(point:CGPoint, surv:Surveillance){
        super.init(nibName: "CameraParametarXIBViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.point = point
        self.surv = surv
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.clear
        
        panStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changePanStep(_:)), for: .valueChanged)
        tiltStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeTiltStep(_:)), for: .valueChanged)
        autoPanStepSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeAutoPanStep(_:)), for: .valueChanged)
        dwellTimeSlider.addTarget(self, action: #selector(CameraParametarXIBViewController.changeDwellTimeSlider(_:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraParametarXIBViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        panStepSlider.value = Float(surv.panStep!)
        tiltStepSlider.value = Float(surv.tiltStep!)
        autoPanStepSlider.value = Float(surv.autSpanStep!)
        dwellTimeSlider.value = Float(surv.dwellTime!)
        
        panStepLabel.text = "\(panStepSlider.value)"
        tiltStepLabel.text = "\(tiltStepSlider.value)"
        autoPanStepLabel.text = "\(autoPanStepSlider.value)"
        dwellTimeLabel.text = "\(dwellTimeSlider.value)"
    }
    
    func changePanStep(_ slider: UISlider){
        slider.value = round(slider.value)
        panStepLabel.text = "\(round(slider.value))"
    }
    
    func changeTiltStep(_ slider: UISlider){
        slider.value = round(slider.value)
        tiltStepLabel.text = "\(round(slider.value))"
    }
    
    func changeAutoPanStep(_ slider: UISlider){
        slider.value = round(slider.value)
        autoPanStepLabel.text = "\(round(slider.value))"
    }
    
    func changeDwellTimeSlider(_ slider: UISlider){
        slider.value = round(slider.value)
        dwellTimeLabel.text = "\(round(slider.value))"
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSave(_ sender: AnyObject) {
        
        surv!.panStep = panStepSlider.value as NSNumber?
        surv!.tiltStep = tiltStepSlider.value as NSNumber?
        surv!.autSpanStep = autoPanStepSlider.value as NSNumber?
        surv!.dwellTime = dwellTimeSlider.value as NSNumber?
        CoreDataController.shahredInstance.saveChanges()
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension CameraParametarXIBViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
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

extension CameraParametarXIBViewController : UIViewControllerTransitioningDelegate {
    
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
    func showCameraParametar(_ point:CGPoint, surveillance:Surveillance) {
        let sp = CameraParametarXIBViewController(point: point, surv: surveillance)
        self.present(sp, animated: true, completion: nil)
    }
}
