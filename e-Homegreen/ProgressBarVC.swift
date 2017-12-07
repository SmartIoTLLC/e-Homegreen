//
//  ProgressBarVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc protocol ProgressBarDelegate {
    func progressBarDidPressedExit()
}

class ProgressBarVC: UIViewController {
    var delegate:ProgressBarDelegate?
    
    @IBOutlet weak var progressBarView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblHowMuchOf: UILabel!
    
    var progressBarTitle:String = ""
    var percentage:Float = 0.0
    var howMuchOf:String = ""
    
    var isPresenting: Bool = true
    
    init (title:String, percentage: Float, howMuchOf:String) {
        super.init(nibName: "ProgressBarVC", bundle: nil)
        self.progressBarTitle = title
        self.percentage = percentage
        self.howMuchOf = howMuchOf
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func btnExit(_ sender: AnyObject) {
        delegate?.progressBarDidPressedExit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        progressBarView.layer.borderWidth = 1
        progressBarView.layer.borderColor = UIColor.lightGray.cgColor
        progressBarView.layer.cornerRadius = 5
        progressView.progress = percentage
        lblTitle.text = progressBarTitle
        lblPercentage.text = String.localizedStringWithFormat("%.01f", percentage) + " %"
        lblHowMuchOf.text = howMuchOf
    }
    
    func dissmissProgressBar () {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ProgressBarVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.05, scaleOneY: 1.05, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}



extension ProgressBarVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}
