//
//  ContainerViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case LeftPanelCollapsed
    case LeftPanelExpanded
}
enum LeftMenu: Int {
    case Devices = 0
    case Scenes
    case Security
    case Camera
    case Database
    case NFC
    case Settings
}
class ContainerViewController: UIViewController {
    
    var centerNavigationController: UIViewController!
    var centerViewController: CenterViewController!
    
    var state:Bool = false
    
    var currentState: SlideOutState = .LeftPanelCollapsed {
        didSet {
            let shouldShowShadow = currentState != .LeftPanelCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
//    var panGestureRecognizer:UIPanGestureRecognizer!
    
    @IBAction func hamburgerTapped(sender: AnyObject) {
//        delegate?.toggleLeftPanel?()
    }
    var leftViewController: SidePanelViewController?
    
//    let centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 260
    var centerPanelExpandedOffset: CGFloat = UIScreen.mainScreen().bounds.width - 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController()
        centerViewController.delegate = self
        
//        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController = centerViewController
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
//        var gestureView = UIView(frame: CGRectMake(0, 0, 50, self.view.frame.size.height))
//        gestureView.backgroundColor = UIColor.redColor()
////        self.view.addSubview(gestureView)
//        centerViewController.view.addSubview(gestureView)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
//        gestureView.addGestureRecognizer(panGestureRecognizer)
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate {
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController()
//            leftViewController!.menuItems = Menu.allMenuItems()
            leftViewController!.menuItems = MenuViewControllers.sharedInstance.allMenuItems1()
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: SidePanelViewController) {
        sidePanelController.delegate = self
        
        view.insertSubview(sidePanelController.view, atIndex: 0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        centerPanelExpandedOffset = UIScreen.mainScreen().bounds.width - 200
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .LeftPanelCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
    
    
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    // MARK: Gesture recognizer
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touch = touch.view.superview as? UICollectionView {
            println(touch)
        }
//        let gestureIsDraggingFromRigthToLeft = (gestureRecognizer.velocityInView(view).x < 0)
//        println(gestureIsDraggingFromRigthToLeft)
        if let slider = touch.view as? UISlider {
            return false
        }
        return true
    }
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        let gestureIsDraggingFromRigthToLeft = (recognizer.velocityInView(view).x < 0)
//        if let view = recognizer.view {
//            println(view.frame.origin.x)
//            println(gestureIsDraggingFromRigthToLeft)
//            if view.frame.origin.x >= 0 {
//                if !gestureIsDraggingFromRigthToLeft && view.frame.origin.x >= 0 {
        if recognizer.locationInView(self.view).x < 300 && state == false && gestureIsDraggingFromLeftToRight == true  {
            state = true
        }
        switch(recognizer.state) {
        case .Began:
            if (currentState == .LeftPanelCollapsed) {
//                if (gestureIsDraggingFromLeftToRight) && state == true {
//                    addLeftPanelViewController()
//                }
                addLeftPanelViewController()
                showShadowForCenterViewController(true)
            }
        case .Changed:
            if !(currentState == .LeftPanelCollapsed) {
                if recognizer.view!.center.x + recognizer.translationInView(view).x > view.bounds.size.width/2 - 2 {
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                    recognizer.setTranslation(CGPointZero, inView: view)
                }
            }
            if state == true {
                if recognizer.view!.center.x + recognizer.translationInView(view).x > view.bounds.size.width/2 - 2 {
                    recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                    recognizer.setTranslation(CGPointZero, inView: view)
                }
            }
        case .Ended:
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            state = false
        default:
            break
        }
    }
//                if gestureIsDraggingFromRigthToLeft && view.frame.origin.x > 0 {
//                    if recognizer.locationInView(self.view).x < 1000 && state == false && gestureIsDraggingFromLeftToRight == true {
//                        state = true
//                    }
//                    switch(recognizer.state) {
//                    case .Began:
//                        if (currentState == .LeftPanelCollapsed) {
//                            if (gestureIsDraggingFromLeftToRight) && state == true {
//                                addLeftPanelViewController()
//                            }
//                            showShadowForCenterViewController(true)
//                        }
//                    case .Changed:
//                        if !(currentState == .LeftPanelCollapsed) {
//                            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
//                            recognizer.setTranslation(CGPointZero, inView: view)
//                        }
//                        if state == true {
//                            recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
//                            recognizer.setTranslation(CGPointZero, inView: view)
//                        }
//                    case .Ended:
//                        if (leftViewController != nil) {
//                            // animate the side panel open or closed based on whether the view has moved more or less than halfway
//                            let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
//                            animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
//                        }
//                        state = false
//                    default:
//                        break
//                    }
//                }
//            } else {
//                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > view.bounds.size.width
//                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
//            }
//        }
//        
//    }
}
private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> SidePanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuViewController") as? SidePanelViewController
    }
    
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
    
    class func deviceViewController() -> DevicesViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DeviceViewController") as? DevicesViewController
    }
    
    class func scenesViewController() -> ScenesViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("ScenesViewController") as? ScenesViewController
    }
    
    class func nfcViewController() -> NFCViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("NFCViewController") as? NFCViewController
    }
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
    class func cameraViewController() -> CameraViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CameraViewController") as? CameraViewController
    }
    
    class func databaseViewController() -> DatabaseViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("DatabaseViewController") as? DatabaseViewController
    }
    
    class func securityViewController() -> SecurityViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SecurityViewController") as? SecurityViewController
    }
}
extension ContainerViewController: SidePanelViewControllerDelegate {
    func menuItemSelected(menuItem: MenuItem) {
        if let centerViewControllerSecond = self.centerNavigationController as? CenterViewController {
            menuItem.viewController!.view.frame = CGRectMake(0, 0, centerViewControllerSecond.Container.frame.size.width, centerViewControllerSecond.Container.frame.size.height)
            centerViewControllerSecond.Container.addSubview(menuItem.viewController!.view)
            centerViewControllerSecond.titleOfViewController.text = menuItem.title
//                    view.addSubview(centerNavigationController.view)
//                    addChildViewController(centerNavigationController)
//                    centerNavigationController.didMoveToParentViewController(self)
        }
        self.toggleLeftPanel()
    }
}