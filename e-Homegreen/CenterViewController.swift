//
//  CenterViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
  optional func toggleLeftPanel()
  optional func collapseSidePanels()
}

class CenterViewController: UIViewController {
    
    
    @IBAction func btnSearchIBeacon(sender: AnyObject) {
        (UIApplication.sharedApplication().delegate as! AppDelegate).setFilterBySSIDOrByiBeaconAgain()
        btnSearchIBeacon.bouncingEffectOnTouch(1)
    }
    @IBAction func btnRefreshDevices(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("btnRefreshDevicesClicked", object: self, userInfo: nil)
        btnRefreshDevices.rotate(1)
    }
    @IBOutlet weak var btnRefreshDevices: UIButton!
    @IBOutlet weak var toggleLeftPanel: UIButton!
    @IBOutlet weak var btnSearchIBeacon: UIButton!
    @IBOutlet weak var titleOfViewController: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var Container: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var redView: UIView!
    var fromViewController:UIViewController?
    func prepareForSegue123 (sender: AnyObject?) {
        if let menuItem = sender as? MenuItem {
            let toViewController = menuItem.viewController!
            if toViewController != fromViewController {
                self.addChildViewController(menuItem.viewController!)
                self.transitionFromViewController(fromViewController!, toViewController: toViewController, duration: 0.0, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: nil, completion: {finished in
                    self.fromViewController?.removeFromParentViewController()
                    toViewController.didMoveToParentViewController(self)
                    toViewController.view.frame = self.Container.bounds
                    self.fromViewController = toViewController
                })
            } else {
                fromViewController?.viewWillAppear(true)
                fromViewController?.viewDidAppear(true)
            }
        }
    }
    override func viewDidLoad() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        //  Loading device view controller from singleton
        if NSUserDefaults.standardUserDefaults().boolForKey("firstBool") {
            if let savedValue:String = NSUserDefaults.standardUserDefaults().stringForKey("firstItem"){
                titleOfViewController.text = savedValue
            }else{
                titleOfViewController.text = "Settings"
            }
        }else{
            let returnValue: [NSString]? = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? [NSString]
            if let unwrappedTitlesForTip = returnValue {
                titleOfViewController.text = unwrappedTitlesForTip[0] as String
            }else{
                titleOfViewController.text = "Settings"
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "incomingSignal", name: "didReceiveMessageFromGateway", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendingSignal", name: "didSendMessageToGateway", object: nil)

        
        MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).view.frame = self.Container.bounds
        self.addChildViewController(MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!))
        MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).didMoveToParentViewController(self)
        self.fromViewController = MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!)
        self.Container.addSubview(MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).view)
        
    }
    
    func sendingSignal() {
        dispatch_async(dispatch_get_main_queue(), {
            self.greenView.hidden = false
            self.greenView.alpha = 1
            UIView.animateWithDuration(1, animations: {() -> Void in
                self.greenView.alpha = 0
                }, completion: {(finished:Bool) -> Void in
                    self.greenView.hidden = finished
            })
        })
    }
    
    func incomingSignal() {
        dispatch_async(dispatch_get_main_queue(), {
            self.redView.hidden = false
            self.redView.alpha = 1
            UIView.animateWithDuration(1, animations: {() -> Void in
                self.redView.alpha = 0
                }, completion: {(finished:Bool) -> Void in
                    self.redView.hidden = finished
            })
        })
    }
    
    func imageFromLayer (layer:CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        return img
        
    }
    var delegate: CenterViewControllerDelegate?
    @IBAction func btnScreenMode(sender: AnyObject) {
        btnScreenMode.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            btnScreenMode.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            btnScreenMode.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        }
    }
  
    @IBOutlet weak var btnScreenMode: UIButton!
  // MARK: Button actions
    @IBAction func asfnpadogfjaspgojswdgs(sender: AnyObject) {
        toggleLeftPanel.collapseInReturnToNormal(1)
        delegate?.toggleLeftPanel?()
    }

}

extension CenterViewController: SidePanelViewControllerDelegate {
  func menuItemSelected(menuItem: MenuItem) {
    Container.addSubview(menuItem.viewController!.view)
//    delegate?.collapseSidePanels?()
  }
}