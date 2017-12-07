//
//  Extensions.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/26/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

extension UIButton {
    
    func switchFullscreen() {
        self.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            self.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            self.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        }
    }
    
    func switchFullscreen(viewThatNeedsOffset: UIScrollView) {
        self.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            self.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            self.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if viewThatNeedsOffset.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: viewThatNeedsOffset.contentSize.height - viewThatNeedsOffset.bounds.size.height + viewThatNeedsOffset.contentInset.bottom)
                viewThatNeedsOffset.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
}

extension UICollectionViewCell {
    func getByte(_ value: NSNumber) -> UInt8 {
        return UInt8(Int(value))
    }
}

extension UIViewController {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getByte(_ value: NSNumber) -> UInt8 {
        return UInt8(Int(value))
    }
    
    func getIByte(_ value: Int) -> UInt8 {
        return UInt8(value)
    }
    
    func changeFullscreenImage(fullscreenButton: UIButton) {
        if UIApplication.shared.isStatusBarHidden {
            fullscreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullscreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func updateConstraints(item: UIView) {
        view.addConstraint(NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: item, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: item, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func setupSWRevealViewController(menuButton: UIBarButtonItem) {
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            revealViewController().toggleAnimationDuration = 0.5
            revealViewController().rearViewRevealWidth = 200            
        }
    }
    
    func setTitleView(view: NavigationTitleView) {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            view.setLandscapeTitle()
        } else {
            view.setPortraitTitle()
        }
    }
    
    func dismissEditing() {
        view.endEditing(true)
    }
    
    func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func updateSubtitle(_ titleView: NavigationTitleView, title: String, location: String, level: String, zone: String) {
        titleView.setTitleAndSubtitle(title, subtitle: location + " " + level + " " + zone)
    }
    
    func calculateCellSize(completion: () -> Void) -> CGSize {
        var size: CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: view.frame.size.width)
        return size
    }
    
    func setContentOffset(for scrollView: FilterPullDown) {
        if scrollView.contentOffset.y > 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
    }
    
    func setContentOffset(forScan scrollView: ScanFilterPullDown) {
        if scrollView.contentOffset.y > 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
    }
    
    func moveTextfield(textfield: UITextField, keyboardFrame: CGRect, backView: UIView) {
        if textfield.isFirstResponder {
            if backView.frame.origin.y + textfield.frame.origin.y + 30 > self.view.frame.size.height - keyboardFrame.size.height {
                self.view.frame.origin.y = -(5 + (backView.frame.origin.y + textfield.frame.origin.y + 30 - (self.view.frame.size.height - keyboardFrame.size.height)))
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
    func animateTransitioning(isPresenting: inout Bool, oldPoint: inout CGPoint, point: CGPoint, using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            isPresenting = false
            
            if let presentedController = transitionContext.viewController(forKey: .to) {
                if let presentedControllerView = transitionContext.view(forKey: .to) {
                    let containerView = transitionContext.containerView
                    
                    presentedControllerView.frame     = transitionContext.finalFrame(for: presentedController)
                    oldPoint                          = presentedControllerView.center
                    presentedControllerView.center    = point
                    presentedControllerView.alpha     = 0
                    presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    containerView.addSubview(presentedControllerView)
                    
                    let oldPointValue = oldPoint
                    
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                        presentedControllerView.center    = oldPointValue
                        presentedControllerView.alpha     = 1
                        presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: {
                        (completed: Bool) -> Void in
                        transitionContext.completeTransition(completed)
                    })
                }
            }
            
        } else {
            if let presentedControllerView = transitionContext.view(forKey: .from) {
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                    presentedControllerView.center    = point
                    presentedControllerView.alpha     = 0
                    presentedControllerView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                }, completion: {
                    (completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
                })
            }
        }
        
    }
    
    func animateTransitioning(isPresenting: inout Bool, scaleOneX: CGFloat, scaleOneY: CGFloat, scaleTwoX: CGFloat, scaleTwoY: CGFloat, using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            isPresenting = false
            
            if let presentedController = transitionContext.viewController(forKey: .to) {
                if let presentedControllerView = transitionContext.view(forKey: .to) {
                    let containerView = transitionContext.containerView
                    
                    presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
                    presentedControllerView.alpha = 0
                    presentedControllerView.transform = CGAffineTransform(scaleX: scaleOneX, y: scaleOneY)
                    
                    containerView.addSubview(presentedControllerView)
                    
                    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                        presentedControllerView.alpha = 1
                        presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)                        
                    }, completion: { (completed: Bool) -> Void in
                        transitionContext.completeTransition(completed)
                    })
                }
            }
            
            
        } else {
            if let presentedControllerView = transitionContext.view(forKey: .from) {
                
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                    presentedControllerView.alpha = 0
                    presentedControllerView.transform = CGAffineTransform(scaleX: scaleTwoX, y: scaleTwoY)
                }, completion: { (completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
                })
            }
        }
    }
    
    
}

extension UIView {
    
    func setGradientBackground(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame      = bounds
        gradientLayer.colors     = colors
        gradientLayer.locations  = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = .zero
        
        layer.insertSublayer(gradientLayer, at: 0)
        
    }
}

extension UIFont {
    
    open class func tahoma(size: CGFloat) -> UIFont {
        return UIFont(name: "Tahoma", size: size)!
    }
    
}

public class HelperFunctions {

    class func getGradientLayer(with colors: [CGColor], locations: [NSNumber], on view: UIView) -> CAGradientLayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame      = view.bounds
        gradientLayer.colors     = [colors]
        gradientLayer.locations  = locations        
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint   = CGPoint(x: 0.0, y: 0.0)
        
        return gradientLayer
    }
}

