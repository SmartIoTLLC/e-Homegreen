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
    
    @IBAction func btnRefreshDevices(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName("btnRefreshDevicesClicked", object: self, userInfo: nil)
    }
    @IBOutlet weak var btnRefreshDevices: UIButton!
    @IBOutlet weak var titleOfViewController: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var Container: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var redView: UIView!
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

        
        MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).view.frame = CGRectMake(0, 0, self.Container.frame.size.width, self.Container.frame.size.height)
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
        delegate?.toggleLeftPanel?()
    }

}

extension CenterViewController: SidePanelViewControllerDelegate {
  func menuItemSelected(menuItem: MenuItem) {
    Container.addSubview(menuItem.viewController!.view)
//    delegate?.collapseSidePanels?()
  }
}