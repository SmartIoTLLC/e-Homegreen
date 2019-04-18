//
//  CameraParametarXIBViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/2/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraParametarXIBViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var point:CGPoint?
    var oldPoint:CGPoint? = .zero
    
    var isPresenting: Bool = true
    
    var surv:Surveillance!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var panStepSlider: UISlider!
    @IBOutlet weak var tiltStepSlider: UISlider!
    @IBOutlet weak var autoPanStepSlider: UISlider!
    @IBOutlet weak var dwellTimeSlider: UISlider!
    
    @IBOutlet weak var panStepLabel: UILabel!
    @IBOutlet weak var tiltStepLabel: UILabel!
    @IBOutlet weak var autoPanStepLabel: UILabel!
    @IBOutlet weak var dwellTimeLabel: UILabel!
    
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
        
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.clear

        panStepSlider.addTarget(self, action: #selector(changePanStep(_:)), for: .valueChanged)
        tiltStepSlider.addTarget(self, action: #selector(changeTiltStep(_:)), for: .valueChanged)
        autoPanStepSlider.addTarget(self, action: #selector(changeAutoPanStep(_:)), for: .valueChanged)
        dwellTimeSlider.addTarget(self, action: #selector(changeDwellTimeSlider(_:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        panStepSlider.value = Float(surv.panStep!)
        tiltStepSlider.value = Float(surv.tiltStep!)
        autoPanStepSlider.value = Float(surv.autSpanStep!)
        dwellTimeSlider.value = Float(surv.dwellTime!)
        
        panStepLabel.text = "\(panStepSlider.value)"
        tiltStepLabel.text = "\(tiltStepSlider.value)"
        autoPanStepLabel.text = "\(autoPanStepSlider.value)"
        dwellTimeLabel.text = "\(dwellTimeSlider.value)"
    }
    
    @objc func changePanStep(_ slider: UISlider){
        slider.value = round(slider.value)
        panStepLabel.text = "\(round(slider.value))"
    }
    
    @objc func changeTiltStep(_ slider: UISlider){
        slider.value = round(slider.value)
        tiltStepLabel.text = "\(round(slider.value))"
    }
    
    @objc func changeAutoPanStep(_ slider: UISlider){
        slider.value = round(slider.value)
        autoPanStepLabel.text = "\(round(slider.value))"
    }
    
    @objc func changeDwellTimeSlider(_ slider: UISlider){
        slider.value = round(slider.value)
        dwellTimeLabel.text = "\(round(slider.value))"
    }
    
    @IBAction func btnSave(_ sender: AnyObject) {
        
        surv!.panStep = panStepSlider.value as NSNumber?
        surv!.tiltStep = tiltStepSlider.value as NSNumber?
        surv!.autSpanStep = autoPanStepSlider.value as NSNumber?
        surv!.dwellTime = dwellTimeSlider.value as NSNumber?
        CoreDataController.sharedInstance.saveChanges()
        
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    @objc func dismissViewController () {
        dismiss(animated: true, completion: nil)
    }
    
}

extension CameraParametarXIBViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
    }
}

extension CameraParametarXIBViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showCameraParametar(_ point:CGPoint, surveillance:Surveillance) {
        let sp = CameraParametarXIBViewController(point: point, surv: surveillance)
        present(sp, animated: true, completion: nil)
    }
}
