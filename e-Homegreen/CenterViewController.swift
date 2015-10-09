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
    
    @IBOutlet weak var titleOfViewController: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var Container: UIView!
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

        
        MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).view.frame = CGRectMake(0, 0, self.Container.frame.size.width, self.Container.frame.size.height)
        self.Container.addSubview(MenuViewControllers.sharedInstance.getViewController(titleOfViewController.text!).view)
        
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