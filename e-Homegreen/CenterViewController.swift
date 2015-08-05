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
//        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
//        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
//        self.navigationController?.navigationBar.setBackgroundImage(imageFromLayer(self.navigationController!.navigationBar.layer), forBarMetrics: UIBarMetrics.Default)
//        var img = UIImage(named: "Image")
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "Image"), forBarMetrics: .Default)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 1024, 64)
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        var backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 0, 375, 667)
        view.insertSubview(backgroundImageView, atIndex: 0)
        
        
        //  Loading device view controller from singleton
//        titleOfViewController.text = "Device"
//        MenuViewControllers.sharedInstance.getViewController("Devices").view.frame = CGRectMake(0, 0, self.Container.frame.size.width, self.Container.frame.size.height)
//        self.Container.addSubview(MenuViewControllers.sharedInstance.getViewController("Devices").view)
//        case "Dashboard": backNumber = 0
//        case "Devices": backNumber = 1
//        case "Scenes": backNumber = 2
//        case "Events": backNumber = 3
//        case "Sequences": backNumber = 4
//        case "Timers": backNumber = 5
//        case "Flags": backNumber = 6
//        case "Chat": backNumber = 7
//        case "Security": backNumber = 8
//        case "Surveillance": backNumber = 9
//        case "Energy": backNumber = 10
//        case "Settings": backNumber = 11
        if NSUserDefaults.standardUserDefaults().boolForKey("firstBool") {
            if let savedValue:String = NSUserDefaults.standardUserDefaults().stringForKey("firstItem"){
                titleOfViewController.text = savedValue
            }else{
                titleOfViewController.text = "Settings"
            }
        }else{
            var returnValue: [NSString]? = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? [NSString]
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
        
        layer.renderInContext(UIGraphicsGetCurrentContext())
        var img = UIGraphicsGetImageFromCurrentImageContext()
        return img
        
    }
  var delegate: CenterViewControllerDelegate?
  
  // MARK: Button actions
    @IBAction func asfnpadogfjaspgojswdgs(sender: AnyObject) {
        delegate?.toggleLeftPanel?()
//        if UIApplication.sharedApplication().statusBarHidden {
//            UIApplication.sharedApplication().statusBarHidden = false
//        } else {
//            UIApplication.sharedApplication().statusBarHidden = true
//        }
    }
//    func menuItemSelected(menuItem: Menu) {
//        Container.addSubview(menuItem.viewController.view)
//        //    delegate?.collapseSidePanels?()
//    }
}

extension CenterViewController: SidePanelViewControllerDelegate {
  func menuItemSelected(menuItem: MenuItem) {
    Container.addSubview(menuItem.viewController!.view)
//    delegate?.collapseSidePanels?()
  }
}