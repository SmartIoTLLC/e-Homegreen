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
        gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        var backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 0, 375, 667)
        view.insertSubview(backgroundImageView, atIndex: 0)
        
        
        //  Loading device view controller from singleton
        titleOfViewController.text = Menu.allMenuItems()[0].title
        MenuViewControllers.sharedInstance.getViewController(0).view.frame = CGRectMake(0, 0, self.Container.frame.size.width, self.Container.frame.size.height)
        self.Container.addSubview(MenuViewControllers.sharedInstance.getViewController(0).view)
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
    }
//    func menuItemSelected(menuItem: Menu) {
//        Container.addSubview(menuItem.viewController.view)
//        //    delegate?.collapseSidePanels?()
//    }
}

extension CenterViewController: SidePanelViewControllerDelegate {
  func menuItemSelected(menuItem: Menu) {
    Container.addSubview(menuItem.viewController.view)
//    delegate?.collapseSidePanels?()
  }
}