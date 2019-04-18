//
//  CameraVC.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/7/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class CameraVC: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    
    @IBOutlet weak var leftButton: LeftCustomButtom!
    @IBOutlet weak var rightButton: CustomButton!
    @IBOutlet weak var topButton: TopButton!
    @IBOutlet weak var bottomButtom: BottomButton!
    @IBOutlet weak var btnAutoPan: CustomGradientButtonWhite!
    @IBOutlet weak var btnhome: CustomGradientButtonWhite!
    @IBOutlet weak var btnPresetSequence: CustomGradientButtonWhite!
    
    var isAutoPanStop = false
    var isPresetSequenceStop = false
    
    var surv:Surveillance!
    var point:CGPoint?
    var oldPoint:CGPoint? = .zero
    
    var moveCam:MoveCameraHandler = MoveCameraHandler()
    
    var isPresenting: Bool = true
    
    var timer:Foundation.Timer = Foundation.Timer()
    
    @IBOutlet weak var backViewHeightConstraint: NSLayoutConstraint!
    
    
    init(point:CGPoint, surv:Surveillance){
        super.init(nibName: "CameraVC", bundle: nil)
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
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CameraVC.update), userInfo: nil, repeats: true)

        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            print("vodoravno")
        } else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func exitButton(_ sender: AnyObject) {
        timer.invalidate()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnAutoPan(_ sender: AnyObject) {
        var title = ""
        if isAutoPanStop { title = "AUTO PAN" } else { title = "STOP" }
        btnAutoPan.setTitle(title, for: UIControl.State())
        moveCam.autoPan(surv, isStopNecessary: isAutoPanStop)
        isAutoPanStop = !isAutoPanStop
    }
    
    @IBAction func btnHome(_ sender: AnyObject) {
        moveCam.home(surv)
    }
    
    @IBAction func btnPresetSequence(_ sender: AnyObject) {
        var title = ""
        if isPresetSequenceStop { title = "PRESET SEQUENCE" } else { title = "STOP" }
        isPresetSequenceStop = !isPresetSequenceStop
        btnPresetSequence.setTitle(title, for: UIControl.State())
        moveCam.presetSequence(surv, isStopNecessary: isPresetSequenceStop)
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    @objc func update(){
        if surv.imageData != nil { image.image = UIImage(data: surv.imageData! as Data) } else { image.image = UIImage(named: "loading") }
    }
    
    @IBAction func leftButtomAction(_ sender: AnyObject) {
        moveCam.moveCamera(surv, position: "left")
    }
    
    @IBAction func rightButtomAction(_ sender: AnyObject) {
        moveCam.moveCamera(surv, position: "right")
    }
    
    @IBAction func topButtomAction(_ sender: AnyObject) {
        moveCam.moveCamera(surv, position: "up")
    }
    
    @IBAction func bottomButtomAction(_ sender: AnyObject) {
        moveCam.moveCamera(surv, position: "down")
    }

}

extension CameraVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.        
        animateTransitioning(isPresenting: &isPresenting, oldPoint: &oldPoint!, point: point!, using: transitionContext)
    }
}

extension CameraVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
extension UIViewController {
    func showCamera(_ point:CGPoint, surv:Surveillance) {
        let ad = CameraVC(point: point, surv:surv)
        self.present(ad, animated: true, completion: nil)
    }
}

